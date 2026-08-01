// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LangRu extends Lang {
  LangRu([String locale = 'ru']) : super(locale);

  @override
  String get gDupe => 'Duplicate';

  @override
  String get gHidden => 'Hidden';

  @override
  String get gButton => 'Button';

  @override
  String get gTile => 'Tile';

  @override
  String get hsHome => 'Home';

  @override
  String get hsWelcome => 'Welcome to Liminal Launcher';

  @override
  String get hsDescription =>
      'It\'s geared toward minimalism,\nbut has limitless customization.';

  @override
  String get hsUserSettings =>
      'Personalization is easy, and everything that needs explanation will have it.\n\nAs a general rule: Liminal\'s appearance can be completely separate based on theme mode!\n\nWhile in the relevant settings, you will see a toggle-able icon that indicates whether you\'re editing the dark ';

  @override
  String get hsLight => ', light ';

  @override
  String get hsBoth => ', or both ';

  @override
  String get hsThemes => ' themes.';

  @override
  String get hsGetStarted =>
      'Long press the home screen to get started.\nThank you, and enjoy!';

  @override
  String get hsOneMore => 'One more thing...';

  @override
  String get hsFree =>
      'This version is not from the Play Store, so it should have been free.\nRest assured, the free version of Liminal will always be identical to the Google Play version.\n\nIf you want to support Liminal\'s development, or the development of more cool software, please consider ';

  @override
  String get hsContribute => 'contributing';

  @override
  String get hsContributeHint => 'Open a link to contribution options';

  @override
  String get hsPopUp =>
      '.\n\nThis is the only non-tutorial pop-up, and its only appearance this install.';

  @override
  String get hsOkay => 'Okay';

  @override
  String get hsApp => 'App';

  @override
  String get hsFolder => 'Folder';

  @override
  String get hsWidget => 'Widget';

  @override
  String get hsSpacer => 'Spacer';

  @override
  String get hsLane => 'Lane';

  @override
  String get hsScreenLanes => ' lanes on screen.';

  @override
  String get hsWithCurr => 'With your current...\n\nicon size (';

  @override
  String get hsPadding => '),\npadding (';

  @override
  String get hsSpacing => '),\n& spacing (';

  @override
  String get hsCanFit => '...values, you can fit up to ';

  @override
  String get hsWithMin => ' With the minimum values, you can fit up to ';

  @override
  String get hsLanes => ' lanes.';

  @override
  String get hsHiddenAuth => 'Authenticate to see hidden apps';

  @override
  String get alSearch => 'Search';

  @override
  String get ssElevated => 'Elevated style';

  @override
  String get ssWallpaper => 'Wallpaper';

  @override
  String get ssUseOS => 'Use OS';

  @override
  String get ssListAlign => 'List alignment';

  @override
  String get ssHideStatus => 'Hide status bar';

  @override
  String get ssPages => 'Home screen pages';
}
