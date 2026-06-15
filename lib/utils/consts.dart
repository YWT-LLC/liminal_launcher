/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
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

/// Delay for home screen navigation when reaching the edge of a list
const Duration scrollDelay = Duration(milliseconds: 100);

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

const String renamedIDsKey = 'renamedIDs';
const String hiddenIDsKey = 'hiddenIDs';
const String banishedIDsKey = 'banishedIDs';
const String darkHomeDataKey = 'darkHomeIDs';
const String lightHomeDataKey = 'lightHomeIDs';

const String shownIntroKey = 'shownIntro';

const String ascListKey = 'ascList';
const String listSortKey = 'listSort';

/// Intro, ID lists, and sorting keys
const Map<String, Type> limBTSKeys = <String, Type>{
  // ID lists
  renamedIDsKey: List<String>,
  hiddenIDsKey: List<String>,
  banishedIDsKey: List<String>,
  darkHomeDataKey: List<String>,
  lightHomeDataKey: List<String>,

  // Intro
  shownIntroKey: bool,

  // List(s) sort
  ascListKey: bool,
  listSortKey: String,
};

// List //

const String interlinkedKey = 'interlinked';

const String autoSearchKey = 'autoSearch';

const String leftSwipeIDKey = 'leftSwipeID';
const String rightSwipeIDKey = 'rightSwipeID';

/// Header, quick launch, and app list settings
const Map<String, Type> limListKeys = <String, Type>{
  // Home list
  interlinkedKey: bool,

  // App list
  autoSearchKey: bool,

  // Quick launch
  leftSwipeIDKey: String,
  rightSwipeIDKey: String,
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

const String lightListLabelKey = 'lightListLabel';
const String lightListIconKey = 'lightListIcon';
const String lightElevatedListKey = 'lightElevatedList';
const String lightFolderLabelKey = 'lightFolderLabel';
const String lightFolderIconKey = 'lightFolderIcon';
const String lightElevatedFolderKey = 'lightElevatedFolder';
const String lightWideTilesKey = 'lightWideTiles';

// Design (page) //

const String darkHideStatusKey = 'darkHideStatus';
const String darkHomeTimeKey = 'darkHomeTime';
const String darkHomeDateKey = 'darkHomeDate';
const String darkHorizontalAlignKey = 'darkHorizontalAlign';
const String darkVerticalAlignKey = 'darkVerticalAlign';

const String lightHideStatusKey = 'lightHideStatus';
const String lightHomeTimeKey = 'lightHomeTime';
const String lightHomeDateKey = 'lightHomeDate';
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

  lightListLabelKey: String,
  lightListIconKey: bool,
  lightElevatedListKey: bool,
  lightFolderLabelKey: String,
  lightFolderIconKey: bool,
  lightElevatedFolderKey: bool,
  lightWideTilesKey: bool,

  // Page
  darkHideStatusKey: bool,
  darkHomeTimeKey: bool,
  darkHomeDateKey: String,
  darkHorizontalAlignKey: String,
  darkVerticalAlignKey: String,

  lightHideStatusKey: bool,
  lightHomeTimeKey: bool,
  lightHomeDateKey: String,
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
final Set<String> neverResetKeys = <String>{
  ...limBTSKeys.keys,
  ...limListKeys.keys,
};

/// [empathMobileConfig] with Liminal additions
final Map<String, Object> liminalDefault = <String, Object>{
  ...empathMobileConfig,

  // BTS //
  // ID lists
  renamedIDsKey: <String>[],
  hiddenIDsKey: <String>[],
  banishedIDsKey: <String>[],
  darkHomeDataKey: <String>['[]'],
  lightHomeDataKey: <String>['[]'],

  // Intro
  shownIntroKey: false,

  // List(s) sort
  ascListKey: true,
  listSortKey: AppSort.name.value,

  // List //
  // Home
  interlinkedKey: true,

  // All
  autoSearchKey: false,

  // Quick launch
  leftSwipeIDKey: '',
  rightSwipeIDKey: '',

  // Design //
  // Button
  darkListLabelKey: LabelType.full.value,
  darkListIconKey: true,
  darkElevatedListKey: false,
  darkFolderLabelKey: LabelType.full.value,
  darkFolderIconKey: true,
  darkElevatedFolderKey: false,
  darkWideTilesKey: true,

  lightListLabelKey: LabelType.full.value,
  lightListIconKey: true,
  lightElevatedListKey: false,
  lightFolderLabelKey: LabelType.full.value,
  lightFolderIconKey: true,
  lightElevatedFolderKey: false,
  lightWideTilesKey: true,

  // Page
  darkHideStatusKey: false,
  darkHomeTimeKey: true,
  darkHomeDateKey: DateType.medium.value,
  darkHorizontalAlignKey: ListAlignment.center.value,
  darkVerticalAlignKey: ListAlignment.start.value,

  lightHideStatusKey: false,
  lightHomeTimeKey: true,
  lightHomeDateKey: DateType.compact.value,
  lightHorizontalAlignKey: ListAlignment.center.value,
  lightVerticalAlignKey: ListAlignment.start.value,
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

/// :01010011: == :S:
const String spacerSplit = ':01010011:';

/// :01000110: == :F:
const String folderSplit = ':01000110:';

/// 'empty'
const String emptyTag = 'empty';

/// ---
const String nullAppLabel = '---';

/// empty [String]
const String nullAppPackage = '';

/// 00W
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

// Not const //

Offset lastRipple = Offset.zero;

/// 1.5
double rippleMod = 1.5;
