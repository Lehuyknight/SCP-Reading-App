import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'widgets.dart';

class PacksPage extends StatefulWidget {
  const PacksPage({super.key});

  @override
  State<PacksPage> createState() => _PacksPageState();
}

class _PacksPageState extends State<PacksPage> {
  List<PackInfo>? _remote;
  PackInfo? _bundled;
  bool _loadFailed = false;
  bool _loading = true;

  /// series -> tiến trình tải (0..1), `null` khi đang giải nén/cài.
  final _busy = <int, double?>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final app = AppScope.read(context);
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    _bundled ??= await app.packs.bundledInfo();
    try {
      _remote = await app.packs.fetchManifest();
    } catch (_) {
      _loadFailed = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _install(PackInfo info, {required bool fromBundle}) async {
    final app = AppScope.read(context);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy[info.series] = fromBundle ? null : 0);
    try {
      if (fromBundle) {
        await app.packs.installBundled();
      } else {
        await app.packs.download(info, onProgress: (p) {
          if (mounted) setState(() => _busy[info.series] = p >= 1 ? null : p);
        });
      }
      await app.reloadContent();
    } catch (_) {
      messenger.showSnackBar(
          SnackBar(content: Text(l.packInstallFailed(romanSeries[info.series]))));
    } finally {
      if (mounted) setState(() => _busy.remove(info.series));
    }
  }

  Future<void> _remove(int series) async {
    final app = AppScope.read(context);
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.packRemoveConfirm(romanSeries[series])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.remove)),
        ],
      ),
    );
    if (ok != true) return;
    await app.packs.remove(series);
    await app.reloadContent();
  }

  Future<void> _installAll(List<PackInfo> missing) async {
    for (final info in missing) {
      if (!mounted) return;
      await _install(info, fromBundle: false);
    }
  }

  static String _size(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final installed = {for (final p in app.installedPacks) p.series: p};
    final remote = {for (final p in _remote ?? const <PackInfo>[]) p.series: p};
    final bundled = _bundled;
    final seriesList = {
      ...remote.keys,
      ...installed.keys,
      if (bundled != null) bundled.series,
    }.toList()
      ..sort();
    final missing = [
      for (final s in seriesList)
        if (remote[s] != null &&
            (installed[s] == null || installed[s]!.version != remote[s]!.version))
          remote[s]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.packsTitle),
        actions: [
          if (missing.isNotEmpty && _busy.isEmpty)
            TextButton.icon(
              onPressed: () => _installAll(missing),
              icon: const Icon(Icons.download_rounded),
              label: Text(l.downloadAll),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            if (_loadFailed)
              ListTile(
                leading: const Icon(Icons.cloud_off, color: Colors.orangeAccent),
                title: Text(l.packsLoadError),
                trailing: TextButton(onPressed: _load, child: Text(l.retry)),
              ),
            for (final s in seriesList)
              _PackTile(
                series: s,
                installed: installed[s],
                remote: remote[s],
                bundled: bundled?.series == s ? bundled : null,
                busy: _busy.containsKey(s),
                progress: _busy[s],
                sizeLabel: _size,
                onInstall: (info, fromBundle) => _install(info, fromBundle: fromBundle),
                onRemove: () => _remove(s),
              ),
          ],
        ),
      ),
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    required this.series,
    required this.installed,
    required this.remote,
    required this.bundled,
    required this.busy,
    required this.progress,
    required this.sizeLabel,
    required this.onInstall,
    required this.onRemove,
  });

  final int series;
  final InstalledPack? installed;
  final PackInfo? remote;
  final PackInfo? bundled;
  final bool busy;
  final double? progress;
  final String Function(int bytes) sizeLabel;
  final void Function(PackInfo info, bool fromBundle) onInstall;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final installed = this.installed;
    final remote = this.remote;
    final bundled = this.bundled;
    final hasUpdate = installed != null && remote != null && installed.version != remote.version;
    final info = remote ?? bundled;

    final status = installed == null
        ? l.packNotInstalled
        : hasUpdate
            ? l.packUpdate
            : installed.bundled
                ? l.packBundled
                : l.packInstalled;
    final statusColor = installed == null
        ? AppColors.textSecondary
        : hasUpdate
            ? AppColors.accent
            : AppColors.read;
    final meta = info != null
        ? l.packMeta(info.count, sizeLabel(info.size))
        : l.packMeta(installed?.count ?? 0, '—');

    Widget action;
    if (busy) {
      action = SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 3, value: progress),
      );
    } else if (installed == null) {
      final fromBundle = remote == null && bundled != null;
      action = FilledButton.tonal(
        onPressed: info == null ? null : () => onInstall(info, fromBundle),
        child: Text(l.install),
      );
    } else {
      action = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUpdate)
            FilledButton.tonal(onPressed: () => onInstall(remote, false), child: Text(l.update)),
          IconButton(
            tooltip: l.remove,
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceHigh,
        child: Text(romanSeries[series],
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
      title: Text(l.seriesLabel(romanSeries[series])),
      subtitle: Text.rich(TextSpan(children: [
        TextSpan(text: status, style: TextStyle(color: statusColor)),
        TextSpan(text: '  ·  $meta'),
      ])),
      trailing: action,
    );
  }
}
