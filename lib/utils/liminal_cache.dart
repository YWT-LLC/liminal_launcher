/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalCache extends EzAppCache {
  // Construct //

  Locale _locale;
  Lang _l10n;

  final AppInfoProvider _appInfo;

  late LauncherCache _launcher;
  late DesignCache _design;
  late LayoutCache _layout;

  LiminalCache(Locale locale, Lang l10n, AppInfoProvider appInfo)
      : _locale = locale,
        _l10n = l10n,
        _appInfo = appInfo;

  // Get //

  Lang get l10n => _l10n;

  LauncherCache get launcher => _launcher;
  DesignCache get design => _design;
  LayoutCache get layout => _layout;

  AppInfoProvider get appInfo => _appInfo;

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

  void _buildLocalCache({bool? darkInit}) {
    if (darkInit ?? EzConfig.isDark) {
      _launcher = LauncherCache(
        leftSwipe: EzConfig.get(darkLeftSwipeIDKey),
        rightSwipe: EzConfig.get(darkRightSwipeIDKey),
      );
      _design = DesignCache(
        useOSWall: EzConfig.get(darkUseOSKey),
        wideTiles: EzConfig.get(darkWideTilesKey),
        homeDate: DateTypeConfig.lookup(EzConfig.get(darkHomeDateKey)),
        homeTime: EzConfig.get(darkHomeTimeKey),
        folderIcons: EzConfig.get(darkFolderIconKey),
        folderLabels:
            LabelTypeConfig.lookup(EzConfig.get(darkFolderLabelTypeKey)),
        listIcons: EzConfig.get(darkListIconKey),
        listLabels: LabelTypeConfig.lookup(EzConfig.get(darkListLabelTypeKey)),
      );
      _layout = LayoutCache(
        horizontalAlign:
            ListAlignmentConfig.lookup(EzConfig.get(darkHorizontalAlignKey)),
        verticalAlign:
            ListAlignmentConfig.lookup(EzConfig.get(darkVerticalAlignKey)),
      );
    } else {
      _launcher = LauncherCache(
        leftSwipe: EzConfig.get(lightLeftSwipeIDKey),
        rightSwipe: EzConfig.get(lightRightSwipeIDKey),
      );
      _design = DesignCache(
        useOSWall: EzConfig.get(lightUseOSKey),
        wideTiles: EzConfig.get(lightWideTilesKey),
        homeDate: DateTypeConfig.lookup(EzConfig.get(lightHomeDateKey)),
        homeTime: EzConfig.get(lightHomeTimeKey),
        folderIcons: EzConfig.get(lightFolderIconKey),
        folderLabels:
            LabelTypeConfig.lookup(EzConfig.get(lightFolderLabelTypeKey)),
        listIcons: EzConfig.get(lightListIconKey),
        listLabels: LabelTypeConfig.lookup(EzConfig.get(lightListLabelTypeKey)),
      );
      _layout = LayoutCache(
        horizontalAlign:
            ListAlignmentConfig.lookup(EzConfig.get(lightHorizontalAlignKey)),
        verticalAlign:
            ListAlignmentConfig.lookup(EzConfig.get(lightVerticalAlignKey)),
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
  final bool useOSWall;
  final bool wideTiles;

  final DateType homeDate;
  final bool homeTime;

  final bool folderIcons;
  final LabelType folderLabels;

  final bool listIcons;
  final LabelType listLabels;

  DesignCache({
    required this.useOSWall,
    required this.wideTiles,
    required this.homeDate,
    required this.homeTime,
    required this.folderIcons,
    required this.folderLabels,
    required this.listIcons,
    required this.listLabels,
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

AppInfoProvider get appInfo => _pointer.appInfo;

String get leftSwipeID => _pointer.launcher.leftSwipe;
String get rightSwipeID => _pointer.launcher.rightSwipe;

bool get useOSWall => _pointer.design.useOSWall;
bool get wideTiles => _pointer.design.wideTiles;

DateType get homeDate => _pointer.design.homeDate;
bool get homeTime => _pointer.design.homeTime;

bool get folderIcons => _pointer.design.folderIcons;
LabelType get folderLabels => _pointer.design.folderLabels;

bool get listIcons => _pointer.design.listIcons;
LabelType get listLabels => _pointer.design.listLabels;

double get appIconSize => EzConfig.iconSize * 1.25 + EzConfig.padding;

ListAlignment get hAlign => _pointer.layout.horizontalAlign;
ListAlignment get vAlign => _pointer.layout.verticalAlign;
