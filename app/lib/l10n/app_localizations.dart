import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SCP Reader'**
  String get appTitle;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open data:\n{error}'**
  String loadError(String error);

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'SCP Library'**
  String get libraryTitle;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueReading;

  /// No description provided for @nowReading.
  ///
  /// In en, this message translates to:
  /// **'NOW READING'**
  String get nowReading;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @seriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Series {roman}'**
  String seriesLabel(String roman);

  /// No description provided for @addSeries.
  ///
  /// In en, this message translates to:
  /// **'More series'**
  String get addSeries;

  /// No description provided for @readProgress.
  ///
  /// In en, this message translates to:
  /// **'{read}/{total} read'**
  String readProgress(int read, int total);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @filterRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get filterRead;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No articles'**
  String get noItems;

  /// No description provided for @noContentTitle.
  ///
  /// In en, this message translates to:
  /// **'No content packs yet'**
  String get noContentTitle;

  /// No description provided for @noContentBody.
  ///
  /// In en, this message translates to:
  /// **'Download a series to start reading.'**
  String get noContentBody;

  /// No description provided for @downloadPacks.
  ///
  /// In en, this message translates to:
  /// **'Download content packs'**
  String get downloadPacks;

  /// No description provided for @statusRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get statusRead;

  /// No description provided for @statusUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get statusUnread;

  /// No description provided for @markedRead.
  ///
  /// In en, this message translates to:
  /// **'Marked {code} as read'**
  String markedRead(String code);

  /// No description provided for @unmarkedRead.
  ///
  /// In en, this message translates to:
  /// **'Unmarked {code}'**
  String unmarkedRead(String code);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading history'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing read yet'**
  String get historyEmpty;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} d'**
  String daysAgo(int n);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Number (e.g. 173) or title'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter an SCP number or title'**
  String get searchPrompt;

  /// No description provided for @searchNoResult.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResult;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionReader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get sectionReader;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @preferVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Prefer Vietnamese translation'**
  String get preferVietnamese;

  /// No description provided for @preferVietnameseSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off to open the English original by default'**
  String get preferVietnameseSub;

  /// No description provided for @managePacks.
  ///
  /// In en, this message translates to:
  /// **'Manage content packs'**
  String get managePacks;

  /// No description provided for @packsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} articles in {packs} series'**
  String packsSummary(int count, int packs);

  /// No description provided for @readStats.
  ///
  /// In en, this message translates to:
  /// **'Read {read} / {total}'**
  String readStats(int read, int total);

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset all reading progress'**
  String get resetProgress;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All read marks and reading positions will be deleted. This can\'t be undone.'**
  String get resetConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @translationModel.
  ///
  /// In en, this message translates to:
  /// **'Offline translation pack'**
  String get translationModel;

  /// No description provided for @translationModelReady.
  ///
  /// In en, this message translates to:
  /// **'English–Vietnamese pack downloaded'**
  String get translationModelReady;

  /// No description provided for @translationModelMissing.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded (~30 MB, downloaded on first use)'**
  String get translationModelMissing;

  /// No description provided for @translationModelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Translation pack deleted'**
  String get translationModelDeleted;

  /// No description provided for @sourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Source: SCP Wiki (scp-wiki.wikidot.com)'**
  String get sourceTitle;

  /// No description provided for @sourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Licensed under CC BY-SA 3.0. Tap for details.'**
  String get sourceSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @lineHeight.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get lineHeight;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @unmarkRead.
  ///
  /// In en, this message translates to:
  /// **'Unmark as read'**
  String get unmarkRead;

  /// No description provided for @textSettings.
  ///
  /// In en, this message translates to:
  /// **'Text settings'**
  String get textSettings;

  /// No description provided for @noTranslation.
  ///
  /// In en, this message translates to:
  /// **'No translation'**
  String get noTranslation;

  /// No description provided for @attributionBy.
  ///
  /// In en, this message translates to:
  /// **' by {author}'**
  String attributionBy(String author);

  /// No description provided for @attribution.
  ///
  /// In en, this message translates to:
  /// **'\"{code}\"{by}, from the SCP Wiki. Source: {url}. Licensed under CC BY-SA 3.0.'**
  String attribution(String code, String by, String url);

  /// No description provided for @attributionMlKit.
  ///
  /// In en, this message translates to:
  /// **' Vietnamese text machine-translated with Google ML Kit.'**
  String get attributionMlKit;

  /// No description provided for @attributionAi.
  ///
  /// In en, this message translates to:
  /// **' Vietnamese text translated automatically by AI.'**
  String get attributionAi;

  /// No description provided for @translateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Translate to Vietnamese'**
  String get translateTooltip;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @translateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate. Please try again.'**
  String get translateFailed;

  /// No description provided for @modelDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download translation pack?'**
  String get modelDownloadTitle;

  /// No description provided for @modelDownloadBody.
  ///
  /// In en, this message translates to:
  /// **'Translation runs on your device and needs the offline English–Vietnamese pack (~30 MB). Download it now?'**
  String get modelDownloadBody;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @modelDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the translation pack. Check your connection.'**
  String get modelDownloadFailed;

  /// No description provided for @packsTitle.
  ///
  /// In en, this message translates to:
  /// **'Content packs'**
  String get packsTitle;

  /// No description provided for @packsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the online pack list. Check your connection.'**
  String get packsLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get downloadAll;

  /// No description provided for @packInstalled.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get packInstalled;

  /// No description provided for @packBundled.
  ///
  /// In en, this message translates to:
  /// **'Built into the app'**
  String get packBundled;

  /// No description provided for @packUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get packUpdate;

  /// No description provided for @packNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded'**
  String get packNotInstalled;

  /// No description provided for @packMeta.
  ///
  /// In en, this message translates to:
  /// **'{count} articles · {size}'**
  String packMeta(int count, String size);

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @packRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove Series {roman}? Your reading progress is kept.'**
  String packRemoveConfirm(String roman);

  /// No description provided for @packInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t install Series {roman}.'**
  String packInstallFailed(String roman);

  /// No description provided for @licenseTitle.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licenseTitle;

  /// No description provided for @licenseIntro.
  ///
  /// In en, this message translates to:
  /// **'Articles in this app come from the SCP Wiki (scp-wiki.wikidot.com) and are licensed under Creative Commons Attribution-ShareAlike 3.0 (CC BY-SA 3.0).'**
  String get licenseIntro;

  /// No description provided for @licenseAttribution.
  ///
  /// In en, this message translates to:
  /// **'Each article credits its original author(s) and links to the source page at the end of the article.'**
  String get licenseAttribution;

  /// No description provided for @licenseShareAlike.
  ///
  /// In en, this message translates to:
  /// **'Machine translations shown in the app are derivative works and are shared under the same CC BY-SA 3.0 license.'**
  String get licenseShareAlike;

  /// No description provided for @licenseImages.
  ///
  /// In en, this message translates to:
  /// **'Images are loaded directly from the SCP Wiki and may be covered by their own licenses. See the image\'s source page for details.'**
  String get licenseImages;

  /// No description provided for @licenseUnofficial.
  ///
  /// In en, this message translates to:
  /// **'This is an unofficial, fan-made app. It is not affiliated with or endorsed by the SCP Wiki or its staff.'**
  String get licenseUnofficial;

  /// No description provided for @openLicense.
  ///
  /// In en, this message translates to:
  /// **'View CC BY-SA 3.0 license'**
  String get openLicense;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
