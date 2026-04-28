/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalCache extends EzAppCache {
  // Construct //

  Locale _locale;
  Lang _l10n;

  late LauncherCache _launcher;
  late DesignCache _design;
  late LayoutCache _layout;

  LiminalCache(Locale locale, Lang l10n)
      : _locale = locale,
        _l10n = l10n;

  // Get //

  Lang get l10n => _l10n;

  LauncherCache get launcher => _launcher;
  DesignCache get design => _design;
  LayoutCache get layout => _layout;

  // Set //

  @override
  void init(bool isDark) => _buildLocalCache(darkInit: isDark);

  @override
  Future<void> rebuild() async {
    if (_locale != EzConfig.locale) {
      _l10n = await Lang.delegate.load(EzConfig.locale);
      _locale = EzConfig.locale;
    }

    _buildLocalCache();
  }

  void _buildLocalCache({bool? darkInit}) async {
    final bool isDark = darkInit ?? EzConfig.isDark;

    if (isDark) {
      _launcher = LauncherCache(
        leftSwipe: EzConfig.get(darkLeftSwipeIDKey),
        rightSwipe: EzConfig.get(darkRightSwipeIDKey),
      );
      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzConfig.get(darkHomeDateKey)),
        homeTime: EzConfig.get(darkHomeTimeKey),
        listIcons: EzConfig.get(darkListIconKey),
        listLabels: LabelTypeConfig.lookup(EzConfig.get(darkListLabelTypeKey)),
        elevatedLists: EzConfig.get(darkElevatedListKey),
        folderIcons: EzConfig.get(darkFolderIconKey),
        folderLabels: LabelTypeConfig.lookup(EzConfig.get(darkFolderLabelTypeKey)),
        elevatedFolders: EzConfig.get(darkElevatedFolderKey),
        wideTiles: EzConfig.get(darkWideTilesKey),
      );
      _layout = LayoutCache(
        horizontalAlign: ListAlignmentConfig.lookup(EzConfig.get(darkHorizontalAlignKey)),
        verticalAlign: ListAlignmentConfig.lookup(EzConfig.get(darkVerticalAlignKey)),
      );
    } else {
      _launcher = LauncherCache(
        leftSwipe: EzConfig.get(lightLeftSwipeIDKey),
        rightSwipe: EzConfig.get(lightRightSwipeIDKey),
      );
      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzConfig.get(lightHomeDateKey)),
        homeTime: EzConfig.get(lightHomeTimeKey),
        listIcons: EzConfig.get(lightListIconKey),
        listLabels: LabelTypeConfig.lookup(EzConfig.get(lightListLabelTypeKey)),
        elevatedLists: EzConfig.get(lightElevatedListKey),
        folderIcons: EzConfig.get(lightFolderIconKey),
        folderLabels: LabelTypeConfig.lookup(EzConfig.get(lightFolderLabelTypeKey)),
        elevatedFolders: EzConfig.get(lightElevatedFolderKey),
        wideTiles: EzConfig.get(lightWideTilesKey),
      );
      _layout = LayoutCache(
        horizontalAlign: ListAlignmentConfig.lookup(EzConfig.get(lightHorizontalAlignKey)),
        verticalAlign: ListAlignmentConfig.lookup(EzConfig.get(lightVerticalAlignKey)),
      );
    }

    if (EzConfig.get(isDark ? darkHideStatusKey : lightHideStatusKey) == true) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: <SystemUiOverlay>[SystemUiOverlay.bottom],
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}

// Local sub-caches //

class LauncherCache {
  final String leftSwipe;
  final String rightSwipe;

  LauncherCache({
    required this.leftSwipe,
    required this.rightSwipe,
  });
}

class DesignCache {
  final DateType homeDate;
  final bool homeTime;

  final bool listIcons;
  final LabelType listLabels;
  final bool elevatedLists;

  final bool folderIcons;
  final LabelType folderLabels;
  final bool elevatedFolders;

  final bool wideTiles;

  DesignCache({
    required this.homeDate,
    required this.homeTime,
    required this.listIcons,
    required this.listLabels,
    required this.elevatedLists,
    required this.folderIcons,
    required this.folderLabels,
    required this.wideTiles,
    required this.elevatedFolders,
  });
}

class LayoutCache {
  final ListAlignment horizontalAlign;
  final ListAlignment verticalAlign;

  LayoutCache({
    required this.horizontalAlign,
    required this.verticalAlign,
  });
}

// Aliases //

LiminalCache get _pointer => EzConfig.appCache! as LiminalCache;

Lang get l10n => _pointer.l10n;

AppInfoProvider get appInfo =>
    Provider.of<AppInfoProvider>(ezRootNav.currentContext!, listen: false);

String get leftSwipeID => _pointer.launcher.leftSwipe;
String get rightSwipeID => _pointer.launcher.rightSwipe;

DateType get homeDate => _pointer.design.homeDate;
bool get homeTime => _pointer.design.homeTime;

bool get listIcons => _pointer.design.listIcons;
LabelType get listLabels => _pointer.design.listLabels;
bool get elevatedLists => _pointer.design.elevatedLists;

bool get folderIcons => _pointer.design.folderIcons;
LabelType get folderLabels => _pointer.design.folderLabels;
bool get elevatedFolders => _pointer.design.elevatedFolders;

bool get wideTiles => _pointer.design.wideTiles;
double get appIconSize => EzConfig.iconSize * 1.2 + EzConfig.padding;

ListAlignment get hAlign => _pointer.layout.horizontalAlign;
ListAlignment get vAlign => _pointer.layout.verticalAlign;
