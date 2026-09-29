import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Tiến độ đọc, tách riêng khỏi gói nội dung để không mất khi cập nhật gói.
class UserDb {
  UserDb._(this._db);

  final Database _db;

  static Future<UserDb> open() async {
    final path = p.join(await getDatabasesPath(), 'user.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE reading (
          scp_id TEXT PRIMARY KEY,
          is_read INTEGER NOT NULL DEFAULT 0,
          last_opened_at INTEGER,
          scroll_ratio REAL NOT NULL DEFAULT 0
        )
      '''),
    );
    return UserDb._(db);
  }

  Future<Map<String, ReadingState>> loadAll() async {
    final rows = await _db.query('reading');
    return {for (final r in rows) r['scp_id'] as String: ReadingState.fromRow(r)};
  }

  Future<void> save(ReadingState state) => _db.insert(
        'reading',
        state.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> clear() => _db.delete('reading');
}
