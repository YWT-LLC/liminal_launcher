/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// ,
const String folderSplit = ',';

/// empty
const String emptyTag = 'empty';

class AppInfoProvider extends ChangeNotifier {
  // Construct //

  // App info
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  // App listeners
  static const EventChannel _appEventChannel =
      EventChannel('net.empathetech.liminal/app_events');
  StreamSubscription<dynamic>? _appEventSubscription;

  // Renamed apps
  final Set<String> _renamedSet = Set<String>.from(EzConfig.get(renamedIDsKey));

  // Home apps
  final Set<String> _homeSet = Set<String>.from(EzConfig.get(homeIDsKey));
  final List<String> _homeList = EzConfig.get(homeIDsKey);

  // Hidden apps
  final Set<String> _hiddenSet = Set<String>.from(EzConfig.get(hiddenIDsKey));
  final List<String> _hiddenList = EzConfig.get(hiddenIDsKey);

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{
          for (AppInfo app in apps) app.id: app,
        } {
    // Iterate through the home set and split any folders
    final Set<String> homeCopy = Set<String>.from(_homeSet);
    final Set<String> folders = <String>{};

    for (final String item in homeCopy) {
      if (item.contains(folderSplit)) {
        _homeSet.addAll(item
            .split(folderSplit)
            .where((String item) => item.contains(idSplit))
            .toSet());

        folders.add(item);
      }
    }
    _homeSet.removeAll(folders);

    // Gather renamed apps
    if (_renamedSet.isNotEmpty) {
      for (final String csv in _renamedSet) {
        final List<String> parts = csv.split(idSplit);
        if (parts.length == 3) {
          final AppInfo? app = _appMap[parts[0] + idSplit + parts[1]];
          if (app != null) {
            app.rename = parts[2];
          }
        }
      }
    }

    // Sort based on the user's preferences
    sort(
      AppSortConfig.fromValue(EzConfig.get(listSortKey)),
      EzConfig.get(ascListKey),
    );

    // Listen //
    _listenToAppEvents();
  }

  void _listenToAppEvents() {
    _appEventSubscription =
        _appEventChannel.receiveBroadcastStream().listen((dynamic event) async {
      if (event is Map<dynamic, dynamic>) {
        final String eventType = event['eventType'] as String;

        switch (eventType) {
          case 'installed':
            final Map<String, dynamic>? appInfoMap =
                event['appInfo'] as Map<String, dynamic>?;

            if (appInfoMap != null) await _handleAppInstalled(appInfoMap);
            break;
          case 'uninstalled':
            final String? packageName = event['packageName'] as String?;
            if (packageName == null) return;

            final List<AppInfo> apps = _apps
                .where((AppInfo app) => app.package == packageName)
                .toList();

            if (apps.isNotEmpty) {
              for (final AppInfo app in apps) {
                await removeDeleted(app.id);
              }
            }
            break;
        }
      }
    }, onError: (dynamic error) {
      ezLog('Error listening to app events: $error');
    });
  }

  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(
      AppSortConfig.fromValue(EzConfig.get(listSortKey)),
      EzConfig.get(ascListKey),
    );

    if (EzConfig.get(autoAddToHomeKey) == true &&
        !_homeSet.contains(installed.id)) {
      _homeList.add(installed.id);
      _homeSet.add(installed.id);
      await EzConfig.setStringList(homeIDsKey, _homeList);
    }

