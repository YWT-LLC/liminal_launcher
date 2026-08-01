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

  /// No description provided for @gDupe.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get gDupe;

  /// No description provided for @gHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get gHidden;

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

  /// No description provided for @hsWidget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get hsWidget;

  /// No description provided for @hsSpacer.
  ///
  /// In en, this message translates to:
  /// **'Spacer'**
  String get hsSpacer;

  /// No description provided for @hsLane.
  ///
  /// In en, this message translates to:
  /// **'Lane'**
  String get hsLane;

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

  /// No description provided for @alSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get alSearch;

  /// No description provided for @ssElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated style'**
  String get ssElevated;

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
