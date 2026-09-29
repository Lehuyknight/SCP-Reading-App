// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SCP Reader';

  @override
  String loadError(String error) {
    return 'Couldn\'t open data:\n$error';
  }

  @override
  String get navLibrary => 'Library';

  @override
  String get navHistory => 'History';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get libraryTitle => 'SCP Library';

  @override
  String get continueReading => 'Continue';

  @override
  String get nowReading => 'NOW READING';

  @override
  String get finished => 'Finished';

  @override
  String seriesLabel(String roman) {
    return 'Series $roman';
  }

  @override
  String get addSeries => 'More series';

  @override
  String readProgress(int read, int total) {
    return '$read/$total read';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterRead => 'Read';

  @override
  String get noItems => 'No articles';

  @override
  String get noContentTitle => 'No content packs yet';

  @override
  String get noContentBody => 'Download a series to start reading.';

  @override
  String get downloadPacks => 'Download content packs';

  @override
  String get statusRead => 'Read';

  @override
  String get statusUnread => 'Unread';

  @override
  String markedRead(String code) {
    return 'Marked $code as read';
  }

  @override
  String unmarkedRead(String code) {
    return 'Unmarked $code';
  }

  @override
  String get historyTitle => 'Reading history';

  @override
  String get historyEmpty => 'Nothing read yet';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) {
    return '$n min';
  }

  @override
  String hoursAgo(int n) {
    return '$n h';
  }

  @override
  String daysAgo(int n) {
    return '$n d';
  }

  @override
  String get searchHint => 'Number (e.g. 173) or title';

  @override
  String get searchPrompt => 'Enter an SCP number or title';

  @override
  String get searchNoResult => 'No results';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionReader => 'Reader';

  @override
  String get sectionData => 'Data';

  @override
  String get sectionAbout => 'About';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageSystem => 'System default';

  @override
  String get preferVietnamese => 'Prefer Vietnamese translation';

  @override
  String get preferVietnameseSub =>
      'Turn off to open the English original by default';

  @override
  String get managePacks => 'Manage content packs';

  @override
  String packsSummary(int count, int packs) {
    return '$count articles in $packs series';
  }

  @override
  String readStats(int read, int total) {
    return 'Read $read / $total';
  }

  @override
  String get resetProgress => 'Reset all reading progress';

  @override
  String get resetConfirmTitle => 'Reset progress?';

  @override
  String get resetConfirmBody =>
      'All read marks and reading positions will be deleted. This can\'t be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get translationModel => 'Offline translation pack';

  @override
  String get translationModelReady => 'English–Vietnamese pack downloaded';

  @override
  String get translationModelMissing =>
      'Not downloaded (~30 MB, downloaded on first use)';

  @override
  String get translationModelDeleted => 'Translation pack deleted';

  @override
  String get sourceTitle => 'Source: SCP Wiki (scp-wiki.wikidot.com)';

  @override
  String get sourceSubtitle => 'Licensed under CC BY-SA 3.0. Tap for details.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get fontSize => 'Font size';

  @override
  String get lineHeight => 'Line spacing';

  @override
  String get background => 'Background';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeLight => 'Light';

  @override
  String get markRead => 'Mark as read';

  @override
  String get unmarkRead => 'Unmark as read';

  @override
  String get textSettings => 'Text settings';

  @override
  String get noTranslation => 'No translation';

  @override
  String attributionBy(String author) {
    return ' by $author';
  }

  @override
  String attribution(String code, String by, String url) {
    return '\"$code\"$by, from the SCP Wiki. Source: $url. Licensed under CC BY-SA 3.0.';
  }

  @override
  String get attributionMlKit =>
      ' Vietnamese text machine-translated with Google ML Kit.';

  @override
  String get attributionAi =>
      ' Vietnamese text translated automatically by AI.';

  @override
  String get translateTooltip => 'Translate to Vietnamese';

  @override
  String get showOriginal => 'Show original';

  @override
  String get translating => 'Translating...';

  @override
  String get translateFailed => 'Couldn\'t translate. Please try again.';

  @override
  String get modelDownloadTitle => 'Download translation pack?';

  @override
  String get modelDownloadBody =>
      'Translation runs on your device and needs the offline English–Vietnamese pack (~30 MB). Download it now?';

  @override
  String get download => 'Download';

  @override
  String get modelDownloadFailed =>
      'Couldn\'t download the translation pack. Check your connection.';

  @override
  String get packsTitle => 'Content packs';

  @override
  String get packsLoadError =>
      'Couldn\'t load the online pack list. Check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get downloadAll => 'Download all';

  @override
  String get packInstalled => 'Downloaded';

  @override
  String get packBundled => 'Built into the app';

  @override
  String get packUpdate => 'Update available';

  @override
  String get packNotInstalled => 'Not downloaded';

  @override
  String packMeta(int count, String size) {
    return '$count articles · $size';
  }

  @override
  String get install => 'Install';

  @override
  String get update => 'Update';

  @override
  String get remove => 'Remove';

  @override
  String packRemoveConfirm(String roman) {
    return 'Remove Series $roman? Your reading progress is kept.';
  }

  @override
  String packInstallFailed(String roman) {
    return 'Couldn\'t install Series $roman.';
  }

  @override
  String get licenseTitle => 'License';

  @override
  String get licenseIntro =>
      'Articles in this app come from the SCP Wiki (scp-wiki.wikidot.com) and are licensed under Creative Commons Attribution-ShareAlike 3.0 (CC BY-SA 3.0).';

  @override
  String get licenseAttribution =>
      'Each article credits its original author(s) and links to the source page at the end of the article.';

  @override
  String get licenseShareAlike =>
      'Machine translations shown in the app are derivative works and are shared under the same CC BY-SA 3.0 license.';

  @override
  String get licenseImages =>
      'Images are loaded directly from the SCP Wiki and may be covered by their own licenses. See the image\'s source page for details.';

  @override
  String get licenseUnofficial =>
      'This is an unofficial, fan-made app. It is not affiliated with or endorsed by the SCP Wiki or its staff.';

  @override
  String get openLicense => 'View CC BY-SA 3.0 license';

  @override
  String get openSourceLicenses => 'Open-source licenses';
}
