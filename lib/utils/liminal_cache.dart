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
  Locale _locale;
  Lang _l10n;

  late DesignCache _design;

  LiminalCache(Locale locale, Lang l10n)
      : _locale = locale,
        _l10n = l10n;

  @override
  void init(bool isDark) => _buildLocalCache(darkInit: isDark);

  @override
  Future<void> rebuild() async {
    if (_locale != EzConfig.locale) {
      _locale = EzConfig.locale;
      _l10n = await Lang.delegate.load(EzConfig.locale);
    }

    _buildLocalCache();
  }

  void _buildLocalCache({bool? darkInit}) async {
    final bool isDark = darkInit ?? EzConfig.isDark;

    if (isDark) {
      final bool listIcons = EzConfig.get(darkListIconKey);
      final LabelType listLabels = LabelTypeConfig.lookup(EzConfig.get(darkListLabelTypeKey));
      final bool elevatedLists = EzConfig.get(darkElevatedListKey);

      final bool folderIcons = EzConfig.get(darkFolderIconKey);
      final LabelType folderLabels = LabelTypeConfig.lookup(EzConfig.get(darkFolderLabelTypeKey));
      final bool elevatedFolders = EzConfig.get(darkElevatedFolderKey);

      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzConfig.get(darkHomeDateKey)),
        homeTime: EzConfig.get(darkHomeTimeKey),
        horizontalAlign: LAConfig.lookup(EzConfig.get(darkHorizontalAlignKey)),
        verticalAlign: LAConfig.lookup(EzConfig.get(darkVerticalAlignKey)),
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
        wideTiles: EzConfig.get(darkWideTilesKey),
      );
    } else {
      final bool listIcons = EzConfig.get(lightListIconKey);
      final LabelType listLabels = LabelTypeConfig.lookup(EzConfig.get(lightListLabelTypeKey));
      final bool elevatedLists = EzConfig.get(lightElevatedListKey);

      final bool folderIcons = EzConfig.get(lightFolderIconKey);
      final LabelType folderLabels = LabelTypeConfig.lookup(EzConfig.get(lightFolderLabelTypeKey));
      final bool elevatedFolders = EzConfig.get(lightElevatedFolderKey);

      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzConfig.get(lightHomeDateKey)),
        homeTime: EzConfig.get(lightHomeTimeKey),
        horizontalAlign: LAConfig.lookup(EzConfig.get(lightHorizontalAlignKey)),
        verticalAlign: LAConfig.lookup(EzConfig.get(lightVerticalAlignKey)),
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
        wideTiles: EzConfig.get(lightWideTilesKey),
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

class DesignCache {
  final DateType homeDate;
  final bool homeTime;

  final ListAlignment horizontalAlign;
  final ListAlignment verticalAlign;

  final bool listIcons;
  final LabelType listLabels;
  final bool elevatedLists;
  final ButtonType listBT;

  final bool folderIcons;
  final LabelType folderLabels;
  final bool elevatedFolders;
  final ButtonType folderBT;

  final bool wideTiles;

  DesignCache({
    required this.homeDate,
    required this.homeTime,
    required this.horizontalAlign,
    required this.verticalAlign,
    required this.listIcons,
    required this.listLabels,
    required this.elevatedLists,
    required this.listBT,
    required this.folderIcons,
    required this.folderLabels,
    required this.elevatedFolders,
    required this.folderBT,
    required this.wideTiles,
  });
}

LiminalCache get _pointer => EzConfig.appCache! as LiminalCache;

Lang get l10n => _pointer._l10n;

AppInfoProvider get appInfo =>
    Provider.of<AppInfoProvider>(ezRootNav.currentContext!, listen: false);

String get leftSwipeID => EzConfig.get(leftSwipeIDKey);
String get rightSwipeID => EzConfig.get(rightSwipeIDKey);

bool get listIcons => _pointer._design.listIcons;
LabelType get listLabels => _pointer._design.listLabels;
bool get elevatedLists => _pointer._design.elevatedLists;
ButtonType get listBT => _pointer._design.listBT;

bool get folderIcons => _pointer._design.folderIcons;
LabelType get folderLabels => _pointer._design.folderLabels;
bool get elevatedFolders => _pointer._design.elevatedFolders;
ButtonType get folderBT => _pointer._design.folderBT;

bool get wideTiles => _pointer._design.wideTiles;
double get appIconSize => EzConfig.iconSize + EzConfig.padding;

DateType get homeDate => _pointer._design.homeDate;
bool get homeTime => _pointer._design.homeTime;

ListAlignment get hAlign => _pointer._design.horizontalAlign;
ListAlignment get vAlign => _pointer._design.verticalAlign;
