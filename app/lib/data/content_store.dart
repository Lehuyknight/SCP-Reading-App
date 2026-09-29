import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Toàn bộ nội dung SCP đã cài trên máy, gộp từ các gói theo series.
class ContentStore {
  ContentStore._(this._db);

  final Database _db;

  static Future<ContentStore> open() async {
    final path = p.join(await getDatabasesPath(), 'content.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE scp (
            id TEXT PRIMARY KEY,
            number INTEGER NOT NULL,
            series INTEGER NOT NULL,
            title_en TEXT,
            title_vi TEXT,
            object_class TEXT,
            author TEXT,
            url TEXT,
            tags TEXT,
            html_en TEXT,
            html_vi TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_scp_series ON scp(series, number)');
        await db.execute('''
          CREATE TABLE packs (
            series INTEGER PRIMARY KEY,
            version TEXT NOT NULL,
            count INTEGER NOT NULL,
            bundled INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return ContentStore._(db);
  }

  Future<List<InstalledPack>> installedPacks() async {
    final rows = await _db.query('packs', orderBy: 'series');
    return [
      for (final r in rows)
        InstalledPack(
          series: r['series'] as int,
          version: r['version'] as String,
          count: r['count'] as int,
          bundled: (r['bundled'] as int) == 1,
        ),
    ];
  }

  /// Chép bảng `scp` từ file gói (SQLite đã giải nén) vào kho, thay thế series cũ nếu có.
  Future<void> installPack(File packDb, PackInfo info, {required bool bundled}) async {
    await _db.execute('ATTACH DATABASE ? AS pack', [packDb.path]);
    try {
      await _db.transaction((txn) async {
        await txn.delete('scp', where: 'series = ?', whereArgs: [info.series]);
        await txn.execute('INSERT OR REPLACE INTO scp SELECT * FROM pack.scp');
        await txn.insert(
          'packs',
          {
            'series': info.series,
            'version': info.version,
            'count': info.count,
            'bundled': bundled ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } finally {
      await _db.execute('DETACH DATABASE pack');
    }
  }

  Future<void> removePack(int series) => _db.transaction((txn) async {
        await txn.delete('scp', where: 'series = ?', whereArgs: [series]);
        await txn.delete('packs', where: 'series = ?', whereArgs: [series]);
      });

  Future<List<ScpSummary>> allSummaries() async {
    final rows = await _db.query(
      'scp',
      columns: ['id', 'number', 'series', 'title_en', 'title_vi', 'object_class'],
      orderBy: 'number',
    );
    return rows.map(ScpSummary.fromRow).toList();
  }

  Future<ScpArticle?> article(String id) async {
    final rows = await _db.query('scp', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ScpArticle.fromRow(rows.first);
  }
}
