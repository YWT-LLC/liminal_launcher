import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'lang_ar.dart' deferred as lang_ar;
import 'lang_de.dart' deferred as lang_de;
import 'lang_en.dart' deferred as lang_en;
import 'lang_es.dart' deferred as lang_es;
import 'lang_fil.dart' deferred as lang_fil;
import 'lang_fr.dart' deferred as lang_fr;
import 'lang_hi.dart' deferred as lang_hi;
import 'lang_ht.dart' deferred as lang_ht;
import 'lang_ja.dart' deferred as lang_ja;
import 'lang_ko.dart' deferred as lang_ko;
import 'lang_ru.dart' deferred as lang_ru;
import 'lang_sw.dart' deferred as lang_sw;
import 'lang_uk.dart' deferred as lang_uk;
import 'lang_zh.dart' deferred as lang_zh;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Lang
/// returned by `Lang.of(context)`.
///
/// Applications need to include `Lang.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/lang.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Lang.localizationsDelegates,
///   supportedLocales: Lang.supportedLocales,
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
/// be consistent with the languages listed in the Lang.supportedLocales
/// property.
abstract class Lang {
  Lang(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Lang? of(BuildContext context) {
    return Localizations.of<Lang>(context, Lang);
  }

  static const LocalizationsDelegate<Lang> delegate = _LangDelegate();

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
    Locale('ar'),
    Locale('ar', 'EG'),
    Locale('de'),
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('hi'),
    Locale('ht'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('sw'),
    Locale('uk'),
    Locale('zh'),
    Locale('zh', 'CN')
  ];

  /// No description provided for @gAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get gAdd;

  /// No description provided for @gDupe.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get gDupe;

  /// No description provided for @gEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get gEdit;

  /// No description provided for @gResize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get gResize;

  /// No description provided for @gButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get gButton;

  /// No description provided for @gTile.
  ///
  /// In en, this message translates to:
  /// **'Tile'**
  String get gTile;

  /// No description provided for @gWideTiles.
  ///
  /// In en, this message translates to:
  /// **'Wide tiles'**
  String get gWideTiles;

  /// No description provided for @gSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get gSearch;

  /// No description provided for @gSearchBar.
  ///
  /// In en, this message translates to:
  /// **'Search bar'**
  String get gSearchBar;

  /// No description provided for @gEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get gEnd;

  /// No description provided for @gCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get gCenter;

  /// No description provided for @gStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gStart;

  /// No description provided for @gHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get gHidden;

  /// No description provided for @gShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get gShared;

  /// No description provided for @gShown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get gShown;

  /// No description provided for @gFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get gFailed;

  /// No description provided for @gNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get gNothing;

  /// No description provided for @gSelfDestruct.
  ///
  /// In en, this message translates to:
  /// **'Self-destruct'**
  String get gSelfDestruct;

  /// No description provided for @hsHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get hsHome;

  /// No description provided for @hsWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Liminal Launcher'**
  String get hsWelcome;

  /// No description provided for @hsDescription.
  ///
  /// In en, this message translates to:
  /// **'It\'s geared toward minimalism,\nbut has limitless customization.'**
  String get hsDescription;

  /// No description provided for @hsUserSettings.
  ///
  /// In en, this message translates to:
  /// **'Personalization is easy, and everything that needs explanation will have it.\n\nAs a general rule: Liminal\'s appearance can be completely separate based on theme mode!\n\nWhile in the relevant settings, you will see a toggle-able icon that indicates whether you\'re editing the dark '**
  String get hsUserSettings;

  /// No description provided for @hsLight.
  ///
  /// In en, this message translates to:
  /// **', light '**
  String get hsLight;

  /// No description provided for @hsBoth.
  ///
  /// In en, this message translates to:
  /// **', or both '**
  String get hsBoth;

  /// No description provided for @hsThemes.
  ///
  /// In en, this message translates to:
  /// **' themes.'**
  String get hsThemes;

  /// No description provided for @hsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Long press the home screen to get started.\nThank you, and enjoy!'**
  String get hsGetStarted;

  /// No description provided for @hsOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more thing...'**
  String get hsOneMore;

  /// No description provided for @hsFree.
  ///
  /// In en, this message translates to:
  /// **'This version is not from the Play Store, so it should have been free.\nRest assured, the free version of Liminal will always be identical to the Google Play version.\n\nIf you want to support Liminal\'s development, or the development of more cool software, please consider '**
  String get hsFree;

  /// No description provided for @hsContribute.
  ///
  /// In en, this message translates to:
  /// **'contributing'**
  String get hsContribute;

  /// No description provided for @hsContributeHint.
  ///
  /// In en, this message translates to:
  /// **'Open a link to contribution options'**
  String get hsContributeHint;

  /// No description provided for @hsPopUp.
  ///
  /// In en, this message translates to:
  /// **'.\n\nThis is the only non-tutorial pop-up, and its only appearance this install.'**
  String get hsPopUp;

  /// No description provided for @hsOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get hsOkay;

  /// No description provided for @hsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get hsApp;

  /// No description provided for @hsFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get hsFolder;

  /// No description provided for @hsLane.
  ///
  /// In en, this message translates to:
  /// **'Lane'**
  String get hsLane;

  /// No description provided for @hsSpacer.
  ///
  /// In en, this message translates to:
  /// **'Spacer'**
  String get hsSpacer;

  /// No description provided for @hsWidget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get hsWidget;

  /// No description provided for @hsScreenLanes.
  ///
  /// In en, this message translates to:
  /// **' lanes on screen.'**
  String get hsScreenLanes;

  /// No description provided for @hsWithCurr.
  ///
  /// In en, this message translates to:
  /// **'With your current...\n\nicon size ('**
  String get hsWithCurr;

  /// No description provided for @hsPadding.
  ///
  /// In en, this message translates to:
  /// **'),\npadding ('**
  String get hsPadding;

  /// No description provided for @hsSpacing.
  ///
  /// In en, this message translates to:
  /// **'),\n& spacing ('**
  String get hsSpacing;

  /// No description provided for @hsCanFit.
  ///
  /// In en, this message translates to:
  /// **'...values, you can fit up to '**
  String get hsCanFit;

  /// No description provided for @hsWithMin.
  ///
  /// In en, this message translates to:
  /// **' With the minimum values, you can fit up to '**
  String get hsWithMin;

  /// No description provided for @hsLanes.
  ///
  /// In en, this message translates to:
  /// **' lanes.'**
  String get hsLanes;

  /// No description provided for @hsHiddenAuth.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to see hidden apps'**
  String get hsHiddenAuth;

  /// No description provided for @wsBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get wsBackground;

  /// No description provided for @wsBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get wsBackgroundColor;

  /// No description provided for @wsBackgroundShape.
  ///
  /// In en, this message translates to:
  /// **'Background shape'**
  String get wsBackgroundShape;

  /// No description provided for @wsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get wsDate;

  /// No description provided for @wsDateColor.
  ///
  /// In en, this message translates to:
  /// **'Date color'**
  String get wsDateColor;

  /// No description provided for @wsDateStyle.
  ///
  /// In en, this message translates to:
  /// **'Date style'**
  String get wsDateStyle;

  /// No description provided for @wsDateType.
  ///
  /// In en, this message translates to:
  /// **'Date type'**
  String get wsDateType;

  /// No description provided for @wsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get wsTime;

  /// No description provided for @wsTimeBool.
  ///
  /// In en, this message translates to:
  /// **'Show time'**
  String get wsTimeBool;

  /// No description provided for @wsTimeColor.
  ///
  /// In en, this message translates to:
  /// **'Time color'**
  String get wsTimeColor;

  /// No description provided for @wsTimeStyle.
  ///
  /// In en, this message translates to:
  /// **'Time style'**
  String get wsTimeStyle;

  /// No description provided for @wsAppIcon.
  ///
  /// In en, this message translates to:
  /// **'Use app icon'**
  String get wsAppIcon;

  /// No description provided for @wsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get wsCalendar;

  /// No description provided for @wsClear.
  ///
  /// In en, this message translates to:
  /// **'Long press to clear'**
  String get wsClear;

  /// No description provided for @wsNewEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get wsNewEvent;

  /// No description provided for @wsNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get wsNewTask;

  /// No description provided for @wsNoCalendar.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find a default calendar app.\nWhat shall I do?\n\n\'Task\' is just share underneath. You\'ll choose a default app to share with.\nWe recommend using a task app, but don\'t require.\nResults may vary.'**
  String get wsNoCalendar;

  /// No description provided for @wsShare.
  ///
  /// In en, this message translates to:
  /// **'\'Task\' is just share underneath.\nChoose a destination app below.\n\nWe recommend using a task app, but it\'s not required. Results may vary.'**
  String get wsShare;

  /// No description provided for @wsShareDest.
  ///
  /// In en, this message translates to:
  /// **'Selecting share destination'**
  String get wsShareDest;

  /// No description provided for @wsTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get wsTask;

  /// No description provided for @wsUseTasks.
  ///
  /// In en, this message translates to:
  /// **'Switch to tasks'**
  String get wsUseTasks;

  /// No description provided for @wsBadTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get wsBadTime;

  /// No description provided for @wsSelector.
  ///
  /// In en, this message translates to:
  /// **'selector'**
  String get wsSelector;

  /// No description provided for @wsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get wsCustom;

  /// No description provided for @wsName.
  ///
  /// In en, this message translates to:
  /// **'Name '**
  String get wsName;

  /// No description provided for @wsBase.
  ///
  /// In en, this message translates to:
  /// **'Base site '**
  String get wsBase;

  /// No description provided for @wsPath.
  ///
  /// In en, this message translates to:
  /// **'Path '**
  String get wsPath;

  /// No description provided for @wsParameter.
  ///
  /// In en, this message translates to:
  /// **'Parameter '**
  String get wsParameter;

  /// No description provided for @wsPlayResponsibly.
  ///
  /// In en, this message translates to:
  /// **'Liminal does minimal validation of these custom inputs.\nPlay at your own risk.'**
  String get wsPlayResponsibly;

  /// No description provided for @wsNonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Need a non-empty name.'**
  String get wsNonEmpty;

  /// No description provided for @wsSameName.
  ///
  /// In en, this message translates to:
  /// **'A custom entry with that name already exists.\nPlease change the name and try again.'**
  String get wsSameName;

  /// No description provided for @wsFF.
  ///
  /// In en, this message translates to:
  /// **'FF/Rewind'**
  String get wsFF;

  /// No description provided for @wsSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip/Prev'**
  String get wsSkip;

  /// No description provided for @wsSomePlayers.
  ///
  /// In en, this message translates to:
  /// **'Note:\nThese buttons only work if the active player supports them. Some music players don\'t have FF/Rewind, for example'**
  String get wsSomePlayers;

  /// No description provided for @ssAppList.
  ///
  /// In en, this message translates to:
  /// **'App list'**
  String get ssAppList;

  /// No description provided for @ssLinkedList.
  ///
  /// In en, this message translates to:
  /// **'Linked home lists'**
  String get ssLinkedList;

  /// No description provided for @ssThemedHome.
  ///
  /// In en, this message translates to:
  /// **'The home list can be theme based too!'**
  String get ssThemedHome;

  /// No description provided for @ssNoBothHome.
  ///
  /// In en, this message translates to:
  /// **'Note: the home ages have no update both system ('**
  String get ssNoBothHome;

  /// No description provided for @ssIndependent.
  ///
  /// In en, this message translates to:
  /// **').\nThe lists will be fully independent.'**
  String get ssIndependent;

  /// No description provided for @ssRelinked.
  ///
  /// In en, this message translates to:
  /// **'If/when re-linked, you will be asked which version to keep.'**
  String get ssRelinked;

  /// No description provided for @ssKeepWhich.
  ///
  /// In en, this message translates to:
  /// **'Keep which layout?'**
  String get ssKeepWhich;

  /// No description provided for @ssHomeRipple.
  ///
  /// In en, this message translates to:
  /// **'Home ripple animation'**
  String get ssHomeRipple;

  /// No description provided for @ssListRipple.
  ///
  /// In en, this message translates to:
  /// **'List ripple animation'**
  String get ssListRipple;

  /// No description provided for @ssAutoSearch.
  ///
  /// In en, this message translates to:
  /// **'Auto-search the apps list'**
  String get ssAutoSearch;

  /// No description provided for @ssQuickLaunch.
  ///
  /// In en, this message translates to:
  /// **'Quick launch'**
  String get ssQuickLaunch;

  /// No description provided for @ssQLDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right on the home screen (except when editing) to open the selected app.\nLong press to clear your selection.'**
  String get ssQLDescription;

  /// No description provided for @ssSwipe.
  ///
  /// In en, this message translates to:
  /// **'{direction} swipe'**
  String ssSwipe(Object direction);

  /// No description provided for @ssSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a quick access app that will open when you swipe {direction} on the home screen. swipe'**
  String ssSwipeDesc(Object direction);

  /// No description provided for @ssSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose app that opens on {direction} swipe'**
  String ssSwipeHint(Object direction);

  /// No description provided for @ssSwipeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selecting {direction} swipe'**
  String ssSwipeLabel(Object direction);

  /// No description provided for @ssSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get ssSecurity;

  /// No description provided for @ssAuthToEdit.
  ///
  /// In en, this message translates to:
  /// **'Auth to edit lists/settings'**
  String get ssAuthToEdit;

  /// No description provided for @ssAuthForHidden.
  ///
  /// In en, this message translates to:
  /// **'Auth to see hidden apps'**
  String get ssAuthForHidden;

  /// No description provided for @ssAuthTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auth timeout (mins)'**
  String get ssAuthTimeout;

  /// No description provided for @ssPositiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Positive integers only'**
  String get ssPositiveOnly;

  /// No description provided for @ssApp.
  ///
  /// In en, this message translates to:
  /// **'Liminal App'**
  String get ssApp;

  /// No description provided for @ssElevatedStyle.
  ///
  /// In en, this message translates to:
  /// **'Elevated style'**
  String get ssElevatedStyle;

  /// No description provided for @ssFolder.
  ///
  /// In en, this message translates to:
  /// **'Liminal Folder'**
  String get ssFolder;

  /// No description provided for @ssLabelType.
  ///
  /// In en, this message translates to:
  /// **'Label type'**
  String get ssLabelType;

  /// No description provided for @ssFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get ssFullName;

  /// No description provided for @ssShowIcon.
  ///
  /// In en, this message translates to:
  /// **'Show icon'**
  String get ssShowIcon;

  /// No description provided for @ssElevatedButton.
  ///
  /// In en, this message translates to:
  /// **'Elevated button'**
  String get ssElevatedButton;

  /// No description provided for @ssTileType.
  ///
  /// In en, this message translates to:
  /// **'{type} tile'**
  String ssTileType(Object type);

  /// No description provided for @ssWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get ssWallpaper;

  /// No description provided for @ssUseOS.
  ///
  /// In en, this message translates to:
  /// **'Use OS'**
  String get ssUseOS;

  /// No description provided for @ssListAlign.
  ///
  /// In en, this message translates to:
  /// **'List alignment'**
  String get ssListAlign;

  /// No description provided for @ssAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Liminal Launcher icon used for alignment preview'**
  String get ssAlignHint;

  /// No description provided for @ssHideStatus.
  ///
  /// In en, this message translates to:
  /// **'Hide status bar'**
  String get ssHideStatus;

  /// No description provided for @ssPages.
  ///
  /// In en, this message translates to:
  /// **'Home screen pages'**
  String get ssPages;
}

class _LangDelegate extends LocalizationsDelegate<Lang> {
  const _LangDelegate();

