// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Haitian Haitian Creole (`ht`).
class LangHt extends Lang {
  LangHt([String locale = 'ht']) : super(locale);

  @override
  String get aplDate => 'Date';

  @override
  String get aplName => 'Name';

  @override
  String get aplPublisher => 'Publisher';

  @override
  String get aplSize => 'Size';

  @override
  String get clkBackground => 'Background';

  @override
  String get clkBackgroundColor => 'Background color';

  @override
  String get clkBackgroundShape => 'Background shape';

  @override
  String get clkDate => 'Date';

  @override
  String get clkDateColor => 'Date color';

  @override
  String get clkDateStyle => 'Date style';

  @override
  String get clkDateType => 'Date type';

  @override
  String get clkCompact => 'Compact';

  @override
  String get clkLong => 'Long';

  @override
  String get clkMedium => 'Medium';

  @override
  String get clkShort => 'Short';

  @override
  String get clkTime => 'Time';

  @override
  String get clkTimeBool => 'Show time';

  @override
  String get clkTimeColor => 'Time color';

  @override
  String get clkTimeStyle => 'Time style';

  @override
  String dbsTileType(Object type) {
    return '$type tile';
  }

  @override
  String get dbsChangeApp => 'Long press to change the app.';

  @override
  String get dbsApp => 'Liminal App';

  @override
  String get dbsFolder => 'Liminal Folder';

  @override
  String get dbsLabelType => 'Label type';

  @override
  String get dbsInitials => 'Initials';

  @override
  String get dbsFull => 'Full';

  @override
  String get dbsWingding => 'Wingding';

  @override
  String get dbsElevatedButton => 'Elevated button';

  @override
  String get dbsShowIcon => 'Show icon';

  @override
  String get dbsElevatedStyle => 'Elevated style';

  @override
  String get dpsPageSettings => 'Page settings';

  @override
  String get dpsWallpaper => 'Wallpaper';

  @override
  String get dpsUseOS => 'Use OS';

  @override
  String get dpsAlign => 'Align';

  @override
  String get dpsListAlign => 'List alignment';

  @override
  String get dpsAlignHint => 'Liminal Launcher icon used for alignment preview';

  @override
  String get dpsHideStatus => 'Hide status bar';

  @override
  String get dpsPages => 'Home screen pages';

  @override
  String get evtAppIcon => 'Use app icon';

  @override
  String get evtCalendar => 'Calendar';

  @override
  String get evtClear => 'Long press to clear';

  @override
  String get evtNewEvent => 'New event';

  @override
  String get evtNewTask => 'New task';

  @override
  String get evtNoCalendar =>
      'Can\'t find a default calendar app.\nWhat shall I do?\n\n\'Task\' is just share underneath. You\'ll choose a default app to share with.\nWe recommend using a task app, but don\'t require.\nResults may vary.';

  @override
  String get evtShare =>
      '\'Task\' is just share underneath.\nChoose a destination app below.\n\nWe recommend using a task app, but it\'s not required. Results may vary.';

  @override
  String get evtShareDest => 'Selecting share destination';

  @override
  String get evtTask => 'Task';

  @override
  String get evtUseTasks => 'Switch to tasks';

  @override
  String get fldAppearance => 'Appearance';

  @override
  String get fldApps => 'Apps';

  @override
  String get gAdd => 'Add';

  @override
  String get gDefault => 'Default';

  @override
  String get gDupe => 'Duplicate';

  @override
  String get gEdit => 'Edit';

  @override
  String get gEditDefaults => 'Edit defaults';

  @override
  String get gResize => 'Resize';

  @override
  String get gReset => 'Reset';

  @override
  String get gButton => 'Button';

  @override
  String get gTile => 'Tile';

  @override
  String get gWideTiles => 'Wide tiles';

  @override
  String get gSearch => 'Search';

  @override
  String get gSearchBar => 'Search bar';

  @override
  String get gEnd => 'End';

  @override
  String get gCenter => 'Center';

  @override
  String get gStart => 'Start';

  @override
  String get gHidden => 'Hidden';

  @override
  String get gShared => 'Shared';

  @override
  String get gShown => 'Shown';

  @override
  String get gOutlined => 'Outlined';

  @override
  String get gSolid => 'Solid';

  @override
  String get gFailed => 'Failed';

  @override
  String get gInvalid => 'Invalid';

  @override
  String get gNoEmpty => 'Cannot be empty';

  @override
  String get gNothing => 'Nothing';

  @override
  String get gRemoving => 'Removing';

  @override
  String get gSelfDestruct => 'Self-destruct';

  @override
  String get gsAppList => 'App list';

  @override
  String get gsLinkedList => 'Linked home lists';

  @override
  String get gsThemedHome => 'The home list can be theme based too!';

  @override
  String get gsNoBothHome => 'Note: the home ages have no update both system (';

  @override
  String get gsIndependent => ').\nThe lists will be fully independent.';

  @override
  String get gsRelinked =>
      'If/when re-linked, you will be asked which version to keep.';

  @override
  String get gsKeepWhich => 'Keep which layout?';

  @override
  String get gsAutoSearch => 'Auto-search the apps list';

