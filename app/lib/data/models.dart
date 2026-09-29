class ScpSummary {
  const ScpSummary({
    required this.id,
    required this.number,
    required this.series,
    required this.titleEn,
    this.titleVi,
    this.objectClass,
  });

  final String id;
  final int number;
  final int series;
  final String titleEn;
  final String? titleVi;
  final String? objectClass;

  String get code => 'SCP-${number.toString().padLeft(3, '0')}';

  String get displayTitle =>
      (titleVi != null && titleVi!.isNotEmpty) ? titleVi! : titleEn;

  factory ScpSummary.fromRow(Map<String, Object?> row) => ScpSummary(
        id: row['id'] as String,
        number: row['number'] as int,
        series: row['series'] as int,
        titleEn: (row['title_en'] as String?) ?? '',
        titleVi: row['title_vi'] as String?,
        objectClass: row['object_class'] as String?,
      );
}

class ScpArticle {
  const ScpArticle({
    required this.summary,
    required this.url,
    required this.htmlEn,
    this.htmlVi,
    this.author,
    this.tags = const [],
  });

  final ScpSummary summary;
  final String url;
  final String htmlEn;
  final String? htmlVi;
  final String? author;
  final List<String> tags;

  bool get hasTranslation => htmlVi != null && htmlVi!.isNotEmpty;

  factory ScpArticle.fromRow(Map<String, Object?> row) => ScpArticle(
        summary: ScpSummary.fromRow(row),
        url: (row['url'] as String?) ?? '',
        htmlEn: (row['html_en'] as String?) ?? '',
        htmlVi: row['html_vi'] as String?,
        author: row['author'] as String?,
        tags: ((row['tags'] as String?) ?? '')
            .split(',')
            .where((t) => t.isNotEmpty)
            .toList(),
      );
}

/// Một gói nội dung trong manifest (hoặc gói nhúng sẵn trong assets).
class PackInfo {
  const PackInfo({
    required this.series,
    required this.file,
    required this.version,
    required this.count,
    required this.size,
    required this.sha256,
  });

  final int series;
  final String file;
  final String version;
  final int count;
  final int size;
  final String sha256;

  factory PackInfo.fromJson(Map<String, dynamic> json) => PackInfo(
        series: (json['series'] as num).toInt(),
        file: json['file'] as String,
        version: json['version'] as String,
        count: (json['count'] as num).toInt(),
        size: (json['size'] as num).toInt(),
        sha256: json['sha256'] as String,
      );
}

class InstalledPack {
  const InstalledPack({
    required this.series,
    required this.version,
    required this.count,
    required this.bundled,
  });

  final int series;
  final String version;
  final int count;
  final bool bundled;
}

class ReadingState {
  const ReadingState({
    required this.scpId,
    this.isRead = false,
    this.lastOpenedAt,
    this.scrollRatio = 0,
  });

  final String scpId;
  final bool isRead;
  final DateTime? lastOpenedAt;
  final double scrollRatio;

  bool get inProgress => !isRead && scrollRatio > 0.02;

  ReadingState copyWith({
    bool? isRead,
    DateTime? lastOpenedAt,
    double? scrollRatio,
  }) =>
      ReadingState(
        scpId: scpId,
        isRead: isRead ?? this.isRead,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
        scrollRatio: scrollRatio ?? this.scrollRatio,
      );

  factory ReadingState.fromRow(Map<String, Object?> row) => ReadingState(
        scpId: row['scp_id'] as String,
        isRead: (row['is_read'] as int? ?? 0) == 1,
        lastOpenedAt: row['last_opened_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['last_opened_at'] as int),
        scrollRatio: (row['scroll_ratio'] as num? ?? 0).toDouble(),
      );

  Map<String, Object?> toRow() => {
        'scp_id': scpId,
        'is_read': isRead ? 1 : 0,
        'last_opened_at': lastOpenedAt?.millisecondsSinceEpoch,
        'scroll_ratio': scrollRatio,
      };
}
