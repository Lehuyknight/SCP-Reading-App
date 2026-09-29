import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/translator.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'license_page.dart';
import 'packs_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _languages = {'vi': 'Tiếng Việt', 'en': 'English'};

  Future<void> _pickLanguage(BuildContext context, AppState app) async {
    final l = AppLocalizations.of(context);
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.appLanguage),
        children: [
          for (final entry in {'': l.languageSystem, ..._languages}.entries)
            ListTile(
              leading: Icon(
                (app.appLocale ?? '') == entry.key
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.accent,
              ),
              title: Text(entry.value),
              onTap: () => Navigator.pop(ctx, entry.key),
            ),
        ],
      ),
    );
    if (picked != null) await app.setAppLocale(picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final s = app.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Header(l.sectionGeneral),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.appLanguage),
            subtitle: Text(_languages[app.appLocale] ?? l.languageSystem),
            onTap: () => _pickLanguage(context, app),
          ),
          _Header(l.sectionReader),
          const ReaderSettingsPanel(),
          if (app.hasTranslations)
            SwitchListTile(
              title: Text(l.preferVietnamese),
              subtitle: Text(l.preferVietnameseSub),
              value: s.preferVietnamese,
              onChanged: (v) => app.updateSettings(s.copyWith(preferVietnamese: v)),
            ),
          const _TranslationModelTile(),
          _Header(l.sectionData),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(l.managePacks),
            subtitle: Text(l.packsSummary(app.all.length, app.installedPacks.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PacksPage())),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l.readStats(app.readCount(), app.all.length)),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
            title: Text(l.resetProgress),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.resetConfirmTitle),
                  content: Text(l.resetConfirmBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
                  ],
                ),
              );
              if (ok == true) await app.resetProgress();
            },
          ),
          _Header(l.sectionAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.sourceTitle),
            subtitle: Text(l.sourceSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const LicensePageView())),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: openPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}

class _TranslationModelTile extends StatefulWidget {
  const _TranslationModelTile();

  @override
  State<_TranslationModelTile> createState() => _TranslationModelTileState();
}

class _TranslationModelTileState extends State<_TranslationModelTile> {
  final _translator = ArticleTranslator.instance;
  late Future<bool> _ready = _translator.isModelReady();

  @override
  void initState() {
    super.initState();
    _translator.modelChanged.addListener(_refresh);
  }

  @override
  void dispose() {
    _translator.modelChanged.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() => _ready = _translator.isModelReady());

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await _translator.deleteModel();
    messenger.showSnackBar(SnackBar(content: Text(l.translationModelDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<bool>(
      future: _ready,
      builder: (context, snapshot) {
        final ready = snapshot.data ?? false;
        return ListTile(
          leading: const Icon(Icons.translate),
          title: Text(l.translationModel),
          subtitle: Text(ready ? l.translationModelReady : l.translationModelMissing),
          trailing: ready
              ? IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _delete,
                )
              : null,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: AppColors.accent)),
      );
}

/// Dùng chung cho trang Cài đặt và bảng tùy chỉnh trong trình đọc.
class ReaderSettingsPanel extends StatelessWidget {
  const ReaderSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final s = app.settings;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 90, child: Text(l.fontSize)),
              Expanded(
                child: Slider(
                  min: 13,
                  max: 26,
                  divisions: 13,
                  value: s.fontSize,
                  label: s.fontSize.round().toString(),
                  onChanged: (v) => app.updateSettings(s.copyWith(fontSize: v)),
                ),
              ),
              SizedBox(width: 28, child: Text(s.fontSize.round().toString())),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 90, child: Text(l.lineHeight)),
              Expanded(
                child: Slider(
                  min: 1.2,
                  max: 2.2,
                  divisions: 10,
                  value: s.lineHeight,
                  label: s.lineHeight.toStringAsFixed(1),
                  onChanged: (v) => app.updateSettings(s.copyWith(lineHeight: v)),
                ),
              ),
              SizedBox(width: 28, child: Text(s.lineHeight.toStringAsFixed(1))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 90, child: Text(l.background)),
              for (final t in ReaderTheme.values)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ThemeDot(
                    theme: t,
                    selected: s.theme == t,
                    onTap: () => app.updateSettings(s.copyWith(theme: t)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({required this.theme, required this.selected, required this.onTap});

  final ReaderTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = ReaderPalette.of(theme);
    final label = switch (theme) {
      ReaderTheme.dark => l.themeDark,
      ReaderTheme.sepia => l.themeSepia,
      ReaderTheme.light => l.themeLight,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label, style: TextStyle(color: palette.text, fontSize: 13)),
      ),
    );
  }
}
