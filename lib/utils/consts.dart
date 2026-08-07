/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

//* App config *//

/// Liminal Launcher
const String appName = 'Liminal Launcher';

/// llc.ywt.liminal
const String androidPackage = 'llc.ywt.liminal';

/// Liminal Launcher [AppInfo]
final AppInfo self = AppInfo(
  label: appName,
  package: androidPackage,
  removable: false,
  installDate: 0,
  packageSize: 0,
);

/// Delay for home screen navigation when reaching the edge of a list
const Duration scrollDelay = Duration(milliseconds: 200);

//* App assets *//

/// assets/app-icon.png
const String appIconPath = 'assets/app-icon.png';

/// [appIconPath]
const Set<String> assetPaths = <String>{appIconPath};

/// Credits for...
/// [appIconPath]
const Map<String, String> credits = <String, String>{
  appIconPath: 'https://www.pexels.com/@klub-boks-1437055/',
};

//* EzConfig *//

// BTS //

const String darkHomeDataKey = 'darkHomeData';
const String darkHiddenIDsKey = 'darkHiddenIDs';
const String darkBanishIDsKey = 'darkBanishIDs';

const String lightHomeDataKey = 'lightHomeData';
const String lightHiddenIDsKey = 'lightHiddenIDs';
const String lightBanishIDsKey = 'lightBanishIDs';

const String shownIntroKey = 'shownIntro';

const String ascListKey = 'ascList';
const String listSortKey = 'listSort';

/// Intro, ID lists, and sorting keys
const Map<String, Type> limBTSKeys = <String, Type>{
  // ID lists
  darkHomeDataKey: List<String>,
  darkHiddenIDsKey: List<String>,
  darkBanishIDsKey: List<String>,

  lightHomeDataKey: List<String>,
  lightHiddenIDsKey: List<String>,
  lightBanishIDsKey: List<String>,

  // Intro
  shownIntroKey: bool,

  // List(s) sort
  ascListKey: bool,
  listSortKey: String,
};

// List //

const String interlinkedKey = 'interlinked';

const String leftSwipeIDKey = 'leftSwipeID';
const String rightSwipeIDKey = 'rightSwipeID';

const String homeRippleKey = 'homeRipple';
const String listRippleKey = 'listRipple';

const String autoSearchKey = 'autoSearch';

/// Header, quick launch, and app list settings
const Map<String, Type> limListKeys = <String, Type>{
  // Home list
  interlinkedKey: bool,

  // Quick launch
  leftSwipeIDKey: String,
  rightSwipeIDKey: String,

  // Ripple
  homeRippleKey: bool,
  listRippleKey: bool,

  // App list
  autoSearchKey: bool,
};

// Secure //

const String authToEditKey = 'authToEdit';
const String authForHiddenKey = 'authForHidden';
const String authTimeoutKey = 'authTimeout';
const String lastAuthKey = 'lastAuth';

// Design (button) //

const String darkListLabelKey = 'darkListLabel';
const String darkListIconKey = 'darkListIcon';
const String darkElevatedListKey = 'darkElevatedList';
const String darkFolderLabelKey = 'darkFolderLabel';
const String darkFolderIconKey = 'darkFolderIcon';
const String darkElevatedFolderKey = 'darkElevatedFolder';
const String darkWideTilesKey = 'darkWideTiles';
const String darkPagesKey = 'darkPages';

const String lightListLabelKey = 'lightListLabel';
const String lightListIconKey = 'lightListIcon';
const String lightElevatedListKey = 'lightElevatedList';
const String lightFolderLabelKey = 'lightFolderLabel';
const String lightFolderIconKey = 'lightFolderIcon';
const String lightElevatedFolderKey = 'lightElevatedFolder';
const String lightWideTilesKey = 'lightWideTiles';
const String lightPagesKey = 'lightPages';

// Design (page) //

const String darkHideStatusKey = 'darkHideStatus';
const String darkHorizontalAlignKey = 'darkHorizontalAlign';
const String darkVerticalAlignKey = 'darkVerticalAlign';

const String lightHideStatusKey = 'lightHideStatus';
const String lightHorizontalAlignKey = 'lightHorizontalAlign';
const String lightVerticalAlignKey = 'lightVerticalAlign';

