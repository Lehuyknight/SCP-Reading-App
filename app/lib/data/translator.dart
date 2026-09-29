import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class TranslatedArticle {
  const TranslatedArticle(this.title, this.html);

  final String title;
  final String html;
}

/// Dịch Anh -> Việt ngay trên máy bằng Google ML Kit.
///
/// Kết quả chỉ giữ trong RAM: dùng lại trong phiên hiện tại, mất khi tắt app.
class ArticleTranslator {
  ArticleTranslator._();

  static final instance = ArticleTranslator._();

  static const _concurrency = 4;

  /// Nhãn chuẩn của SCP-VN, dùng thay cho bản dịch máy.
  static const _fixed = {
    'Item #:': 'Mã vật thể:',
    'Object Class:': 'Phân loại:',
    'Containment Class:': 'Lớp Quản thúc:',
    'Disruption Class:': 'Lớp Gián đoạn:',
    'Risk Class:': 'Lớp Rủi ro:',
    'Special Containment Procedures:': 'Quy trình Quản thúc Đặc biệt:',
    'Description:': 'Mô tả:',
    '[REDACTED]': '[BỊ GIẤU]',
    '[DATA EXPUNGED]': '[DỮ LIỆU BỊ XÓA]',
  };

  final _models = OnDeviceTranslatorModelManager();
  final _articles = <String, TranslatedArticle>{};
  final _pending = <String, Future<TranslatedArticle>>{};
  final _segments = <String, String>{..._fixed};
  OnDeviceTranslator? _translator;

  /// Tăng mỗi khi gói dịch được tải hoặc xóa, để UI kiểm tra lại trạng thái.
  final modelChanged = ValueNotifier<int>(0);

  static final _languages = [TranslateLanguage.english.bcpCode, TranslateLanguage.vietnamese.bcpCode];

  TranslatedArticle? cached(String id) => _articles[id];

  Future<bool> isModelReady() async {
    for (final code in _languages) {
      if (!await _models.isModelDownloaded(code)) return false;
    }
    return true;
  }

  Future<void> downloadModel() async {
    for (final code in _languages) {
      if (!await _models.isModelDownloaded(code)) {
        await _models.downloadModel(code, isWifiRequired: false);
      }
    }
    modelChanged.value++;
  }

  /// Chỉ xóa gói tiếng Việt; gói tiếng Anh do hệ thống dùng chung.
  Future<void> deleteModel() async {
    await _translator?.close();
    _translator = null;
    await _models.deleteModel(TranslateLanguage.vietnamese.bcpCode);
    modelChanged.value++;
  }

  Future<TranslatedArticle> translateArticle(
    String id,
    String title,
    String html, {
    void Function(double progress)? onProgress,
  }) {
    final hit = _articles[id];
    if (hit != null) return Future.value(hit);
    return _pending[id] ??= _translate(id, title, html, onProgress).whenComplete(() {
      _pending.remove(id);
    });
  }

  Future<TranslatedArticle> _translate(
    String id,
    String title,
    String html,
    void Function(double progress)? onProgress,
  ) async {
    final fragment = html_parser.parseFragment(html);
    final nodes = <dom.Text>[];
    void walk(dom.Node node) {
      for (final child in node.nodes) {
        if (child is dom.Text) {
          if (RegExp(r'[A-Za-z]{2,}').hasMatch(child.data)) nodes.add(child);
        } else if (child is dom.Element &&
            child.localName != 'script' &&
            child.localName != 'style') {
          walk(child);
        }
      }
    }

    walk(fragment);

    final texts = [title, ...nodes.map((n) => n.data)];
    final translated = await _translateAll(texts, onProgress);

    for (var i = 0; i < nodes.length; i++) {
      final original = nodes[i].data;
      final lead = RegExp(r'^\s*').firstMatch(original)!.group(0)!;
      final trail = RegExp(r'\s*$').firstMatch(original)!.group(0)!;
      nodes[i].data = '$lead${translated[i + 1].trim()}$trail';
    }

    final result = TranslatedArticle(translated.first.trim(), fragment.outerHtml);
    _articles[id] = result;
    return result;
  }

  Future<List<String>> _translateAll(
    List<String> texts,
    void Function(double progress)? onProgress,
  ) async {
    final translator = _translator ??= OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.vietnamese,
    );
    final normalized = texts.map((t) => t.replaceAll(RegExp(r'\s+'), ' ').trim()).toList();
    final todo = normalized.toSet().where((t) => !_segments.containsKey(t)).toList();

    var done = 0;
    onProgress?.call(todo.isEmpty ? 1 : 0);
    for (var i = 0; i < todo.length; i += _concurrency) {
      await Future.wait(todo.skip(i).take(_concurrency).map((t) async {
        _segments[t] = await translator.translateText(t);
        done++;
        onProgress?.call(done / todo.length);
      }));
    }

    return [for (final t in normalized) _segments[t] ?? t];
  }
}
