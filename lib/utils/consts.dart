/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

//* App config *//

/// Liminal Launcher
const String appName = 'Liminal Launcher';

/// net.empathetech.liminal
const String androidPackage = 'net.empathetech.liminal';

/// Liminal Launcher [AppInfo]
final AppInfo self = AppInfo(
  label: appName,
  package: androidPackage,
  removable: false,
  installDate: 0,
  packageSize: 0,
);

//* App assets *//

/// assets/images/app-icon.jpg
const String appIconPath = 'assets/images/app-icon.jpg';

/// [appIconPath]
const Set<String> assetPaths = <String>{appIconPath};

/// Credits for...
/// [appIconPath]
const Map<String, String> credits = <String, String>{
  appIconPath: 'AI; tis a placeholder, human work coming soon.',
};

//* EzConfig *//

// BTS //

const String shownIntroKey = 'shownIntro';
const String lastAuthKey = 'lastAuth';

const String renamedIDsKey = 'renamedIDs';
const String homeIDsKey = 'homeIDs';
const String hiddenIDsKey = 'hiddenIDs';
const String banishedIDsKey = 'banishedIDs';

const String ascListKey = 'ascList';
const String listSortKey = 'listSort';

/// Intro, ID lists, and sorting keys
const Map<String, Type> limBTSKeys = <String, Type>{
  // Intro
  shownIntroKey: bool,
  lastAuthKey: String,

  renamedIDsKey: List<String>,
  homeIDsKey: List<String>,
  hiddenIDsKey: List<String>,
  banishedIDsKey: List<String>,

  // List(s) sort
  ascListKey: bool,
  listSortKey: String,
};

// Launcher //

const String darkHideStatusKey = 'darkHideStatus';
const String darkHomeTimeKey = 'darkHomeTime';
const String darkHomeDateKey = 'darkHomeDate';
const String lightHideStatusKey = 'lightHideStatus';
const String lightHomeTimeKey = 'lightHomeTime';
const String lightHomeDateKey = 'lightHomeDate';

const String darkLeftSwipeIDKey = 'darkLeftSwipeID';
const String darkRightSwipeIDKey = 'darkRightSwipeID';
const String lightLeftSwipeIDKey = 'lightLeftSwipeID';
const String lightRightSwipeIDKey = 'lightRightSwipeID';

const String darkWideTilesKey = 'darkWideTiles';
const String lightWideTilesKey = 'lightWideTiles';

const String autoAddToHomeKey = 'autoAddToHome';
const String autoSearchKey = 'autoSearch';

const String authToEditKey = 'authToEdit';
const String authForHiddenKey = 'authForHiddenKey';
const String authTimeoutKey = 'authTimeout';

/// Header, quick launch, and app list settings
const Map<String, Type> limLauncherKeys = <String, Type>{
  // Header
  darkHideStatusKey: bool,
  darkHomeTimeKey: bool,
  darkHomeDateKey: String,
  lightHideStatusKey: bool,
  lightHomeTimeKey: bool,
  lightHomeDateKey: String,

  // Quick launch
  darkLeftSwipeIDKey: String,
  darkRightSwipeIDKey: String,
  lightLeftSwipeIDKey: String,
  lightRightSwipeIDKey: String,

  // App list (themed)
  darkWideTilesKey: bool,
  lightWideTilesKey: bool,

  // App list (global)
  autoAddToHomeKey: bool,
  autoSearchKey: bool,
  authToEditKey: bool,
  authForHiddenKey: bool,
  authTimeoutKey: int,
};

// Design //

const String darkUseOSKey = 'darkUseOS';
const String lightUseOSKey = 'lightUseOS';

const String darkListLabelTypeKey = 'darkListLabelType';
const String darkListIconKey = 'darkListIcon';
const String lightListLabelTypeKey = 'lightListLabelType';
const String lightListIconKey = 'lightListIcon';

const String darkFolderLabelTypeKey = 'darkFolderLabelType';
const String darkFolderIconKey = 'darkFolderIcon';
const String lightFolderLabelTypeKey = 'lightFolderLabelType';
const String lightFolderIconKey = 'lightFolderIcon';

/// Wallpaper and app tile settings
const Map<String, Type> limDesignKeys = <String, Type>{
  // Wallpaper
  darkUseOSKey: bool,
  lightUseOSKey: bool,

  // App
  darkListLabelTypeKey: String,
  darkListIconKey: bool,
  lightListLabelTypeKey: String,
  lightListIconKey: bool,

  // Folder
  darkFolderLabelTypeKey: String,
  darkFolderIconKey: bool,
  lightFolderLabelTypeKey: String,
  lightFolderIconKey: bool,
};

// Layout //

const String darkHorizontalAlignKey = 'darkHorizontalAlign';
const String darkVerticalAlignKey = 'darkVerticalAlign';
const String lightHorizontalAlignKey = 'lightHorizontalAlign';
const String lightVerticalAlignKey = 'lightVerticalAlign';