/// Wallpaper and app tile settings
const Map<String, Type> limDesignKeys = <String, Type>{
  // Button
  darkListLabelKey: String,
  darkListIconKey: bool,
  darkElevatedListKey: bool,
  darkFolderLabelKey: String,
  darkFolderIconKey: bool,
  darkElevatedFolderKey: bool,
  darkWideTilesKey: bool,
  darkPagesKey: bool,

  lightListLabelKey: String,
  lightListIconKey: bool,
  lightElevatedListKey: bool,
  lightFolderLabelKey: String,
  lightFolderIconKey: bool,
  lightElevatedFolderKey: bool,
  lightWideTilesKey: bool,
  lightPagesKey: bool,

  // Page
  darkHideStatusKey: bool,
  darkHorizontalAlignKey: String,
  darkVerticalAlignKey: String,

  lightHideStatusKey: bool,
  lightHorizontalAlignKey: String,
  lightVerticalAlignKey: String,
};

// Shared //

/// [allEZConfigKeys], [limBTSKeys], [limListKeys], [limDesignKeys],
const Map<String, Type> allLimKeys = <String, Type>{
  ...allEZConfigKeys,
  ...limBTSKeys,
  ...limListKeys,
  ...limDesignKeys,
};

/// [EzCM.init] passthrough
final Set<String> neverResetKeys = <String>{...limBTSKeys.keys, ...limListKeys.keys};

/// [ywtMobileConfig] with Liminal additions
final Map<String, Object> liminalDefault = <String, Object>{
  ...ywtMobileConfig,

  // BTS //
  // ID lists
  darkHomeDataKey: <String>[
    <String>[
      defaultLaneEntry(),
      <String>[WWGG.clock.value, defaultClockEntry()].join(widgetSplit),
      <String>[WWGG.search.value, defaultSearchEntry()].join(widgetSplit),
    ].join(listSplit),
  ],
  darkHiddenIDsKey: <String>[],
  darkBanishIDsKey: <String>[],

  lightHomeDataKey: <String>[
    <String>[
      defaultLaneEntry(),
      <String>[WWGG.clock.value, defaultClockEntry()].join(widgetSplit),
      <String>[WWGG.search.value, defaultSearchEntry()].join(widgetSplit),
    ].join(listSplit),
  ],
  lightHiddenIDsKey: <String>[],
  lightBanishIDsKey: <String>[],

  // Intro
  shownIntroKey: false,

  // List(s) sort
  ascListKey: true,
  listSortKey: ListSort.name.value,

  // List //
  // Home
  interlinkedKey: true,

  // Quick launch
  leftSwipeIDKey: '',
  rightSwipeIDKey: '',

  // Ripple
  homeRippleKey: true,
  listRippleKey: true,

  // All
  autoSearchKey: false,

  // Design //
  // Button
  darkListLabelKey: LabelType.full.value,
  darkListIconKey: true,
  darkElevatedListKey: false,
  darkFolderLabelKey: LabelType.full.value,
  darkFolderIconKey: true,
  darkElevatedFolderKey: false,
  darkWideTilesKey: true,
  darkPagesKey: true,

  lightListLabelKey: LabelType.full.value,
  lightListIconKey: true,
  lightElevatedListKey: false,
  lightFolderLabelKey: LabelType.full.value,
  lightFolderIconKey: true,
  lightElevatedFolderKey: false,
  lightWideTilesKey: true,
  lightPagesKey: true,

  // Page
  darkHideStatusKey: true,
  darkHorizontalAlignKey: ListAlignment.center.value,
  darkVerticalAlignKey: ListAlignment.start.value,

  lightHideStatusKey: true,
  lightHorizontalAlignKey: ListAlignment.center.value,
  lightVerticalAlignKey: ListAlignment.start.value,

  // Text //
  darkTextBackgroundOpacityKey: 0.75,

  lightTextBackgroundOpacityKey: 0.75,
};

/// Secure key defaults for Liminal
const Map<String, Object> limSecDef = <String, Object>{
  authToEditKey: false,
  authForHiddenKey: false,
  authTimeoutKey: 5,
  lastAuthKey: '',
};

//* Runtime *//

/// :01001100: == :L:
const String listSplit = ':01001100:';

/// :01001001: == :I:
const String idSplit = ':01001001:';

/// :01010111: == :W:
const String widgetSplit = ':01010111:';

/// :01000110: == :F:
const String folderSplit = ':01000110:';

/// :01010011: == :S:
const String spacerSplit = ':01010011:';