  @override
  Future<Lang> load(Locale locale) {
    return lookupLang(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fil',
        'fr',
        'hi',
        'ht',
        'ja',
        'ko',
        'ru',
        'sw',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_LangDelegate old) => false;
}

Future<Lang> lookupLang(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'ar':
      {
        switch (locale.countryCode) {
          case 'EG':
            return lang_ar
                .loadLibrary()
                .then((dynamic _) => lang_ar.LangArEg());
        }
        break;
      }
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return lang_en
                .loadLibrary()
                .then((dynamic _) => lang_en.LangEnUs());
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return lang_zh
                .loadLibrary()
                .then((dynamic _) => lang_zh.LangZhCn());
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return lang_ar.loadLibrary().then((dynamic _) => lang_ar.LangAr());
    case 'de':
      return lang_de.loadLibrary().then((dynamic _) => lang_de.LangDe());
    case 'en':
      return lang_en.loadLibrary().then((dynamic _) => lang_en.LangEn());
    case 'es':
      return lang_es.loadLibrary().then((dynamic _) => lang_es.LangEs());
    case 'fil':
      return lang_fil.loadLibrary().then((dynamic _) => lang_fil.LangFil());
    case 'fr':
      return lang_fr.loadLibrary().then((dynamic _) => lang_fr.LangFr());
    case 'hi':
      return lang_hi.loadLibrary().then((dynamic _) => lang_hi.LangHi());
    case 'ht':
      return lang_ht.loadLibrary().then((dynamic _) => lang_ht.LangHt());
    case 'ja':
      return lang_ja.loadLibrary().then((dynamic _) => lang_ja.LangJa());
    case 'ko':
      return lang_ko.loadLibrary().then((dynamic _) => lang_ko.LangKo());
    case 'ru':
      return lang_ru.loadLibrary().then((dynamic _) => lang_ru.LangRu());
    case 'sw':
      return lang_sw.loadLibrary().then((dynamic _) => lang_sw.LangSw());
    case 'uk':
      return lang_uk.loadLibrary().then((dynamic _) => lang_uk.LangUk());
    case 'zh':
      return lang_zh.loadLibrary().then((dynamic _) => lang_zh.LangZh());
  }

  throw FlutterError(
      'Lang.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
