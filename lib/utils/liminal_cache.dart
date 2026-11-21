/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class LiminalCache extends EzAppCache {
  Locale _locale;
  Lang _l10n;

  late DesignCache _design;
  late SecureCache _security;

  LiminalCache(Locale locale, Lang l10n)
      : _locale = locale,
        _l10n = l10n;

  @override
  void init(EzProvider config) => _buildLocalCache(config);

  @override
  Future<void> rebuild(EzProvider config) async {
    if (_locale != config.locale) {
      _locale = config.locale;
      _l10n = await Lang.delegate.load(config.locale);
    }

    await _buildLocalCache(config);

    // For when nothing is being drawn by Flutter. Don't want jump scares.
    if (config.backgroundImagePath != noImageValue) unawaited(setBlankWallpaper());
  }

  Future<void> _buildLocalCache(EzProvider config) async {
    // Design cache
    if (config.isDark) {
      final bool listIcons = EzManager.get(darkListIconKey);
      final LabelType listLabels = LTConfig.safeLookup(EzManager.get(darkListLabelKey));
      final bool elevatedLists = EzManager.get(darkElevatedListKey);

      final bool folderIcons = EzManager.get(darkFolderIconKey);
      final LabelType folderLabels = LTConfig.safeLookup(EzManager.get(darkFolderLabelKey));
      final bool elevatedFolders = EzManager.get(darkElevatedFolderKey);

      _design = DesignCache(
        wallpaper: (config.backgroundImagePath == noImageValue) ? null : config.screenDecoration,
        pages: EzManager.get(darkPagesKey),
        wideTiles: EzManager.get(darkWideTilesKey),
        horizontalAlign:
            LAConfig.lookup(EzManager.get(darkHorizontalAlignKey)) ?? ListAlignment.center,
        verticalAlign: LAConfig.lookup(EzManager.get(darkVerticalAlignKey)) ?? ListAlignment.start,
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
      );
    } else {
      final bool listIcons = EzManager.get(lightListIconKey);
      final LabelType listLabels = LTConfig.safeLookup(EzManager.get(lightListLabelKey));
      final bool elevatedLists = EzManager.get(lightElevatedListKey);

      final bool folderIcons = EzManager.get(lightFolderIconKey);
      final LabelType folderLabels = LTConfig.safeLookup(EzManager.get(lightFolderLabelKey));
      final bool elevatedFolders = EzManager.get(lightElevatedFolderKey);

      _design = DesignCache(
        wallpaper: (config.backgroundImagePath == noImageValue) ? null : config.screenDecoration,
        pages: EzManager.get(lightPagesKey),
        wideTiles: EzManager.get(lightWideTilesKey),
        horizontalAlign:
            LAConfig.lookup(EzManager.get(lightHorizontalAlignKey)) ?? ListAlignment.center,
        verticalAlign: LAConfig.lookup(EzManager.get(lightVerticalAlignKey)) ?? ListAlignment.start,
        listIcons: listIcons,
        listLabels: listLabels,
        elevatedLists: elevatedLists,
        listBT: BTConfig.build(listLabels, icons: listIcons, elevated: elevatedLists),
        folderIcons: folderIcons,
        folderLabels: folderLabels,
        elevatedFolders: elevatedFolders,
        folderBT: BTConfig.build(folderLabels, icons: folderIcons, elevated: elevatedFolders),
      );
    }

    if (EzManager.get(config.isDark ? darkHideStatusKey : lightHideStatusKey) == true) {
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

    // Secure cache
    final bool defATE = limSecDef[authToEditKey] as bool;
    final bool defAFH = limSecDef[authForHiddenKey] as bool;
    final int defAT = limSecDef[authTimeoutKey] as int;

    _security = SecureCache(
      authToEdit: bool.tryParse(await EzManager.secGet(authToEditKey)) ?? defATE,
      resetAfterEdit: EzManager.get(resetAfterEditKey),
      authForHidden: bool.tryParse(await EzManager.secGet(authForHiddenKey)) ?? defAFH,
      resetAfterOpened: EzManager.get(resetAfterOpenedKey),
      authTimeout: Duration(minutes: int.tryParse(await EzManager.secGet(authTimeoutKey)) ?? defAT),
    );
  }
}

class DesignCache {
  final BoxDecoration? wallpaper;
  final bool pages;
  final bool wideTiles;

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

  DesignCache({
    required this.wallpaper,
    required this.pages,
    required this.wideTiles,
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
  });
}

class SecureCache {
  final bool _authToEdit;
  final bool _resetAfterEdit;

  final bool _authForHidden;
  final bool _resetAfterOpened;

  final Duration _authTimeout;

  SecureCache({
    required bool authToEdit,
    required bool resetAfterEdit,
    required bool authForHidden,
    required bool resetAfterOpened,
    required Duration authTimeout,
  })  : _authToEdit = authToEdit,
        _resetAfterEdit = resetAfterEdit,
        _authForHidden = authForHidden,
        _resetAfterOpened = resetAfterOpened,
        _authTimeout = authTimeout;

  bool get authToEdit => _authToEdit;
  bool get resetAfterEdit => _resetAfterEdit;

  bool get authForHidden => _authForHidden;
  bool get resetAfterOpened => _resetAfterOpened;

  Duration get authTimeout => _authTimeout;
}

// EzManager aliases //

bool get interlinked => EzManager.get(interlinkedKey);

bool get homeRipple => EzManager.get(homeRippleKey);
bool get listRipple => EzManager.get(listRippleKey);

String get leftSwipeID => EzManager.get(leftSwipeIDKey);
String get rightSwipeID => EzManager.get(rightSwipeIDKey);

// EzProvider aliases //

LiminalCache _cache(EzProvider config) => config.appCache! as LiminalCache;

Lang l10n(EzProvider config) => _cache(config)._l10n;
double appIconSize(EzProvider config) => config.iconSize + config.padding;

BoxDecoration? wallpaper(EzProvider config) => _cache(config)._design.wallpaper;
bool pages(EzProvider config) => _cache(config)._design.pages;
bool wideTiles(EzProvider config) => _cache(config)._design.wideTiles;

ListAlignment horizontalAlign(EzProvider config) => _cache(config)._design.horizontalAlign;
ListAlignment verticalAlign(EzProvider config) => _cache(config)._design.verticalAlign;

bool listIcons(EzProvider config) => _cache(config)._design.listIcons;
LabelType listLabels(EzProvider config) => _cache(config)._design.listLabels;
bool elevatedLists(EzProvider config) => _cache(config)._design.elevatedLists;
ButtonType listBT(EzProvider config) => _cache(config)._design.listBT;

bool folderIcons(EzProvider config) => _cache(config)._design.folderIcons;
LabelType folderLabels(EzProvider config) => _cache(config)._design.folderLabels;
bool elevatedFolders(EzProvider config) => _cache(config)._design.elevatedFolders;
ButtonType folderBT(EzProvider config) => _cache(config)._design.folderBT;

bool authToEdit(EzProvider config) => _cache(config)._security.authToEdit;
bool resetAfterEdit(EzProvider config) => _cache(config)._security.resetAfterEdit;

bool authForHidden(EzProvider config) => _cache(config)._security.authForHidden;
bool resetAfterOpened(EzProvider config) => _cache(config)._security.resetAfterOpened;

Duration authTimeout(EzProvider config) => _cache(config)._security.authTimeout;