/// r'(:(I|W|F|S):)'... but the binaries
final RegExp tileRegex = RegExp(r':(01001001|01010111|01000110|01010011):');

/// :01000011: == :C:
const String configSplit = ':01000011:';

class LimPos {
  final int lane;
  final int index;
  final ListAlignment hAlign;
  final ListAlignment vAlign;

  const LimPos({
    required this.lane,
    required this.index,
    required this.hAlign,
    required this.vAlign,
  });

  Alignment get subAlign => LAConfig.merge(h: hAlign, v: vAlign);
}

/// ---
const String nullAppLabel = '---';

/// empty [String]
const String nullAppPackage = '';

const List<IconData> solidIconChoices = <IconData>[
  Icons.account_balance_wallet,
  Icons.alarm,
  Icons.book,
  Icons.calculate,
  Icons.calendar_month,
  Icons.camera_alt,
  Icons.chat,
  Icons.check_circle,
  Icons.cloud,
  Icons.code,
  Icons.directions_boat,
  Icons.directions_bike,
  Icons.directions_car,
  Icons.directions_run,
  Icons.directions_transit,
  Icons.draw,
  Icons.explore,
  Icons.favorite,
  Icons.fitness_center,
  Icons.flight,
  Icons.folder,
  Icons.group,
  Icons.headset,
  Icons.health_and_safety,
  Icons.home,
  Icons.local_cafe,
  Icons.local_mall,
  Icons.lock,
  Icons.mail,
  Icons.movie,
  Icons.music_note,
  Icons.navigation,
  Icons.newspaper,
  Icons.pets,
  Icons.photo_library,
  Icons.public,
  Icons.restaurant,
  Icons.school,
  Icons.settings,
  Icons.share,
  Icons.shopping_cart,
  Icons.sports_bar,
  Icons.sports_esports,
  Icons.sports_gymnastics,
  Icons.star,
  Icons.storefront,
  Icons.tv,
  Icons.videogame_asset,
  Icons.wine_bar,
  Icons.work,
];

const List<IconData> outlinedIconChoices = <IconData>[
  Icons.account_balance_wallet_outlined,
  Icons.alarm_outlined,
  Icons.book_outlined,
  Icons.calculate_outlined,
  Icons.calendar_month_outlined,
  Icons.camera_alt_outlined,
  Icons.chat_outlined,
  Icons.check_circle_outline,
  Icons.cloud_outlined,
  Icons.code_outlined,
  Icons.directions_boat_outlined,
  Icons.directions_bike_outlined,
  Icons.directions_car_outlined,
  Icons.directions_run_outlined,
  Icons.directions_transit_outlined,
  Icons.draw_outlined,
  Icons.explore_outlined,
  Icons.favorite_border,
  Icons.fitness_center_outlined,
  Icons.flight_outlined,
  Icons.folder_outlined,
  Icons.group_outlined,
  Icons.headset_outlined,
  Icons.health_and_safety_outlined,
  Icons.home_outlined,
  Icons.local_cafe_outlined,
  Icons.local_mall_outlined,
  Icons.lock_outlined,
  Icons.mail_outlined,
  Icons.movie_outlined,
  Icons.music_note_outlined,
  Icons.navigation_outlined,
  Icons.newspaper_outlined,
  Icons.pets_outlined,
  Icons.photo_library_outlined,
  Icons.public_outlined,
  Icons.restaurant_outlined,
  Icons.school_outlined,
  Icons.settings_outlined,
  Icons.share_outlined,
  Icons.shopping_cart_outlined,
  Icons.sports_bar_outlined,
  Icons.sports_esports_outlined,
  Icons.sports_gymnastics_outlined,
  Icons.star_border,
  Icons.storefront_outlined,
  Icons.tv_outlined,
  Icons.videogame_asset_outlined,
  Icons.wine_bar_outlined,
  Icons.work_outline_outlined,
];

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

/// 2 seconds
const Duration breatheTime = Duration(seconds: 2);

// Not const //

Offset lastRipple = Offset.zero;

final ValueNotifier<(int?, int?)> marked = ValueNotifier<(int?, int?)>((null, null));
bool get editingSpacer => marked.value.$1 != null || marked.value.$2 != null;

final ValueNotifier<double> editSpacerHeight = ValueNotifier<double>(defaultMobileSpacing);
final ValueNotifier<double> editSpacerWidth = ValueNotifier<double>(defaultMobileSpacing);
