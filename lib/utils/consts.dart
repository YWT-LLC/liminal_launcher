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

const String ascListKey = 'asc_list';
const String hiddenIDsKey = 'hidden_ids';
const String homeIDsKey = 'home_ids';
const String listSortKey = 'list_sort';
const String renamedIDsKey = 'renamed_ids';
const String shownReminderKey = 'shown_reminder';

/// Home/app list keys
const Map<String, Type> limBTSKeys = <String, Type>{
  ascListKey: bool,
  hiddenIDsKey: List<String>,
  homeIDsKey: List<String>,
  listSortKey: String,
  renamedIDsKey: List<String>,
  shownReminderKey: bool,
};

// Design //

const String wideTilesKey = 'wide_tiles';

const String darkHomeTimeKey = 'dark_home_time';
const String darkHomeDateKey = 'dark_home_date';
const String darkListIconKey = 'dark_list_icon';
const String darkListLabelTypeKey = 'dark_list_label_type';
const String darkFolderIconKey = 'dark_folder_icon';
const String darkFolderLabelTypeKey = 'dark_folder_label_type';
const String darkUseOSKey = 'dark_use_os';

const String lightHomeTimeKey = 'light_home_time';
const String lightHomeDateKey = 'light_home_date';
const String lightListIconKey = 'light_list_icon';
const String lightListLabelTypeKey = 'light_list_label_type';
const String lightFolderIconKey = 'light_folder_icon';
const String lightFolderLabelTypeKey = 'light_folder_label_type';
const String lightUseOSKey = 'light_use_os';

/// Clock keys,
const Map<String, Type> limDesignKeys = <String, Type>{
  wideTilesKey: bool,
  darkHomeTimeKey: bool,
  darkHomeDateKey: String,
  darkListIconKey: bool,
  darkListLabelTypeKey: String,
  darkFolderIconKey: bool,
  darkFolderLabelTypeKey: String,
  darkUseOSKey: bool,
  lightHomeTimeKey: bool,
  lightHomeDateKey: String,
  lightListIconKey: bool,
  lightListLabelTypeKey: String,
  lightFolderIconKey: bool,
  lightFolderLabelTypeKey: String,
  lightUseOSKey: bool,
};

// Launcher //

const String leftSwipeIDKey = 'left_swipe_id';
const String rightSwipeIDKey = 'right_swipe_id';
const String hideStatusKey = 'hide_status';
const String autoAddToHomeKey = 'auto_add_to_home';
const String autoSearchKey = 'auto_search';
const String authToEditKey = 'auth_to_edit';
const String authForHiddenKey = 'auth_for_hidden';

/// Left/right swipe, auth, hide status, and auto add/search keys
const Map<String, Type> limLauncherKeys = <String, Type>{
  leftSwipeIDKey: String,
  rightSwipeIDKey: String,
  hideStatusKey: bool,
  autoAddToHomeKey: bool,
  autoSearchKey: bool,
  authToEditKey: bool,
  authForHiddenKey: bool,
};

// Layout //

const String darkHomeHAlignKey = 'dark_home_horizontal_alignment';
const String darkHomeVAlignKey = 'dark_home_vertical_alignment';
const String darkListHAlignKey = 'dark_list_horizontal_alignment';
const String darkListVAlignKey = 'dark_list_vertical_alignment';

const String lightHomeHAlignKey = 'light_home_horizontal_alignment';
const String lightHomeVAlignKey = 'light_home_vertical_alignment';
const String lightListHAlignKey = 'light_list_horizontal_alignment';
const String lightListVAlignKey = 'light_list_vertical_alignment';

/// Home and list alignment keys
const Map<String, Type> limLayoutKeys = <String, Type>{
  darkHomeHAlignKey: String,
  darkHomeVAlignKey: String,
  darkListHAlignKey: String,
  darkListVAlignKey: String,
  lightHomeHAlignKey: String,
  lightHomeVAlignKey: String,
  lightListHAlignKey: String,
  lightListVAlignKey: String,
};

// Shared //

/// [allEZConfigKeys], [limBTSKeys], [limDesignKeys], [limLauncherKeys], [limLayoutKeys]
const Map<String, Type> allLimKeys = <String, Type>{
  ...allEZConfigKeys,
  ...limBTSKeys,
  ...limDesignKeys,
  ...limLauncherKeys,
  ...limLayoutKeys,
};

/// Keys that should be preserved from [EzConfig.reset] by default
final Set<String> defaultNoResetKeys = <String>{
  ...limBTSKeys.keys,
  ...limLauncherKeys.keys,
};

/// [EzConfig] keys that should never b reset/only changed by the user
const Set<String> neverResetKeys = <String>{
  shownReminderKey,
};

/// [empathMobileConfig] with Liminal additions
final Map<String, Object> liminalDefault = <String, Object>{
  ...empathMobileConfig,

  // BTS
  homeIDsKey: <String>[],
  hiddenIDsKey: <String>[],
  renamedIDsKey: <String>[],
  listSortKey: AppSort.name.configValue,
  ascListKey: true,
  shownReminderKey: false,

  // Design
  wideTilesKey: true,

  darkHomeTimeKey: true,
  darkHomeDateKey: DateType.medium.configValue,
  darkListIconKey: false,
  darkListLabelTypeKey: LabelType.full.configValue,
  darkFolderIconKey: false,
  darkFolderLabelTypeKey: LabelType.initials.configValue,
  darkUseOSKey: true,

  lightHomeTimeKey: true,
  lightHomeDateKey: DateType.compact.configValue,
  lightListIconKey: true,
  lightListLabelTypeKey: LabelType.full.configValue,
  lightFolderIconKey: true,
  lightFolderLabelTypeKey: LabelType.none.configValue,
  lightUseOSKey: true,

  // Launcher
  leftSwipeIDKey: '',
  rightSwipeIDKey: '',
  authToEditKey: false,
  authForHiddenKey: false,
  hideStatusKey: true,
  autoAddToHomeKey: false,
  autoSearchKey: false,

  // Layout
  darkHomeHAlignKey: ListAlignment.center.configValue,
  darkHomeVAlignKey: ListAlignment.start.configValue,
  darkListHAlignKey: ListAlignment.center.configValue,
  darkListVAlignKey: ListAlignment.start.configValue,

  lightHomeHAlignKey: ListAlignment.center.configValue,
  lightHomeVAlignKey: ListAlignment.start.configValue,
  lightListHAlignKey: ListAlignment.center.configValue,
  lightListVAlignKey: ListAlignment.start.configValue,
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