  @override
  String get gsHomeRipple => 'Home ripple animation';

  @override
  String get gsListRipple => 'List ripple animation';

  @override
  String get gsQuickLaunch => 'Quick launch';

  @override
  String get gsQLDescription =>
      'Swipe left/right on the home screen (except when editing) to open the selected app.\nLong press to clear your selection.';

  @override
  String gsSwipe(Object direction) {
    return '$direction swipe';
  }

  @override
  String gsSwipeDesc(Object direction) {
    return 'Choose a quick access app that will open when you swipe $direction on the home screen. swipe';
  }

  @override
  String gsSwipeHint(Object direction) {
    return 'Choose app that opens on $direction swipe';
  }

  @override
  String gsSwipeLabel(Object direction) {
    return 'Selecting $direction swipe';
  }

  @override
  String get gsSecurity => 'Security';

  @override
  String get gsAuthToEdit => 'Auth to edit lists/settings';

  @override
  String get gsAuthForHidden => 'Auth to see hidden apps';

  @override
  String get gsAuthTimeout => 'Auth timeout (mins)';

  @override
  String get gsPositiveOnly => 'Positive integers only';

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
  String get hsLane => 'Lane';

  @override
  String get hsSpacer => 'Spacer';

  @override
  String get hsWidget => 'Widget';

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
  String get hsEditAuth => 'Authenticate to edit the launcher';

  @override
  String get hsHiddenAuth => 'Authenticate to see hidden apps';

  @override
  String get mcIconButton => 'Icon button size';

  @override
  String get mcBanish => 'Banish';

  @override
  String get mcDelete => 'Delete';

  @override
  String get mcDone => 'Done';

  @override
  String get mcHide => 'Hide';

  @override
  String get mcInfo => 'Info';

  @override
  String get mcMove => 'Move';

  @override
  String get mcRemove => 'Remove';

  @override
  String get mcSave => 'Save';

  @override
  String get mcShow => 'Show';

  @override
  String get mcUninstall => 'Uninstall';

  @override
  String get mltLaneConfig => 'Multi-lane configuration';

  @override
  String get mltPagesEnabled =>
      'With pages enabled, lanes behave like pages on a traditional launcher.\n';

  @override
  String get mltPagesDisabled =>
      'With pages disabled, all lanes share one horizontal scroll.\n';

  @override
  String get mltWideEnabled => 'With wide tiles enabled...\n';

  @override
  String get mltWideWidth =>
      'each lane (with an item) will be the width of one screen.\n';

  @override
  String get mltAnywhere =>
      'apps and folders can/will be activated anywhere in their horizontal space.\n';

  @override
  String get mltWideDisabled => 'With wide tiles disabled...\n';

  @override
  String get mltAutoWidth =>
      'lanes will be sized by their widest item & your spacing setting.\n';

  @override
  String get mltOnlyButton =>
      'apps and folders can/will be activated only by their button(s).\n';

  @override
  String get pHiddenReminder =>
      'Swipe up while editing to open the hidden apps list.';

  @override
  String get pReminder => 'Reminder';

  @override
  String pBanishApp(Object app) {
    return 'Banish $app?';
  }

  @override
  String pRemoveLane(Object lane) {
    return 'Remove $lane?';
  }

  @override
  String get pWantTo => 'Want to...';

  @override
  String get pHideDarkToo => 'Hide for dark mode too?';

  @override
  String get pHideLightToo => 'Hide for light mode too?';

  @override
  String get pShowDarkToo => 'Show for dark mode too?';

  @override
  String get pShowLightToo => 'Show for light mode too?';

  @override
  String pWhatBanish(Object undo) {
    return 'When you banish an app, it will still be installed but not appear in Liminal at all.\nBanished apps can only be opened from the system settings, or via app link.\n\nBanishing is useful for utility apps that also waste time. For example, you may want to banish your web browser(s).\nThat way, you can use online menus when you go out, and reduce doom scrolling when you stay in.\n\n$undo\n\nReminder: banishing is just for UX, not for security.\nFor example: if an app has always on location permissions, banishing it will not affect that.';
  }

  @override
  String pUnBanish(Object app) {
    return 'The simplest wat to restore/un-banish $app is to uninstall it from the system settings, then reinstall.';
  }

  @override
  String get srcCustom => 'Custom';

  @override
  String get srcName => 'Name ';

  @override
  String get srcBase => 'Base site ';

  @override
  String get srcPath => 'Path ';

  @override
  String get srcParameter => 'Parameter ';

  @override
  String get srcNonEmpty => 'Need a non-empty name.';

  @override
  String get srcPlayResponsibly =>
      'Liminal does minimal validation of these custom inputs.\nPlay at your own risk.';

  @override
  String get srcSameName =>
      'A custom entry with that name already exists.\nPlease change the name and try again.';

  @override
  String get thmSelector => 'selector';

  @override
  String get timBadTime => 'Invalid time';

  @override
  String get togFF => 'FF/Rewind';

  @override
  String get togSkip => 'Skip/Prev';

  @override
  String get togSomePlayers =>
      'Note:\nThese buttons only work if the active player supports them. Some music players don\'t have FF/Rewind, for example';
}
