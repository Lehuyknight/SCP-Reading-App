import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static String _ago(AppLocalizations l, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l.justNow;
    if (d.inHours < 1) return l.minutesAgo(d.inMinutes);
    if (d.inDays < 1) return l.hoursAgo(d.inHours);
    if (d.inDays < 30) return l.daysAgo(d.inDays);
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = AppScope.of(context).history;
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: history.isEmpty
          ? Center(
              child: Text(l.historyEmpty,
                  style: const TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, i) {
                final (scp, state) = history[i];
                return ScpTile(scp: scp, trailingText: _ago(l, state.lastOpenedAt!));
              },
            ),
    );
  }
}
