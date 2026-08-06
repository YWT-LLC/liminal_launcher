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

  /// No description provided for @aplDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get aplDate;

  /// No description provided for @aplName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get aplName;

  /// No description provided for @aplPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get aplPublisher;

  /// No description provided for @aplSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get aplSize;

  /// No description provided for @clkBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get clkBackground;

  /// No description provided for @clkBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get clkBackgroundColor;

  /// No description provided for @clkBackgroundShape.
  ///
  /// In en, this message translates to:
  /// **'Background shape'**
  String get clkBackgroundShape;

  /// No description provided for @clkDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get clkDate;

  /// No description provided for @clkDateColor.
  ///
  /// In en, this message translates to:
  /// **'Date color'**
  String get clkDateColor;

  /// No description provided for @clkDateStyle.
  ///
  /// In en, this message translates to:
  /// **'Date style'**
  String get clkDateStyle;

  /// No description provided for @clkDateType.
  ///
  /// In en, this message translates to:
  /// **'Date type'**
  String get clkDateType;

  /// No description provided for @clkCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get clkCompact;

  /// No description provided for @clkLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get clkLong;

  /// No description provided for @clkMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get clkMedium;

  /// No description provided for @clkShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get clkShort;

  /// No description provided for @clkTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get clkTime;

  /// No description provided for @clkTimeBool.
  ///
  /// In en, this message translates to:
  /// **'Show time'**
  String get clkTimeBool;

  /// No description provided for @clkTimeColor.
  ///
  /// In en, this message translates to:
  /// **'Time color'**
  String get clkTimeColor;

  /// No description provided for @clkTimeStyle.
  ///
  /// In en, this message translates to:
  /// **'Time style'**
  String get clkTimeStyle;

  /// No description provided for @dbsTileType.
  ///
  /// In en, this message translates to:
  /// **'{type} tile'**
  String dbsTileType(Object type);

  /// No description provided for @dbsChangeApp.
  ///
  /// In en, this message translates to:
  /// **'Long press to change the app.'**
  String get dbsChangeApp;

  /// No description provided for @dbsApp.
  ///
  /// In en, this message translates to:
  /// **'Liminal App'**
  String get dbsApp;

  /// No description provided for @dbsFolder.
  ///
  /// In en, this message translates to:
  /// **'Liminal Folder'**
  String get dbsFolder;

  /// No description provided for @dbsLabelType.
  ///
  /// In en, this message translates to:
  /// **'Label type'**
  String get dbsLabelType;

  /// No description provided for @dbsInitials.
  ///
  /// In en, this message translates to:
  /// **'Initials'**
  String get dbsInitials;

  /// No description provided for @dbsFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get dbsFull;

  /// No description provided for @dbsWingding.
  ///
  /// In en, this message translates to:
  /// **'Wingding'**
  String get dbsWingding;

  /// No description provided for @dbsElevatedButton.
  ///
  /// In en, this message translates to:
  /// **'Elevated button'**
  String get dbsElevatedButton;

  /// No description provided for @dbsShowIcon.
  ///
  /// In en, this message translates to:
  /// **'Show icon'**
  String get dbsShowIcon;

  /// No description provided for @dbsElevatedStyle.
  ///
  /// In en, this message translates to:
  /// **'Elevated style'**
  String get dbsElevatedStyle;

  /// No description provided for @dpsPageSettings.
  ///
  /// In en, this message translates to:
  /// **'Page settings'**
  String get dpsPageSettings;

  /// No description provided for @dpsWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get dpsWallpaper;

  /// No description provided for @dpsUseOS.
  ///
  /// In en, this message translates to:
  /// **'Use OS'**
  String get dpsUseOS;

  /// No description provided for @dpsAlign.
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get dpsAlign;

  /// No description provided for @dpsListAlign.
  ///
  /// In en, this message translates to:
  /// **'List alignment'**
  String get dpsListAlign;

  /// No description provided for @dpsAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Liminal Launcher icon used for alignment preview'**
  String get dpsAlignHint;

  /// No description provided for @dpsHideStatus.
  ///
  /// In en, this message translates to:
  /// **'Hide status bar'**
  String get dpsHideStatus;

  /// No description provided for @dpsPages.
  ///
  /// In en, this message translates to:
  /// **'Home screen pages'**
  String get dpsPages;

  /// No description provided for @evtAppIcon.
  ///
  /// In en, this message translates to:
  /// **'Use app icon'**
  String get evtAppIcon;

  /// No description provided for @evtCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get evtCalendar;

  /// No description provided for @evtClear.
  ///
  /// In en, this message translates to:
  /// **'Long press to clear'**
  String get evtClear;

  /// No description provided for @evtNewEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get evtNewEvent;

  /// No description provided for @evtNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get evtNewTask;

  /// No description provided for @evtNoCalendar.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find a default calendar app.\nWhat shall I do?\n\n\'Task\' is just share underneath. You\'ll choose a default app to share with.\nWe recommend using a task app, but don\'t require.\nResults may vary.'**
  String get evtNoCalendar;

  /// No description provided for @evtShare.
  ///
  /// In en, this message translates to:
  /// **'\'Task\' is just share underneath.\nChoose a destination app below.\n\nWe recommend using a task app, but it\'s not required. Results may vary.'**
  String get evtShare;

  /// No description provided for @evtShareDest.
  ///
  /// In en, this message translates to:
  /// **'Selecting share destination'**
  String get evtShareDest;

  /// No description provided for @evtTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get evtTask;

  /// No description provided for @evtUseTasks.
  ///
  /// In en, this message translates to:
  /// **'Switch to tasks'**
  String get evtUseTasks;

  /// No description provided for @fldAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get fldAppearance;

  /// No description provided for @fldApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get fldApps;

  /// No description provided for @gAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get gAdd;

  /// No description provided for @gDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get gDefault;

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

  /// No description provided for @gEditDefaults.
  ///
  /// In en, this message translates to:
  /// **'Edit defaults'**
  String get gEditDefaults;

  /// No description provided for @gResize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get gResize;

  /// No description provided for @gReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get gReset;

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

  /// No description provided for @gOutlined.
  ///
  /// In en, this message translates to:
  /// **'Outlined'**
  String get gOutlined;

  /// No description provided for @gSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get gSolid;

  /// No description provided for @gFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get gFailed;

  /// No description provided for @gInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get gInvalid;

  /// No description provided for @gNoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty'**
  String get gNoEmpty;

  /// No description provided for @gNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get gNothing;

  /// No description provided for @gRemoving.
  ///
  /// In en, this message translates to:
  /// **'Removing'**
  String get gRemoving;

  /// No description provided for @gSelfDestruct.
  ///
  /// In en, this message translates to:
  /// **'Self-destruct'**
  String get gSelfDestruct;

  /// No description provided for @gMachineTranslated.
  ///
  /// In en, this message translates to:
  /// **'Everything is machine translated. If you see something wrong, please submit a fix!\n'**
  String get gMachineTranslated;

  /// No description provided for @gTranslations.
  ///
  /// In en, this message translates to:
  /// **'Translations link.'**
  String get gTranslations;

  /// No description provided for @gFix.
  ///
  /// In en, this message translates to:
  /// **'Fix...'**
  String get gFix;

  /// No description provided for @gLauncherEntries.
  ///
  /// In en, this message translates to:
  /// **'Launcher entries'**
  String get gLauncherEntries;

  /// No description provided for @gSettingsEntries.
  ///
  /// In en, this message translates to:
  /// **'Settings entries'**
  String get gSettingsEntries;

  /// No description provided for @gsAppList.
  ///
  /// In en, this message translates to:
  /// **'App list'**
  String get gsAppList;

  /// No description provided for @gsLinkedList.
  ///
  /// In en, this message translates to:
  /// **'Linked home lists'**
  String get gsLinkedList;

  /// No description provided for @gsThemedHome.
  ///
  /// In en, this message translates to:
  /// **'The home list can be theme based too!'**
  String get gsThemedHome;

  /// No description provided for @gsNoBothHome.
  ///
  /// In en, this message translates to:
  /// **'Note: the home ages have no update both system ('**
  String get gsNoBothHome;

  /// No description provided for @gsIndependent.
  ///
  /// In en, this message translates to:
  /// **').\nThe lists will be fully independent.'**
  String get gsIndependent;

  /// No description provided for @gsRelinked.
  ///
  /// In en, this message translates to:
  /// **'If/when re-linked, you will be asked which version to keep.'**
  String get gsRelinked;

  /// No description provided for @gsKeepWhich.
  ///
  /// In en, this message translates to:
  /// **'Keep which layout?'**
  String get gsKeepWhich;

  /// No description provided for @gsAutoSearch.
  ///
  /// In en, this message translates to:
  /// **'Auto-search the apps list'**
  String get gsAutoSearch;

  /// No description provided for @gsHomeRipple.
  ///
  /// In en, this message translates to:
  /// **'Home ripple animation'**
  String get gsHomeRipple;

  /// No description provided for @gsListRipple.
  ///
  /// In en, this message translates to:
  /// **'List ripple animation'**
  String get gsListRipple;

  /// No description provided for @gsQuickLaunch.
  ///
  /// In en, this message translates to:
  /// **'Quick launch'**
  String get gsQuickLaunch;

  /// No description provided for @gsQLDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right on the home screen (except when editing) to open the selected app.\nLong press to clear your selection.'**
  String get gsQLDescription;

  /// No description provided for @gsSwipe.
  ///
  /// In en, this message translates to:
  /// **'{direction} swipe'**
  String gsSwipe(Object direction);

  /// No description provided for @gsSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a quick access app that will open when you swipe {direction} on the home screen. swipe'**
  String gsSwipeDesc(Object direction);

  /// No description provided for @gsSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose app that opens on {direction} swipe'**
  String gsSwipeHint(Object direction);

  /// No description provided for @gsSwipeLabel.
  ///
  /// In en, this message translates to:
  /// **'Selecting {direction} swipe'**
  String gsSwipeLabel(Object direction);

  /// No description provided for @gsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get gsSecurity;

  /// No description provided for @gsAuthToEdit.
  ///
  /// In en, this message translates to:
  /// **'Auth to edit lists/settings'**
  String get gsAuthToEdit;

  /// No description provided for @gsAuthForHidden.
  ///
  /// In en, this message translates to:
  /// **'Auth to see hidden apps'**
  String get gsAuthForHidden;

  /// No description provided for @gsAuthTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auth timeout (mins)'**
  String get gsAuthTimeout;

  /// No description provided for @gsPositiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Positive integers only'**
  String get gsPositiveOnly;

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

  /// No description provided for @hsEditAuth.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to edit the launcher'**
  String get hsEditAuth;

  /// No description provided for @hsHiddenAuth.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to see hidden apps'**
  String get hsHiddenAuth;

  /// No description provided for @mcIconButton.
  ///
  /// In en, this message translates to:
  /// **'Icon button size'**
  String get mcIconButton;

  /// No description provided for @mcBanish.
  ///
  /// In en, this message translates to:
  /// **'Banish'**
  String get mcBanish;

  /// No description provided for @mcDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mcDelete;

  /// No description provided for @mcDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mcDone;

  /// No description provided for @mcHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get mcHide;

  /// No description provided for @mcInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get mcInfo;

  /// No description provided for @mcMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get mcMove;

  /// No description provided for @mcRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mcRemove;

  /// No description provided for @mcSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mcSave;

  /// No description provided for @mcShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get mcShow;

  /// No description provided for @mcUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get mcUninstall;

  /// No description provided for @mltLaneConfig.
  ///
  /// In en, this message translates to:
  /// **'Multi-lane configuration'**
  String get mltLaneConfig;

  /// No description provided for @mltPagesEnabled.
  ///
  /// In en, this message translates to:
  /// **'With pages enabled, lanes behave like pages on a traditional launcher.\n'**
  String get mltPagesEnabled;

  /// No description provided for @mltPagesDisabled.
  ///
  /// In en, this message translates to:
  /// **'With pages disabled, all lanes share one horizontal scroll.\n'**
  String get mltPagesDisabled;

  /// No description provided for @mltWideEnabled.
  ///
  /// In en, this message translates to:
  /// **'With wide tiles enabled...\n'**
  String get mltWideEnabled;

  /// No description provided for @mltWideWidth.
  ///
  /// In en, this message translates to:
  /// **'each lane (with an item) will be the width of one screen.\n'**
  String get mltWideWidth;

  /// No description provided for @mltAnywhere.
  ///
  /// In en, this message translates to:
  /// **'apps and folders can/will be activated anywhere in their horizontal space.\n'**
  String get mltAnywhere;

  /// No description provided for @mltWideDisabled.
  ///
  /// In en, this message translates to:
  /// **'With wide tiles disabled...\n'**
  String get mltWideDisabled;

  /// No description provided for @mltAutoWidth.
  ///
  /// In en, this message translates to:
  /// **'lanes will be sized by their widest item & your spacing setting.\n'**
  String get mltAutoWidth;

  /// No description provided for @mltOnlyButton.
  ///
  /// In en, this message translates to:
  /// **'apps and folders can/will be activated only by their button(s).\n'**
  String get mltOnlyButton;

  /// No description provided for @pHiddenReminder.
  ///
  /// In en, this message translates to:
  /// **'Swipe up while editing to open the hidden apps list.'**
  String get pHiddenReminder;

  /// No description provided for @pReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get pReminder;

  /// No description provided for @pBanishApp.
  ///
  /// In en, this message translates to:
  /// **'Banish {app}?'**
  String pBanishApp(Object app);

  /// No description provided for @pRemoveLane.
  ///
  /// In en, this message translates to:
  /// **'Remove {lane}?'**
  String pRemoveLane(Object lane);

  /// No description provided for @pWantTo.
  ///
  /// In en, this message translates to:
  /// **'Want to...'**
  String get pWantTo;

  /// No description provided for @pHideDarkToo.
  ///
  /// In en, this message translates to:
  /// **'Hide for dark mode too?'**
  String get pHideDarkToo;

  /// No description provided for @pHideLightToo.
  ///
  /// In en, this message translates to:
  /// **'Hide for light mode too?'**
  String get pHideLightToo;

  /// No description provided for @pShowDarkToo.
  ///
  /// In en, this message translates to:
  /// **'Show for dark mode too?'**
  String get pShowDarkToo;

  /// No description provided for @pShowLightToo.
  ///
  /// In en, this message translates to:
  /// **'Show for light mode too?'**
  String get pShowLightToo;

  /// No description provided for @pWhatBanish.
  ///
  /// In en, this message translates to:
  /// **'When you banish an app, it will still be installed but not appear in Liminal at all.\nBanished apps can only be opened from the system settings, or via app link.\n\nBanishing is useful for utility apps that also waste time. For example, you may want to banish your web browser(s).\nThat way, you can use online menus when you go out, and reduce doom scrolling when you stay in.\n\n{undo}\n\nReminder: banishing is just for UX, not for security.\nFor example: if an app has always on location permissions, banishing it will not affect that.'**
  String pWhatBanish(Object undo);

  /// No description provided for @pUnBanish.
  ///
  /// In en, this message translates to:
  /// **'The simplest wat to restore/un-banish {app} is to uninstall it from the system settings, then reinstall.'**
  String pUnBanish(Object app);

  /// No description provided for @srcCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get srcCustom;

  /// No description provided for @srcName.
  ///
  /// In en, this message translates to:
  /// **'Name '**
  String get srcName;

  /// No description provided for @srcBase.
  ///
  /// In en, this message translates to:
  /// **'Base site '**
  String get srcBase;

  /// No description provided for @srcPath.
  ///
  /// In en, this message translates to:
  /// **'Path '**
  String get srcPath;

  /// No description provided for @srcParameter.
  ///
  /// In en, this message translates to:
  /// **'Parameter '**
  String get srcParameter;

  /// No description provided for @srcNonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Need a non-empty name.'**
  String get srcNonEmpty;

  /// No description provided for @srcPlayResponsibly.
  ///
  /// In en, this message translates to:
  /// **'Liminal does minimal validation of these custom inputs.\nPlay at your own risk.'**
  String get srcPlayResponsibly;

  /// No description provided for @srcSameName.
  ///
  /// In en, this message translates to:
  /// **'A custom entry with that name already exists.\nPlease change the name and try again.'**
  String get srcSameName;

  /// No description provided for @thmSelector.
  ///
  /// In en, this message translates to:
  /// **'selector'**
  String get thmSelector;

  /// No description provided for @timBadTime.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get timBadTime;

  /// No description provided for @togFF.
  ///
  /// In en, this message translates to:
  /// **'FF/Rewind'**
  String get togFF;

  /// No description provided for @togSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip/Prev'**
  String get togSkip;

  /// No description provided for @togSomePlayers.
  ///
  /// In en, this message translates to:
  /// **'Note:\nThese buttons only work if the active player supports them. Some music players don\'t have FF/Rewind, for example'**
  String get togSomePlayers;
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
