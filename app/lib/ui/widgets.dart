import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'reader_page.dart';

const romanSeries = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];

Future<void> openReader(BuildContext context, String scpId) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ReaderPage(scpId: scpId)),
  );
}

class ObjectClassBadge extends StatelessWidget {
  const ObjectClassBadge(this.objectClass, {super.key});

  final String? objectClass;

  @override
  Widget build(BuildContext context) {
    if (objectClass == null) return const SizedBox.shrink();
    final color = AppColors.objectClass(objectClass);
    final label = objectClass![0].toUpperCase() + objectClass!.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class ScpTile extends StatelessWidget {
  const ScpTile({super.key, required this.scp, this.trailingText});

  final ScpSummary scp;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final state = app.stateOf(scp.id);
    final color = AppColors.objectClass(scp.objectClass);

    return InkWell(
      onTap: () => openReader(context, scp.id),
      onLongPress: () async {
        final l = AppLocalizations.of(context);
        await app.setRead(scp.id, !state.isRead);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.isRead ? l.unmarkedRead(scp.code) : l.markedRead(scp.code)),
            duration: const Duration(seconds: 1),
          ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.35), AppColors.surfaceHigh],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                scp.number.toString().padLeft(3, '0'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scp.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: state.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(scp.code,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      ObjectClassBadge(scp.objectClass),
                    ],
                  ),
                  if (state.inProgress) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: state.scrollRatio,
                        minHeight: 3,
                        backgroundColor: AppColors.surfaceHigh,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailingText != null)
              Text(trailingText!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
            else
              _ReadBadge(read: state.isRead),
          ],
        ),
      ),
    );
  }
}

class _ReadBadge extends StatelessWidget {
  const _ReadBadge({required this.read});

  final bool read;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: read ? AppColors.read.withValues(alpha: 0.15) : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(read ? Icons.check_circle : Icons.circle_outlined,
              size: 14, color: read ? AppColors.read : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
              read
                  ? AppLocalizations.of(context).statusRead
                  : AppLocalizations.of(context).statusUnread,
              style: TextStyle(
                  fontSize: 11, color: read ? AppColors.read : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final current = app.continueReading;
    if (current == null) return const SizedBox.shrink();
    final (scp, state) = current;
    final color = AppColors.objectClass(scp.objectClass);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openReader(context, scp.id),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.35), AppColors.surface],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).nowReading,
                          style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent)),
                      const SizedBox(height: 6),
                      Text(scp.code,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(scp.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: state.isRead ? 1 : state.scrollRatio,
                                minHeight: 5,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            state.isRead
                                ? AppLocalizations.of(context).finished
                                : '${(state.scrollRatio * 100).round()}%',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => openReader(context, scp.id),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(AppLocalizations.of(context).continueReading),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
