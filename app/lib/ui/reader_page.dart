import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../data/translator.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'settings_page.dart';
import 'widgets.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, required this.scpId});

  final String scpId;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final _scroll = ScrollController();
  late final AppState _app = AppScope.read(context);
  ScpArticle? _article;
  bool _showVi = true;
  bool _restoring = true;
  double _ratio = 0;
  Timer? _saveTimer;
  TranslatedArticle? _google;
  bool _showGoogle = false;
  double? _translateProgress;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  Future<void> _load() async {
    final article = await _app.content.article(widget.scpId);
    if (!mounted) return;
    final saved = _app.stateOf(widget.scpId).scrollRatio;
    setState(() {
      _article = article;
      _showVi = _app.settings.preferVietnamese && (article?.hasTranslation ?? false);
      _ratio = saved;
      _google = ArticleTranslator.instance.cached(widget.scpId);
    });
    await _app.markOpened(widget.scpId);
    _restorePosition(saved);
  }

  /// Nội dung HTML và ảnh có thể làm chiều cao thay đổi sau khi dựng, nên nhảy lại vài lần.
  void _restorePosition(double ratio) {
    _restoring = true;
    var attempts = 0;
    void jump() {
      if (!mounted || !_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) {
        if (attempts == 0) _app.saveScroll(widget.scpId, 1);
      } else {
        _scroll.jumpTo((ratio * max).clamp(0, max));
      }
      attempts++;
      if (attempts < 4) {
        Future.delayed(Duration(milliseconds: 150 * attempts * attempts), jump);
      } else {
        _restoring = false;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => jump());
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_restoring && _scroll.position.userScrollDirection != ScrollDirection.idle) {
      _restoring = false;
    }
    if (_restoring) return;
    final max = _scroll.position.maxScrollExtent;
    final ratio = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    if ((ratio - _ratio).abs() > 0.005) setState(() => _ratio = ratio);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      _app.saveScroll(widget.scpId, _ratio);
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_article != null && !_restoring) _app.saveScroll(widget.scpId, _ratio);
    _scroll.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _showVi = !_showVi;
      _showGoogle = false;
    });
    _restorePosition(_ratio);
  }

  Future<void> _toggleGoogle() async {
    final article = _article;
    if (article == null || _translateProgress != null) return;
    if (_showGoogle) {
      setState(() => _showGoogle = false);
      _restorePosition(_ratio);
      return;
    }
    if (_google == null) {
      if (!await _ensureModel()) return;
      if (!mounted) return;
      setState(() => _translateProgress = 0);
      try {
        final result = await ArticleTranslator.instance.translateArticle(
          widget.scpId,
          article.summary.titleEn,
          article.htmlEn,
          onProgress: (p) {
            if (mounted) setState(() => _translateProgress = p);
          },
        );
        if (!mounted) return;
        _google = result;
      } catch (e) {
        if (!mounted) return;
        setState(() => _translateProgress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translateFailed)),
        );
        return;
      }
    }
    setState(() {
      _translateProgress = null;
      _showGoogle = true;
    });
    _restorePosition(_ratio);
  }

  /// Hỏi rồi tải gói dịch offline nếu máy chưa có.
  Future<bool> _ensureModel() async {
    final translator = ArticleTranslator.instance;
    if (await translator.isModelReady()) return true;
    if (!mounted) return false;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.modelDownloadTitle),
        content: Text(l.modelDownloadBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.download)),
        ],
      ),
    );
    if (ok != true || !mounted) return false;
    setState(() => _translateProgress = 0);
    try {
      await translator.downloadModel();
      if (await translator.isModelReady()) return true;
    } catch (_) {}
    if (mounted) {
      setState(() => _translateProgress = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.modelDownloadFailed)));
    }
    return false;
  }

  Future<bool> _onTapUrl(String url) async {
    final match = RegExp(r'^(?:https?://(?:www\.)?scp-?wiki(?:\.wikidot)?\.com)?/(scp-\d{3,4})$',
            caseSensitive: false)
        .firstMatch(url);
    if (match != null) {
      final id = match.group(1)!.toLowerCase();
      if (_app.byId(id) != null) {
        openReader(context, id);
        return true;
      }
    }
    if (url.startsWith('#')) return false;
    final uri = Uri.parse(url.startsWith('/') ? 'https://scp-wiki.wikidot.com$url' : url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openTextSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const SafeArea(child: ReaderSettingsPanel()),
    );
  }

  Widget _translateButton(AppLocalizations l) {
    final progress = _translateProgress;
    if (progress != null) {
      return FloatingActionButton(
        onPressed: null,
        tooltip: l.translating,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: progress == 0 ? null : progress,
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
            Text('${(progress * 100).round()}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return FloatingActionButton(
      tooltip: _showGoogle ? l.showOriginal : l.translateTooltip,
      onPressed: _toggleGoogle,
      child: Icon(_showGoogle ? Icons.undo_rounded : Icons.translate_rounded),
    );
  }

  Map<String, String>? _styles(dynamic element, ReaderPalette palette) {
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    switch (element.localName) {
      case 'blockquote':
        return {
          'background-color': hex(palette.quote),
          'border-left': '3px solid ${hex(AppColors.accent)}',
          'padding': '8px 12px',
          'margin': '12px 0',
        };
      case 'table':
        return {'border-collapse': 'collapse', 'margin': '8px 0'};
      case 'td':
      case 'th':
        return {'border': '1px solid ${hex(palette.muted)}', 'padding': '4px 6px'};
      case 'summary':
        return {'font-weight': 'bold', 'color': hex(AppColors.accent)};
      case 'a':
        return {'color': hex(AppColors.accent), 'text-decoration': 'none'};
      case 'h1':
      case 'h2':
      case 'h3':
        return {'margin': '16px 0 8px 0'};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final s = app.settings;
    final palette = ReaderPalette.of(s.theme);
    final article = _article;
    final read = app.isRead(widget.scpId);
    final scp = app.byId(widget.scpId);
    final google = _showGoogle ? _google : null;
    final mode = google != null ? 'google' : (_showVi ? 'vi' : 'en');

    return Scaffold(
      backgroundColor: palette.background,
      floatingActionButton: article == null ? null : _translateButton(l),
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: palette.text),
        title: Text(scp?.code ?? widget.scpId.toUpperCase()),
        actions: [
          if (article?.hasTranslation ?? false)
            TextButton(
              onPressed: _toggleLanguage,
              child: Text(_showVi ? 'VI' : 'EN',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.accent)),
            ),
          IconButton(
            tooltip: read ? l.unmarkRead : l.markRead,
            icon: Icon(read ? Icons.check_circle : Icons.check_circle_outline,
                color: read ? AppColors.read : palette.text),
            onPressed: () => app.setRead(widget.scpId, !read),
          ),
          IconButton(
            tooltip: l.textSettings,
            icon: const Icon(Icons.text_fields),
            onPressed: _openTextSettings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _ratio,
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: article == null
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: _scroll,
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      google?.title ??
                          (_showVi ? article.summary.displayTitle : article.summary.titleEn),
                      style: TextStyle(
                          fontSize: s.fontSize + 7,
                          fontWeight: FontWeight.w800,
                          color: palette.text,
                          height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      ObjectClassBadge(article.summary.objectClass),
                      const SizedBox(width: 8),
                      if (!article.hasTranslation && app.hasTranslations)
                        Text(l.noTranslation,
                            style: TextStyle(fontSize: 12, color: palette.muted)),
                    ]),
                    const SizedBox(height: 12),
                    HtmlWidget(
                      google?.html ?? (_showVi ? article.htmlVi! : article.htmlEn),
                      key: ValueKey('${article.summary.id}-$mode'),
                      buildAsync: false,
                      textStyle: TextStyle(
                        fontSize: s.fontSize,
                        height: s.lineHeight,
                        color: palette.text,
                      ),
                      customStylesBuilder: (e) => _styles(e, palette),
                      onTapUrl: _onTapUrl,
                    ),
                    const SizedBox(height: 32),
                    Divider(color: palette.muted.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      l.attribution(
                            article.summary.code,
                            article.author != null ? l.attributionBy(article.author!) : '',
                            article.url,
                          ) +
                          (google != null
                              ? l.attributionMlKit
                              : _showVi
                                  ? l.attributionAi
                                  : ''),
                      style: TextStyle(fontSize: 12, color: palette.muted, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton.tonalIcon(
                        onPressed: () => app.setRead(widget.scpId, !read),
                        icon: Icon(read ? Icons.undo : Icons.check),
                        label: Text(read ? l.unmarkRead : l.markRead),
                      ),
                    ),
                    _NextPrev(current: article.summary),
                  ],
                ),
              ),
            ),
    );
  }
}

class _NextPrev extends StatelessWidget {
  const _NextPrev({required this.current});

  final ScpSummary current;

  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).all;
    final i = all.indexWhere((s) => s.id == current.id);
    final prev = i > 0 ? all[i - 1] : null;
    final next = i >= 0 && i < all.length - 1 ? all[i + 1] : null;

    void go(ScpSummary s) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ReaderPage(scpId: s.id)),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (prev != null)
            TextButton.icon(
              onPressed: () => go(prev),
              icon: const Icon(Icons.chevron_left),
              label: Text(prev.code),
            ),
          const Spacer(),
          if (next != null)
            TextButton.icon(
              onPressed: () => go(next),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right),
              label: Text(next.code),
            ),
        ],
      ),
    );
  }
}
