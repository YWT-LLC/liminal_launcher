/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// App config //

/// Liminal Launcher
const String appName = 'Liminal Launcher';

/// net.empathetech.liminal
const String androidPackage = 'net.empathetech.liminal';

/// [AppInfo] with package 'net.empathetech.liminal'
final AppInfo self =
    AppInfo(label: appName, package: androidPackage, removable: false);

// EzConfig //

// BTS
const String homeIDsKey = 'home_ids';
const String hiddenIDsKey = 'hidden_ids';
const String renamedIDsKey = 'renamed_ids';
const String listSortKey = 'list_sort';
const String ascListKey = 'asc_list';

// Functionality
const String leftSwipeIDKey = 'left_swipe_id';
const String rightSwipeIDKey = 'right_swipe_id';
const String autoAddToHomeKey = 'auto_add_to_home';
const String autoSearchKey = 'auto_search';
const String authToEditKey = 'auth_to_edit';
const String shakeForFeedbackKey = 'shake_for_feedback';

// Design
const String homeTimeKey = 'home_time';
const String homeDateKey = 'home_date';
const String useOSKey = 'use_os';
const String listIconKey = 'list_icon';
const String listLabelTypeKey = 'list_label_type';
const String folderIconKey = 'folder_icon';
const String folderLabelTypeKey = 'folder_label_type';

// Layout
const String homeHAlignKey = 'home_horizontal_alignment';
const String homeVAlignKey = 'home_vertical_alignment';
const String listHAlignKey = 'list_horizontal_alignment';
const String listVAlignKey = 'list_vertical_alignment';

/// For [EzConfigFAB.extraKeys]
const List<String> liminalDesignKeys = <String>[
  homeTimeKey,
  homeDateKey,
  useOSKey,
  listIconKey,
  listLabelTypeKey,
  folderIconKey,
  folderLabelTypeKey,
];

/// For [EzConfigFAB.extraKeys]
const List<String> liminalLayoutKeys = <String>[
  homeHAlignKey,
  homeVAlignKey,
  listHAlignKey,
  listVAlignKey,
];

/// [empathMobileConfig] with Liminal additions
final Map<String, Object> liminalDefault = <String, Object>{
  ...empathMobileConfig,

  // BTS
  homeIDsKey: <String>[],
  hiddenIDsKey: <String>[],
  renamedIDsKey: <String>[],
  listSortKey: AppSort.name.configValue,
  ascListKey: true,

  // Functionality
  leftSwipeIDKey: '',
  rightSwipeIDKey: '',
  autoAddToHomeKey: false,
  autoSearchKey: false,
  authToEditKey: false,
  shakeForFeedbackKey: false,

  // Design
  homeTimeKey: true,
  homeDateKey: true,
  useOSKey: true,
  listIconKey: true,
  listLabelTypeKey: LabelType.full.configValue,
  folderIconKey: true,
  folderLabelTypeKey: LabelType.none.configValue,

  // Layout
  homeHAlignKey: ListAlignment.center.configValue,
  homeVAlignKey: ListAlignment.start.configValue,
  listHAlignKey: ListAlignment.center.configValue,
  listVAlignKey: ListAlignment.start.configValue,
};

// Custom fonts //

/// 'wingding'
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
