/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalCache extends EzAppCache {
  Locale _locale;
  Lang _l10n;

  late DesignCache _design;
  late SecureCache _security;

  LiminalCache(Locale locale, Lang l10n)
      : _locale = locale,
        _l10n = l10n;

  @override
  void init(bool isDark) => _buildLocalCache(isDark);

  @override
  Future<void> rebuild(EzCP config) async {
    if (_locale != config.locale) {
      _locale = config.locale;
      _l10n = await Lang.delegate.load(config.locale);
    }

    _buildLocalCache(config.isDark);
  }

  void _buildLocalCache(bool isDark) async {
    if (isDark) {
      final bool listIcons = EzCM.get(darkListIconKey);
      final LabelType listLabels = LabelTypeConfig.lookup(EzCM.get(darkListLabelKey));
      final bool elevatedLists = EzCM.get(darkElevatedListKey);

      final bool folderIcons = EzCM.get(darkFolderIconKey);
      final LabelType folderLabels = LabelTypeConfig.lookup(EzCM.get(darkFolderLabelKey));
      final bool elevatedFolders = EzCM.get(darkElevatedFolderKey);

      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzCM.get(darkHomeDateKey)),
        homeTime: EzCM.get(darkHomeTimeKey),
        horizontalAlign: LAConfig.lookup(EzCM.get(darkHorizontalAlignKey)),
        verticalAlign: LAConfig.lookup(EzCM.get(darkVerticalAlignKey)),
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
        wideTiles: EzCM.get(darkWideTilesKey),
      );
    } else {
      final bool listIcons = EzCM.get(lightListIconKey);
      final LabelType listLabels = LabelTypeConfig.lookup(EzCM.get(lightListLabelKey));
      final bool elevatedLists = EzCM.get(lightElevatedListKey);

      final bool folderIcons = EzCM.get(lightFolderIconKey);
      final LabelType folderLabels = LabelTypeConfig.lookup(EzCM.get(lightFolderLabelKey));
      final bool elevatedFolders = EzCM.get(lightElevatedFolderKey);

      _design = DesignCache(
        homeDate: DateTypeConfig.lookup(EzCM.get(lightHomeDateKey)),
        homeTime: EzCM.get(lightHomeTimeKey),
        horizontalAlign: LAConfig.lookup(EzCM.get(lightHorizontalAlignKey)),
        verticalAlign: LAConfig.lookup(EzCM.get(lightVerticalAlignKey)),
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
        wideTiles: EzCM.get(lightWideTilesKey),
      );
    }

    final bool defATE = limSecDef[authToEditKey] as bool;
    final bool defAFH = limSecDef[authForHiddenKey] as bool;
    final int defAT = limSecDef[authTimeoutKey] as int;

    _security = SecureCache(
      authToEdit: bool.tryParse(await EzCM.secGet(authToEditKey)) ?? defATE,
      authForHidden: bool.tryParse(await EzCM.secGet(authForHiddenKey)) ?? defAFH,
      authTimeout: Duration(minutes: int.tryParse(await EzCM.secGet(authTimeoutKey)) ?? defAT),
    );

    if (EzCM.get(isDark ? darkHideStatusKey : lightHideStatusKey) == true) {
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

class SecureCache {
  final bool _authToEdit;
  final bool _authForHidden;
  final Duration _authTimeout;

  SecureCache({
    required bool authToEdit,
    required bool authForHidden,
    required Duration authTimeout,
  })  : _authToEdit = authToEdit,
        _authForHidden = authForHidden,
        _authTimeout = authTimeout;

  bool get authToEdit => _authToEdit;
  bool get authForHidden => _authForHidden;
  Duration get authTimeout => _authTimeout;
}

LiminalCache _cache(EzCP config) => config.appCache! as LiminalCache;

Lang l10n(EzCP config) => _cache(config)._l10n;

String leftSwipeID(EzCP config) => EzCM.get(leftSwipeIDKey);
String rightSwipeID(EzCP config) => EzCM.get(rightSwipeIDKey);

bool listIcons(EzCP config) => _cache(config)._design.listIcons;
LabelType listLabels(EzCP config) => _cache(config)._design.listLabels;
bool elevatedLists(EzCP config) => _cache(config)._design.elevatedLists;
ButtonType listBT(EzCP config) => _cache(config)._design.listBT;

bool folderIcons(EzCP config) => _cache(config)._design.folderIcons;
LabelType folderLabels(EzCP config) => _cache(config)._design.folderLabels;
bool elevatedFolders(EzCP config) => _cache(config)._design.elevatedFolders;
ButtonType folderBT(EzCP config) => _cache(config)._design.folderBT;

bool wideTiles(EzCP config) => _cache(config)._design.wideTiles;
double appIconSize(EzCP config) => config.iconSize + config.padding;

DateType homeDate(EzCP config) => _cache(config)._design.homeDate;
bool homeTime(EzCP config) => _cache(config)._design.homeTime;

ListAlignment hAlign(EzCP config) => _cache(config)._design.horizontalAlign;
ListAlignment vAlign(EzCP config) => _cache(config)._design.verticalAlign;

bool authToEdit(EzCP config) => _cache(config)._security.authToEdit;
bool authForHidden(EzCP config) => _cache(config)._security.authForHidden;
Duration authTimeout(EzCP config) => _cache(config)._security.authTimeout;