    notifyListeners();
  }

  // Get //

  List<AppInfo> get apps => _apps;
  Map<String, AppInfo> get appMap => _appMap;

  Set<String> get renamed => _renamedSet;

  List<String> get homeList => _homeList;
  Set<String> get homeSet => _homeSet;

  List<String> get hiddenList => _hiddenList;
  Set<String> get hiddenSet => _hiddenSet;

  // Post //

  Future<void> addHomeFolder() async {
    _homeList.add('Folder$folderSplit$emptyTag');

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();
  }

  // Put //

  void sort(AppSort sort, bool asc) {
    switch (sort) {
      case AppSort.name:
        _apps.sort((AppInfo a, AppInfo b) =>
            (asc) ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

      case AppSort.publisher:
        _apps.sort((AppInfo a, AppInfo b) => (asc)
            ? a.package.compareTo(b.package)
            : b.package.compareTo(a.package));

      case AppSort.date:
        _apps.sort((AppInfo a, AppInfo b) => (asc)
            ? a.installDate.compareTo(b.installDate)
            : b.installDate.compareTo(a.installDate));

      case AppSort.size:
        _apps.sort((AppInfo a, AppInfo b) => (asc)
            ? a.packageSize.compareTo(b.packageSize)
            : b.packageSize.compareTo(a.packageSize));
    }
    notifyListeners();
  }

  Future<bool> addHomeApp(String appID) async {
    if (_homeSet.contains(appID)) return false;

    _homeList.add(appID);
    _homeSet.add(appID);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> removeHomeApp(String appID) async {
    if (!_homeSet.contains(appID)) return false;

    _homeList.remove(appID);
    _homeSet.remove(appID);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<int?> addToFolder(String appID, int folderIndex) async {
    int toReturn = 0;
    _homeList[folderIndex] = (homeList[folderIndex] + folderSplit + appID)
        .replaceAll(folderSplit + emptyTag, '');

    if (_homeSet.contains(appID)) {
      final int appIndex = _homeList.indexOf(appID);
      _homeList.removeAt(appIndex);

      if (appIndex < folderIndex) toReturn = -1;
    } else {
      _homeSet.add(appID);
    }

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return toReturn;
  }

  Future<bool> removeFromFolder(String appID, int folderIndex) async {
    _homeList[folderIndex] = _homeList[folderIndex].replaceFirst(
      folderSplit + appID,
      '',
    );
    _homeList.add(appID);

    if (!_homeList[folderIndex].contains(folderSplit)) {
      _homeList[folderIndex] = '${_homeList[folderIndex]}$folderSplit$emptyTag';
    }

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  // Patch //

  Future<bool> hideApp(String appID) async {
    if (_hiddenSet.contains(appID)) return false;

    _hiddenList.add(appID);
    _hiddenSet.add(appID);

    await EzConfig.setStringList(hiddenIDsKey, _hiddenList);

    final bool notified = await removeHomeApp(appID);
    if (!notified) notifyListeners();

    return true;
  }

  Future<bool> showApp(String appID) async {
    if (!_hiddenSet.contains(appID)) return false;

    _hiddenList.remove(appID);
    _hiddenSet.remove(appID);

    await EzConfig.setStringList(hiddenIDsKey, _hiddenList);
    notifyListeners();

    return true;
  }

  Future<bool> renameApp({
    required String appID,
    required String newName,
  }) async {
    final AppInfo? app = _appMap[appID];
    if (app == null || app.name == newName) return false;

    app.rename = newName;

    _renamedSet.removeWhere((String entry) => entry.startsWith(appID));
    _renamedSet.add(appID + idSplit + newName);

    await EzConfig.setStringList(renamedIDsKey, _renamedSet.toList());
    notifyListeners();

    return true;
  }

  Future<bool> renameFolder(String newName, int folderIndex) async {
    final String fullName = _homeList[folderIndex];
    final List<String> parts = fullName.split(folderSplit);
    if (parts[0] == newName) return false;

    final String newFullName = (parts.length > 1)
        ? <String>[newName, ...parts].join(folderSplit)
        : newName;
    _homeList[folderIndex] = newFullName;

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> reorderHomeItem({
    required int oldIndex,
    required int newIndex,
  }) async {
    if (oldIndex == newIndex) return false;
    if (newIndex > oldIndex) newIndex -= 1;

    final String id = _homeList.removeAt(oldIndex);
    _homeList.insert(newIndex, id);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> reorderFolderItem({
    required int oldIndex,
    required int newIndex,
    required int folderIndex,
  }) async {
    if (oldIndex == newIndex) return false;
    if (newIndex > oldIndex) newIndex -= 1;

    final List<String> folderList = _homeList[folderIndex].split(folderSplit);
    final String id = folderList.removeAt(oldIndex);
    folderList.insert(newIndex, id);

    final String newFullName = folderList.join(folderSplit);
    _homeList[folderIndex] = newFullName;

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  // Delete //

  Future<void> removeDeleted(String appID) async {
    await showApp(appID);
    await removeHomeApp(appID);
    _apps.remove(_appMap[appID]);
    _appMap.remove(appID);

    notifyListeners();
  }

  Future<bool> deleteFolder(String fullName) async {
    try {
      final List<String> ids = fullName.split(':').sublist(1);
      for (final String id in ids) {
        _homeSet.remove(id);
      }

      _homeList.remove(fullName);
      await EzConfig.setStringList(homeIDsKey, _homeList);

      notifyListeners();
      return true;
    } catch (e) {
      ezLog('Error deleting folder...\n$e');
      return false;
    }
  }

  Future<void> reset() async {
    _renamedSet.clear();
    _homeSet.clear();
    _homeList.clear();
    _hiddenSet.clear();
    _hiddenList.clear();

    sort(
      AppSortConfig.fromValue(EzConfig.getDefault(listSortKey)),
      EzConfig.getDefault(ascListKey),
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _appEventSubscription?.cancel();
    super.dispose();
  }
}
