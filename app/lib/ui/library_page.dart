import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'packs_page.dart';
import 'widgets.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int? _series;
  ReadFilter _filter = ReadFilter.all;

  void _openPacks() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PacksPage()));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final seriesList = app.availableSeries;
    if (seriesList.isEmpty) return _EmptyLibrary(onDownload: _openPacks);

    final series = seriesList.contains(_series) ? _series! : seriesList.first;
    final items = app.inSeries(series, _filter);
    final total = app.inSeries(series).length;
    final read = app.readCount(series);
    final current = app.continueReading;

    return Scaffold(
      floatingActionButton: current == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openReader(context, current.$1.id),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.continueReading),
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(floating: true, title: Text(l.libraryTitle)),
            const SliverToBoxAdapter(child: ContinueReadingCard()),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final s in seriesList)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l.seriesLabel(romanSeries[s])),
                          selected: s == series,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _series = s),
                        ),
                      ),
                    if (seriesList.length < 10)
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18, color: AppColors.accent),
                        label: Text(l.addSeries),
                        onPressed: _openPacks,
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l.readProgress(read, total),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : read / total,
                              minHeight: 4,
                              backgroundColor: AppColors.surfaceHigh,
                              color: AppColors.read,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<ReadFilter>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: ReadFilter.all, label: Text(l.filterAll)),
                        ButtonSegment(value: ReadFilter.unread, label: Text(l.filterUnread)),
                        ButtonSegment(value: ReadFilter.read, label: Text(l.filterRead)),
                      ],
                      selected: {_filter},
                      onSelectionChanged: (v) => setState(() => _filter = v.first),
                    ),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(l.noItems,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => ScpTile(scp: items[i]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onDownload});

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.libraryTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(l.noContentTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l.noContentBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded),
                label: Text(l.downloadPacks),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
