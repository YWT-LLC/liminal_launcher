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

/// llc.ywt.liminal_launcher
const String androidPackage = 'llc.ywt.liminal_launcher';

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
      <String>[WWGG.search.value, defaultSearchEntry(WWGGSize.tile)].join(widgetSplit),
    ].join(listSplit),
  ],
  darkHiddenIDsKey: <String>[],
  darkBanishIDsKey: <String>[],

  lightHomeDataKey: <String>[
    <String>[
      defaultLaneEntry(),
      <String>[WWGG.clock.value, defaultClockEntry()].join(widgetSplit),
      <String>[WWGG.search.value, defaultSearchEntry(WWGGSize.tile)].join(widgetSplit),
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

// Splits //

/// :
const String colon = ':';

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

// Split indexes //

// t-o-d-o (appPaddingIndex, widgetPaddingIndex, etc.)

// Position && padding //

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

  @override
  int get hashCode => lane.hashCode + index.hashCode;

  @override
  bool operator ==(Object other) => other is LimPos && other.lane == lane && other.index == index;
}

/// Placeholder value(s): (0,0) + (center, center)
const LimPos nullPos =
    LimPos(lane: 0, index: 0, hAlign: ListAlignment.center, vAlign: ListAlignment.center);

/// null tile padding [List]double?
const List<double?> nullTPL = <double?>[null, null, null, null];

/// null tile padding [String]
final String nullTPS = <String>[esSystem, esSystem, esSystem, esSystem].join(colon);

/// zero tile padding [String]
final String zeroTPS = <String>['0.0', '0.0', '0.0', '0.0'].join(colon);

// App values //

/// ---
const String nullAppLabel = '---';

/// empty [String]
const String nullAppPackage = '';

// Wingding //

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

// Misc //

/// 2 seconds
const Duration breatheTime = Duration(seconds: 2);

// Const-ish //

Map<String, IconData> solidIconChoices(EzCP config) => <String, IconData>{
      l10n(config).inAlarm: Icons.alarm,
      l10n(config).inBike: Icons.directions_bike,
      l10n(config).inBoat: Icons.directions_boat,
      l10n(config).inBook: Icons.book,
      l10n(config).inCafe: Icons.local_cafe,
      l10n(config).inCalculator: Icons.calculate,
      l10n(config).inCalendar: Icons.calendar_month,
      l10n(config).inCamera: Icons.camera_alt,
      l10n(config).inCar: Icons.directions_car,
      l10n(config).inChat: Icons.chat,
      l10n(config).inCheck: Icons.check_circle,
      l10n(config).inCloud: Icons.cloud,
      l10n(config).inCode: Icons.code,
      l10n(config).inDraw: Icons.draw,
      l10n(config).inExplore: Icons.explore,
      l10n(config).inFavorite: Icons.favorite,
      l10n(config).inFitness: Icons.fitness_center,
      l10n(config).inFlight: Icons.flight,
      l10n(config).inFolder: Icons.folder,
      l10n(config).inFuel: Icons.gas_meter,
      l10n(config).inGame: Icons.sports_esports,
      l10n(config).inGlobal: Icons.public,
      l10n(config).inGrass: Icons.grass,
      l10n(config).inGroup: Icons.group,
      l10n(config).inGymnastics: Icons.sports_gymnastics,
      l10n(config).inHeadset: Icons.headset,
      l10n(config).inHealth: Icons.health_and_safety,
      l10n(config).inHome: Icons.home,
      l10n(config).inLock: Icons.lock,
      l10n(config).inMail: Icons.mail,
      l10n(config).inMovie: Icons.movie,
      l10n(config).inMusic: Icons.music_note,
      l10n(config).inNews: Icons.newspaper,
      l10n(config).inPets: Icons.pets,
      l10n(config).inPhoto: Icons.photo_library,
      l10n(config).inPub: Icons.sports_bar,
      l10n(config).inRestaurant: Icons.restaurant,
      l10n(config).inRun: Icons.directions_run,
      l10n(config).inSchool: Icons.school,
      l10n(config).inSearch: Icons.search,
      l10n(config).inSettings: Icons.settings,
      l10n(config).inShare: Icons.share,
      l10n(config).inShopping: Icons.shopping_cart,
      l10n(config).inStar: Icons.star,
      l10n(config).inStorefront: Icons.storefront,
      l10n(config).inTransit: Icons.directions_transit,
      l10n(config).inTool: Icons.build,
      l10n(config).inTV: Icons.tv,
      l10n(config).inWallet: Icons.account_balance_wallet,
      l10n(config).inWine: Icons.wine_bar,
      l10n(config).inWork: Icons.work,
    };

Map<String, IconData> outlinedIconChoices(EzCP config) => <String, IconData>{
      l10n(config).inAlarm: Icons.alarm_outlined,
      l10n(config).inBike: Icons.directions_bike_outlined,
      l10n(config).inBoat: Icons.directions_boat_outlined,
      l10n(config).inBook: Icons.book_outlined,
      l10n(config).inCafe: Icons.local_cafe_outlined,
      l10n(config).inCalculator: Icons.calculate_outlined,
      l10n(config).inCalendar: Icons.calendar_month_outlined,
      l10n(config).inCamera: Icons.camera_alt_outlined,
      l10n(config).inCar: Icons.directions_car_outlined,
      l10n(config).inChat: Icons.chat_outlined,
      l10n(config).inCheck: Icons.check_circle_outlined,
      l10n(config).inCloud: Icons.cloud_outlined,
      l10n(config).inCode: Icons.code_outlined,
      l10n(config).inDraw: Icons.draw_outlined,
      l10n(config).inExplore: Icons.explore_outlined,
      l10n(config).inFavorite: Icons.favorite_outlined,
      l10n(config).inFitness: Icons.fitness_center_outlined,
      l10n(config).inFlight: Icons.flight_outlined,
      l10n(config).inFolder: Icons.folder_outlined,
      l10n(config).inFuel: Icons.gas_meter_outlined,
      l10n(config).inGame: Icons.sports_esports_outlined,
      l10n(config).inGlobal: Icons.public_outlined,
      l10n(config).inGrass: Icons.grass_outlined,
      l10n(config).inGroup: Icons.group_outlined,
      l10n(config).inGymnastics: Icons.sports_gymnastics_outlined,
      l10n(config).inHeadset: Icons.headset_outlined,
      l10n(config).inHealth: Icons.health_and_safety_outlined,
      l10n(config).inHome: Icons.home_outlined,
      l10n(config).inLock: Icons.lock_outlined,
      l10n(config).inMail: Icons.mail_outlined,
      l10n(config).inMovie: Icons.movie_outlined,
      l10n(config).inMusic: Icons.music_note_outlined,
      l10n(config).inNews: Icons.newspaper_outlined,
      l10n(config).inPets: Icons.pets_outlined,
      l10n(config).inPhoto: Icons.photo_library_outlined,
      l10n(config).inPub: Icons.sports_bar_outlined,
      l10n(config).inRestaurant: Icons.restaurant_outlined,
      l10n(config).inRun: Icons.directions_run_outlined,
      l10n(config).inSchool: Icons.school_outlined,
      l10n(config).inSearch: Icons.search_outlined,
      l10n(config).inSettings: Icons.settings_outlined,
      l10n(config).inShare: Icons.share_outlined,
      l10n(config).inShopping: Icons.shopping_cart_outlined,
      l10n(config).inStar: Icons.star_outlined,
      l10n(config).inStorefront: Icons.storefront_outlined,
      l10n(config).inTransit: Icons.directions_transit_outlined,
      l10n(config).inTool: Icons.build_outlined,
      l10n(config).inTV: Icons.tv_outlined,
      l10n(config).inWallet: Icons.account_balance_wallet_outlined,
      l10n(config).inWine: Icons.wine_bar_outlined,
      l10n(config).inWork: Icons.work_outlined,
    };

// Constantly available //

Offset lastRipple = Offset.zero;

final ValueNotifier<LimPos?> marked = ValueNotifier<LimPos?>(null);
bool get editingMarked => marked.value != null;

final ValueNotifier<Size> editSpacerSize =
    ValueNotifier<Size>(const Size.square(defaultMobileSpacing));

final ValueNotifier<EdgeInsets> editTilePadding =
    ValueNotifier<EdgeInsets>(const EzInsets.wrap(defaultMobileSpacing));