/// List/page alignment keys
const Map<String, Type> limLayoutKeys = <String, Type>{
  darkHorizontalAlignKey: String,
  darkVerticalAlignKey: String,
  lightHorizontalAlignKey: String,
  lightVerticalAlignKey: String,
};

// Shared //

/// [allEZConfigKeys], [limBTSKeys], [limDesignKeys], [limLauncherKeys], [limLayoutKeys]
const Map<String, Type> allLimKeys = <String, Type>{
  ...allEZConfigKeys,
  ...limBTSKeys,
  ...limLauncherKeys,
  ...limDesignKeys,
  ...limLayoutKeys,
};

/// Keys that should be preserved from [EzConfig.reset] by default
final Set<String> defaultNoResetKeys = <String>{
  ...limBTSKeys.keys,
  ...limLauncherKeys.keys,
};

/// [EzConfig] keys that should never b reset/only changed by the user
const Set<String> neverResetKeys = <String>{
  appLocaleKey,
  shownIntroKey,
  lastAuthKey,
};

/// [empathMobileConfig] with Liminal additions
final Map<String, Object> liminalDefault = <String, Object>{
  ...empathMobileConfig,

  // BTS //

  // For dev
  shownIntroKey: false,
  lastAuthKey: '',

  // ID lists
  renamedIDsKey: <String>[],
  homeIDsKey: <String>[],
  hiddenIDsKey: <String>[],
  banishedIDsKey: <String>[],

  // List(s) sort
  ascListKey: true,
  listSortKey: AppSort.name.value,

  // Launcher //

  // Header
  darkHideStatusKey: false,
  darkHomeTimeKey: true,
  darkHomeDateKey: DateType.medium.value,
  lightHideStatusKey: false,
  lightHomeTimeKey: true,
  lightHomeDateKey: DateType.compact.value,

  // Quick launch
  darkLeftSwipeIDKey: '',
  darkRightSwipeIDKey: '',
  lightLeftSwipeIDKey: '',
  lightRightSwipeIDKey: '',

  // App list (themed)
  darkWideTilesKey: false,
  lightWideTilesKey: false,

  // App list (global)
  autoAddToHomeKey: false,
  autoSearchKey: false,
  authToEditKey: false,
  authForHiddenKey: false,
  authTimeoutKey: 5,

  // Design //

  darkUseOSKey: true,
  lightUseOSKey: true,

  darkListLabelTypeKey: LabelType.full.value,
  darkListIconKey: false,
  lightListLabelTypeKey: LabelType.full.value,
  lightListIconKey: true,

  darkFolderLabelTypeKey: LabelType.initials.value,
  darkFolderIconKey: false,
  lightFolderLabelTypeKey: LabelType.none.value,
  lightFolderIconKey: true,

  // Layout //

  darkHorizontalAlignKey: ListAlignment.center.value,
  darkVerticalAlignKey: ListAlignment.start.value,
  lightHorizontalAlignKey: ListAlignment.center.value,
  lightVerticalAlignKey: ListAlignment.start.value,
};

//* Custom fonts *//

/// wingding
const String wingding = 'Wingding';

const Map<String, String> wingdingMap = <String, String>{
  // Lowercase
  'a': '\u{264B}',
  'b': '\u{264C}',
  'c': '\u{264D}',
  'd': '\u{264E}',
  'e': '\u{264F}',
  'f': '\u{2650}',
  'g': '\u{2651}',
  'h': '\u{2652}',
  'i': '\u{2653}',
  'j': '\u{1F670}',
  'k': '\u{1F675}',
  'l': '\u{25CF}',
  'm': '\u{1F53E}',
  'n': '\u{25A0}',
  'o': '\u{25A1}',
  'p': '\u{1F790}',
  'q': '\u{2751}',
  'r': '\u{2752}',
  's': '\u{2B27}',
  't': '\u{29EB}',
  'u': '\u{25C6}',
  'v': '\u{2756}',
  'w': '\u{2B25}',
  'x': '\u{2327}',
  'y': '\u{2BB9}',
  'z': '\u{2318}',

  // Uppercase
  'A': '\u{270C}',
  'B': '\u{1F44C}',
  'C': '\u{1F44D}',
  'D': '\u{1F44E}',
  'E': '\u{261C}',
  'F': '\u{261E}',
  'G': '\u{261D}',
  'H': '\u{261F}',
  'I': '\u{1F590}',
  'J': '\u{263A}',
  'K': '\u{1F610}',
  'L': '\u{2639}',
  'M': '\u{1F4A3}',
  'N': '\u{2620}',
  'O': '\u{1F3F3}',
  'P': '\u{1F3F1}',
  'Q': '\u{2708}',
  'R': '\u{263C}',
  'S': '\u{1F4A7}',
  'T': '\u{2744}',
  'U': '\u{1F546}',
  'V': '\u{271E}',
  'W': '\u{1F548}',
  'X': '\u{2720}',
  'Y': '\u{2721}',
  'Z': '\u{262A}',
};
