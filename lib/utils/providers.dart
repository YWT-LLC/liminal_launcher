/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
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
  static const EventChannel _appEventChannel = EventChannel('$androidPackage/app_events');
  StreamSubscription<dynamic>? _appEventSubscription;

  // Renamed apps
  final Set<String> _renamedSet = Set<String>.from(EzCM.get(renamedIDsKey));

  // Home apps
  final List<String> _homeList = EzCM.get(homeIDsKey);
  final Set<String> _homeSet = Set<String>.from(EzCM.get(homeIDsKey));

  // Hidden apps
  final List<String> _hiddenList = EzCM.get(hiddenIDsKey);
  final Set<String> _hiddenSet = Set<String>.from(EzCM.get(hiddenIDsKey));

  final Set<String> _banishedSet = Set<String>.from(EzCM.get(banishedIDsKey));

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
        folders.add(item);
        _homeSet
            .addAll(item.split(folderSplit).where((String item) => item.contains(idSplit)).toSet());
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
      ASConfig.lookup(EzCM.get(listSortKey)),
      EzCM.get(ascListKey),
    );

    // Listen //
    _listenToAppEvents();
  }

  void _listenToAppEvents() {
    _appEventSubscription = _appEventChannel.receiveBroadcastStream().listen((dynamic event) async {
      if (event is Map<dynamic, dynamic>) {
        final String eventType = event['eventType'] as String;

        switch (eventType) {
          case 'installed':
            final Map<String, dynamic>? appInfoMap = event['appInfo'] as Map<String, dynamic>?;

            if (appInfoMap != null) await _handleAppInstalled(appInfoMap);
            break;
          case 'uninstalled':
            final String? packageName = event['packageName'] as String?;
            if (packageName == null) return;

            final List<AppInfo> apps =
                _apps.where((AppInfo app) => app.package == packageName).toList();

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
      ASConfig.lookup(EzCM.get(listSortKey)),
      EzCM.get(ascListKey),
    );

    if (EzCM.get(autoAddToHomeKey) == true && !_homeSet.contains(installed.id)) {
      _homeList.add(installed.id);
      _homeSet.add(installed.id);
      await EzCM.setStringList(homeIDsKey, _homeList);
    }

    notifyListeners();
  }

  // Get //

  List<AppInfo> get apps => _apps;
  Map<String, AppInfo> get appMap => _appMap;

  Set<String> get homeSet => _homeSet;
  List<String> get homeList => _homeList;

  Set<String> get hiddenSet => _hiddenSet;

  Set<String> hybridIDs(Set<ListContent> contents) => <String>{
        if (contents.contains(ListContent.home)) ..._homeSet,
        if (contents.contains(ListContent.hidden)) ..._hiddenSet,
        if (contents.contains(ListContent.banished)) ..._banishedSet,
      };

  // Put //

  Future<bool> addHomeApp(String appID) async {
    if (_homeSet.contains(appID)) return false;

    _homeList.add(appID);
    _homeSet.add(appID);

    await EzCM.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> removeHomeApp(String appID, {bool batch = false}) async {
    if (!_homeSet.contains(appID)) return false;

    _homeList.remove(appID);
    _homeSet.remove(appID);

    await EzCM.setStringList(homeIDsKey, _homeList);
    if (!batch) notifyListeners();

    return true;
  }

  Future<void> addHomeFolder() async {
    _homeList.add('Folder$folderSplit$emptyTag');

    await EzCM.setStringList(homeIDsKey, _homeList);
    notifyListeners();
  }

  // Patch //

  void sort(AppSort sort, bool asc) {
    switch (sort) {
      case AppSort.name:
        _apps.sort(
            (AppInfo a, AppInfo b) => (asc) ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

      case AppSort.publisher:
        _apps.sort((AppInfo a, AppInfo b) =>
            (asc) ? a.package.compareTo(b.package) : b.package.compareTo(a.package));

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

  Future<void> reorderHomeItem({required int oldIndex, required int newIndex}) async {
    final String id = _homeList.removeAt(oldIndex);
    _homeList.insert(
      oldIndex < newIndex ? newIndex - 1 : newIndex,
      id,
    );

    await EzCM.setStringList(homeIDsKey, _homeList);
    notifyListeners();
  }

  Future<bool> renameApp({required String appID, required String newName}) async {
    final AppInfo? app = _appMap[appID];
    if (app == null || app.name == newName) return false;

    app.rename = newName;

    _renamedSet.removeWhere((String entry) => entry.startsWith(appID));
    _renamedSet.add(appID + idSplit + newName);

    await EzCM.setStringList(renamedIDsKey, _renamedSet.toList());
    notifyListeners();

    return true;
  }

  Future<bool> renameFolder(String newName, int folderIndex) async {
    final String fullName = _homeList[folderIndex];
    final List<String> parts = fullName.split(folderSplit);
    if (parts[0] == newName) return false;

    final String newFullName =
        (parts.length > 1) ? <String>[newName, ...parts].join(folderSplit) : newName;
    _homeList[folderIndex] = newFullName;

    await EzCM.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<void> updateFolder({
    required String name,
    required int index,
    required List<String> ids,
  }) async {
    final Set<String> newSet = ids.toSet();
    final Set<String> oldSet = _homeList[index].split(folderSplit).sublist(1).toSet();
    oldSet.remove(emptyTag);

    _homeList[index] = name + folderSplit + (ids.isEmpty ? emptyTag : ids.join(folderSplit));

    for (final String id in oldSet.difference(newSet)) {
      _homeSet.remove(id);
    }
    for (final String id in newSet.difference(oldSet)) {
      _homeSet.add(id);
    }

    await EzCM.setStringList(homeIDsKey, _homeList);
    notifyListeners();
  }

  Future<bool> hideApp(EzCP config, String appID) async {
    if (_hiddenSet.contains(appID)) return false;

    if (_hiddenSet.isEmpty && ezRootNav.currentContext != null) {
      await showDialog(
        context: ezRootNav.currentContext!,
        builder: (_) => EzAlertDialog(
          config,
          title: const Text('Reminder', textAlign: TextAlign.center),
          content: const Text(
            'Swipe up while editing to open the hidden apps list.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    _hiddenList.add(appID);
    _hiddenSet.add(appID);

    await EzCM.setStringList(hiddenIDsKey, _hiddenList);

    final bool notified = await removeHomeApp(appID);
    if (!notified) notifyListeners();

    return true;
  }

  Future<bool> showApp(String appID, {bool batch = false}) async {
    if (!_hiddenSet.contains(appID)) return false;

    _hiddenList.remove(appID);
    _hiddenSet.remove(appID);

    await EzCM.setStringList(hiddenIDsKey, _hiddenList);
    if (!batch) notifyListeners();

    return true;
  }

  Future<bool> banishApp(EzCP config, String appID) async {
    if (_banishedSet.contains(appID) ||
        ezRootNav.currentContext == null ||
        !ezRootNav.currentContext!.mounted) {
      return false;
    }
    final BuildContext currContext = ezRootNav.currentContext!;

    final AppInfo? currApp = _appMap[appID];
    if (currApp == null) return false;
    final String name = currApp.name;

    final bool confirmed = await showDialog(
      context: currContext,
      builder: (BuildContext dCon) => EzAlertDialog(
        config,
        title: Text(
          'Banish $name?',
          textAlign: TextAlign.center,
        ),
        content: _banishedSet.isEmpty
            ? Text(
                '''When you banish an app, it will still be installed but not appear in Liminal at all.
Banished apps can only be opened from the system settings, or via app link.

To restore $name, you will have to uninstall it from the system settings, then reinstall.

Banishing is useful for utility apps that also waste time. For example, you may want to banish your web browser(s).
That way, you can use online menus when you go out, and reduce doom scrolling when you stay in.

Reminder: banishing is just for UX, not for security.
For example: if an app has always on location permissions, banishing it will not affect that.''',
                textAlign: TextAlign.center,
              )
            : Text(
                'To restore $name, you will have to uninstall it from the system settings, then reinstall.',
                textAlign: TextAlign.center,
              ),
        actions: ezActionPair(
          config,
          onConfirm: () => Navigator.of(dCon).pop(true),
          confirmMsg: config.ezL10n.gContinue,
          confirmIsDestructive: true,
          onDeny: () => Navigator.of(dCon).pop(false),
        ),
        needsClose: false,
      ),
    );
    if (!confirmed) return false;

    _banishedSet.add(appID);
    await EzCM.setStringList(banishedIDsKey, _banishedSet.toList());

    final bool notified = await removeHomeApp(appID);
    if (!notified) notifyListeners();

    return true;
  }

  // Delete //

  Future<void> removeDeleted(String appID) async {
    if (_banishedSet.contains(appID)) {
      _banishedSet.remove(appID);
      await EzCM.setStringList(banishedIDsKey, _banishedSet.toList());
    }

    await showApp(appID, batch: true);
    await removeHomeApp(appID, batch: true);

    _apps.remove(_appMap[appID]);
    _appMap.remove(appID);

    notifyListeners();
  }

  Future<bool> deleteFolder(int index) async {
    if (index >= _homeList.length) return false;

    final List<String> ids = _homeList[index].split(':').sublist(1);
    for (final String id in ids) {
      _homeSet.remove(id);
    }

    _homeList.removeAt(index);
    await EzCM.setStringList(homeIDsKey, _homeList);

    notifyListeners();
    return true;
  }

  Future<void> reset() async {
    _renamedSet.clear();
    _homeSet.clear();
    _homeList.clear();
    _hiddenSet.clear();
    _hiddenList.clear();
    _banishedSet.clear();

    sort(
      ASConfig.lookup(EzCM.getDefault(listSortKey)),
      EzCM.getDefault(ascListKey),
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _appEventSubscription?.cancel();
    super.dispose();
  }
}
