import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'content_store.dart';
import 'models.dart';

/// Tải, kiểm tra và cài các gói nội dung theo series.
class PackService {
  PackService(this._store);

  final ContentStore _store;

  /// Mọi gói nằm cạnh manifest trong cùng một GitHub Release.
  static const releaseBase =
      'https://github.com/lehuyknight/scp-reader-content/releases/latest/download/';
  static const _bundledInfoAsset = 'assets/db/series-1.json';
  static const _bundledSeenKey = 'bundled_pack_version';

  final _client = http.Client();

  Future<PackInfo> bundledInfo() async => PackInfo.fromJson(
        jsonDecode(await rootBundle.loadString(_bundledInfoAsset)) as Map<String, dynamic>,
      );

  /// Cài Series I nhúng sẵn khi mở app lần đầu, hoặc khi bản app mới mang gói nhúng mới hơn.
  /// Nếu người dùng đã tự xóa Series I thì không cài lại.
  Future<void> installBundledIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await bundledInfo();
    final seen = prefs.getString(_bundledSeenKey);
    if (seen == info.version) return;

    final installed = (await _store.installedPacks())
        .where((pack) => pack.series == info.series)
        .firstOrNull;
    final firstLaunch = seen == null && installed == null;
    final bundledUpdate = installed != null && installed.bundled;
    if (firstLaunch || bundledUpdate) await installBundled();
    await prefs.setString(_bundledSeenKey, info.version);
  }

  Future<void> installBundled() async {
    final info = await bundledInfo();
    final data = await rootBundle.load('assets/db/${info.file}');
    final gz = await _tempFile(info.file);
    await gz.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    await _installGz(gz, info, bundled: true);
  }

  Future<List<PackInfo>> fetchManifest() async {
    final res = await _client
        .get(Uri.parse('${releaseBase}manifest.json'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}');
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return [
      for (final pack in json['packs'] as List) PackInfo.fromJson(pack as Map<String, dynamic>),
    ];
  }

  Future<void> download(PackInfo info, {void Function(double progress)? onProgress}) async {
    final res = await _client.send(http.Request('GET', Uri.parse('$releaseBase${info.file}')));
    if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}');
    final total = res.contentLength ?? info.size;
    final gz = await _tempFile(info.file);
    final sink = gz.openWrite();
    var received = 0;
    await for (final chunk in res.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) onProgress?.call((received / total).clamp(0.0, 1.0));
    }
    await sink.close();

    final digest = await sha256.bind(gz.openRead()).first;
    if (digest.toString() != info.sha256) {
      await gz.delete();
      throw const FormatException('Checksum mismatch');
    }
    await _installGz(gz, info, bundled: false);
  }

  Future<void> remove(int series) => _store.removePack(series);

  Future<void> _installGz(File gz, PackInfo info, {required bool bundled}) async {
    final db = File(gz.path.replaceAll(RegExp(r'\.gz$'), ''));
    try {
      await gz.openRead().transform(gzip.decoder).pipe(db.openWrite());
      await _store.installPack(db, info, bundled: bundled);
    } finally {
      for (final f in [gz, db]) {
        if (f.existsSync()) await f.delete();
      }
    }
  }

  Future<File> _tempFile(String name) async {
    final dir = Directory(p.join(await getDatabasesPath(), 'downloads'));
    await dir.create(recursive: true);
    return File(p.join(dir.path, name));
  }
}
