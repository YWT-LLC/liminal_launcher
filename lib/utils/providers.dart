/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppInfoProvider extends ChangeNotifier {
  // Construct //

  // All
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  static const EventChannel _appEventChannel = EventChannel('$androidPackage/app_events');
  StreamSubscription<dynamic>? _appEventSubscription;

  // Renamed
  final Set<String> _renamedSet = Set<String>.from(EzCM.get(renamedIDsKey));

  // Hidden
  final Set<String> _hiddenSet = Set<String>.from(EzCM.get(hiddenIDsKey));

  // Banished
  final Set<String> _banishedSet = Set<String>.from(EzCM.get(banishedIDsKey));

  // Home
  late List<List<String>> _darkHomeMatrix;
  late List<List<String>> _lightHomeMatrix;

  Set<String> _darkHomeSet = <String>{};
  Set<String> _lightHomeSet = <String>{};

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{for (AppInfo app in apps) app.id: app} {
    // Build the matrices
    _darkHomeMatrix = _buildHomeMatrix(EzCM.get(darkHomeDataKey));
    _lightHomeMatrix = _buildHomeMatrix(EzCM.get(lightHomeDataKey));

    // Iterate through the sub-lists to properly populate the home sets
    for (final List<String> lane in _darkHomeMatrix) {
      for (final String entry in lane) {
        // TODO: svvitch (with more (&& below))
        if (entry.contains(folderSplit)) {
          final List<String> items = entry.split(folderSplit);
          if (items.length > 2) _darkHomeSet.addAll(items.sublist(2));
        } else {
          _darkHomeSet.add(entry);
        }
      }
    }

    for (final List<String> lane in _lightHomeMatrix) {
      for (final String entry in lane) {
        if (entry.contains(folderSplit)) {
          final List<String> items = entry.split(folderSplit);
          if (items.length > 2) _lightHomeSet.addAll(items.sublist(2));
        } else {
          _lightHomeSet.add(entry);
        }
      }
    }

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
    sort(ASConfig.lookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));

    // Listen to events (installs, external deletes, etc.)
    _listenToAppEvents();
  }

  void _listenToAppEvents() {
    _appEventSubscription = _appEventChannel.receiveBroadcastStream().listen(
      (dynamic event) async {
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

              final List<AppInfo> uninstalled =
                  _apps.where((AppInfo app) => app.package == packageName).toList();

              if (uninstalled.isNotEmpty) {
                for (final AppInfo app in uninstalled) {
                  await _removeDeletedApp(app.id);
                }
              }
              break;
          }
        }
      },
      onError: (dynamic error) => ezLog('Error listening to app events: $error'),
    );
  }

  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(ASConfig.lookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));
    notifyListeners();
  }

  // Get //

  List<AppInfo> get apps => _apps;
  Map<String, AppInfo> get appMap => _appMap;

  Set<String> get hiddenSet => _hiddenSet;

  Set<String> homeSet(EzCP config) => config.isDark ? _darkHomeSet : _lightHomeSet;

  int numLanes(EzCP config) => config.isDark ? _darkHomeMatrix.length : _lightHomeMatrix.length;

  List<String> homeList(EzCP config, int lane) =>
      config.isDark ? _darkHomeMatrix[lane] : _darkHomeMatrix[lane];

  Set<String> hybridIDs(EzCP config, ListConfig listConfig) => <String>{
        if (listConfig.localContent != null) ...listConfig.localContent!.value,
        if (listConfig.listContent.contains(ListContent.home))
          ...(config.isDark ? _darkHomeSet : _lightHomeSet),
        if (listConfig.listContent.contains(ListContent.hidden)) ..._hiddenSet,
        if (listConfig.listContent.contains(ListContent.banished)) ..._banishedSet,
      };

  // Put //

  bool _addThrottle = false;

  Future<void> _added(EzCP config) async {
    if (_addThrottle) return;

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Center(
              child: EzIconButton(config, icon: const Icon(Icons.check), onPressed: doNothing),
            ),
          ),
        ),
      ),
    );

    _addThrottle = true;
    ezRootNav.currentState?.overlay?.insert(entry);

    await wait(1);

    entry.remove();
    _addThrottle = false;
  }

  Future<void> addApp(EzCP config, {required int lane, required String id}) async {
    if ((interlinked || config.isDark) && !_darkHomeSet.contains(id)) {
      _darkHomeMatrix[lane].add(id);
      _darkHomeSet.add(id);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if ((interlinked || !config.isDark) && !_lightHomeSet.contains(id)) {
      _lightHomeMatrix[lane].add(id);
      _lightHomeSet.add(id);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  Future<void> addFolder(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].add('Folder$folderSplit${Icons.folder_outlined.codePoint}');

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].add('Folder$folderSplit${Icons.folder_outlined.codePoint}');

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  Future<void> addWidget(
    EzCP config,
    int lane,
    WidWidGetGet type,
    WidgetSize size, {
    List<String>? extra,
  }) async {
    final List<String> parts = (extra == null)
        ? <String>[type.value, size.value]
        : <String>[type.value, size.value, ...extra];

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].add(parts.join(widgetSplit));
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].add(parts.join(widgetSplit));
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  Future<void> addClock(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.clock.value,
      'true',
      TxtStile.headline.value,
      DateType.compact.value,
      TxtStile.label.value
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].add(entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].add(entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  Future<int> addSpacer(EzCP config, int lane) async {
    int pos = 0;

    if (interlinked || config.isDark) {
      pos = _darkHomeMatrix[lane].length;
      _darkHomeMatrix[lane].add(<String>[
        config.spacing.toString(),
        appIconSize(config).toString(),
      ].join(spacerSplit));

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      pos = _lightHomeMatrix[lane].length;
      _lightHomeMatrix[lane].add(<String>[
        config.spacing.toString(),
        appIconSize(config).toString(),
      ].join(spacerSplit));

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    return pos;
  }

  Future<void> addHomeLane(EzCP config) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix.add(<String>[]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.add(<String>[]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  // Patch //

  void sort(AppSort sort, bool asc) {
    _apps.sort(switch (sort) {
      AppSort.name => (AppInfo a, AppInfo b) =>
          asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
      AppSort.publisher => (AppInfo a, AppInfo b) =>
          asc ? a.package.compareTo(b.package) : b.package.compareTo(a.package),
      AppSort.date => (AppInfo a, AppInfo b) =>
          asc ? a.installDate.compareTo(b.installDate) : b.installDate.compareTo(a.installDate),
      AppSort.size => (AppInfo a, AppInfo b) =>
          asc ? a.packageSize.compareTo(b.packageSize) : b.packageSize.compareTo(a.packageSize),
    });

    notifyListeners();
  }

  Future<bool> renameApp({required String appID, required String newName}) async {
    final AppInfo? app = _appMap[appID];
    if (app == null || app.name == newName) return false;

    app.rename = newName;

    _renamedSet.removeWhere((String entry) => entry.startsWith(appID));
    _renamedSet.add(appID + idSplit + newName);
    unawaited(EzCM.setStringList(renamedIDsKey, _renamedSet.toList()));

    notifyListeners();
    return true;
  }

  Future<void> renameFolder(
    EzCP config,
    String name,
    IconData icon, {
    required int lane,
    required int index,
  }) async {
    if (interlinked || config.isDark) {
      final List<String> parts = _darkHomeMatrix[lane][index].split(folderSplit);

      parts[0] = name;
      parts[1] = icon.codePoint.toString();
      _darkHomeMatrix[lane][index] = parts.join(folderSplit);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> parts = _lightHomeMatrix[lane][index].split(folderSplit);

      parts[0] = name;
      parts[1] = icon.codePoint.toString();
      _lightHomeMatrix[lane][index] = parts.join(folderSplit);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  Future<void> updateWidget(
    EzCP config,
    WidWidGetGet type,
    WidgetSize size, {
    required List<String>? extra,
    required int lane,
    required int index,
  }) async {
    final List<String> parts = (extra == null)
        ? <String>[type.value, size.value]
        : <String>[type.value, size.value, ...extra];

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = parts.join(widgetSplit);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = parts.join(widgetSplit);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    // Don't notifyListeners();
  }

  Future<void> updateClock(
    EzCP config,
    List<String> extra, {
    required int lane,
    required int index,
  }) async {
    final String entry = <String>[WidWidGetGet.clock.value, ...extra].join(widgetSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    // Don't notifyListeners();
  }

  void reorderHomeList(
    EzCP config, {
    required int lane,
    required int oldIndex,
    required int newIndex,
  }) {
    if (interlinked || config.isDark) {
      final String element = _darkHomeMatrix[lane].removeAt(oldIndex);
      _darkHomeMatrix[lane].insert(newIndex, element);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final String element = _lightHomeMatrix[lane].removeAt(oldIndex);
      _lightHomeMatrix[lane].insert(newIndex, element);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    // don't notifyListeners(); twill happen when the user exits edit mode
  }

  Future<void> updateFolder(
    EzCP config, {
    required int lane,
    required int index,
    required String name,
    required IconData icon,
    required List<String> ids,
  }) async {
    if (interlinked || config.isDark) {
      // Get the old && new ID sets
      final List<String> oldIDs = _darkHomeMatrix[lane][index].split(folderSplit);
      final Set<String> oldSet = oldIDs.length > 2 ? oldIDs.sublist(2).toSet() : <String>{};
      final Set<String> newSet = ids.toSet();

      // Update the matrix entry
      _darkHomeMatrix[lane][index] = <String>[
        name,
        icon.codePoint.toString(),
        if (ids.isNotEmpty) ...ids,
      ].join(folderSplit);

      // Remove those removed
      _darkHomeSet.removeAll(oldSet.difference(newSet));

      // Add those added
      for (final String id in newSet.difference(oldSet)) {
        final bool wasInList = _darkHomeMatrix[lane].remove(id);
        if (!wasInList) _darkHomeSet.add(id);
      }

      // Save results
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      // Get the old && new ID sets
      final List<String> oldIDs = _lightHomeMatrix[lane][index].split(folderSplit);
      final Set<String> oldSet = oldIDs.length > 2 ? oldIDs.sublist(2).toSet() : <String>{};
      final Set<String> newSet = ids.toSet();

      // Update the matrix entry
      _lightHomeMatrix[lane][index] = <String>[
        name,
        icon.codePoint.toString(),
        if (ids.isNotEmpty) ...ids,
      ].join(folderSplit);

      // Remove those removed
      _lightHomeSet.removeAll(oldSet.difference(newSet));

      // Add those added
      for (final String id in newSet.difference(oldSet)) {
        final bool wasInList = _lightHomeMatrix[lane].remove(id);
        if (!wasInList) _lightHomeSet.add(id);
      }

      // Save results
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Assumes index checks have already been done
  Future<void> moveItemUp(EzCP config, {required int lane, required int index}) async {
    if (interlinked || config.isDark) {
      final String item = _darkHomeMatrix[lane].removeAt(index);
      _darkHomeMatrix[lane + 1].add(item);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final String item = _lightHomeMatrix[lane].removeAt(index);
      _lightHomeMatrix[lane + 1].add(item);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Assumes index checks have already been done
  Future<void> moveItemDown(EzCP config, {required int lane, required int index}) async {
    if (interlinked || config.isDark) {
      final String item = _darkHomeMatrix[lane].removeAt(index);
      _darkHomeMatrix[lane - 1].add(item);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final String item = _lightHomeMatrix[lane].removeAt(index);
      _lightHomeMatrix[lane - 1].add(item);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  Future<void> moveLaneUp(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      final List<String> col = _darkHomeMatrix.removeAt(lane);
      _darkHomeMatrix.insert(lane + 1, col);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> col = _lightHomeMatrix.removeAt(lane);
      _lightHomeMatrix.insert(lane + 1, col);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  Future<void> moveLaneDown(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      final List<String> col = _darkHomeMatrix.removeAt(lane);
      _darkHomeMatrix.insert(lane - 1, col);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> col = _lightHomeMatrix.removeAt(lane);
      _lightHomeMatrix.insert(lane - 1, col);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  Future<void> hideApp(
    EzCP config, {
    required BuildContext context,
    required String id,
    int? lane,
    int? index,
  }) async {
    if (_hiddenSet.contains(id)) return;
    if (_hiddenSet.isEmpty) {
      await showDialog(
        context: context,
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

    _hiddenSet.add(id);
    unawaited(EzCM.setStringList(hiddenIDsKey, _hiddenSet.toList()));

    final bool notified = await removeHomeApp(config, id: id, lane: lane, index: index);
    if (!notified) notifyListeners();
  }

  Future<bool> showApp(String appID, {bool batch = false}) async {
    if (!_hiddenSet.contains(appID)) return false;
    _hiddenSet.remove(appID);

    unawaited(EzCM.setStringList(hiddenIDsKey, _hiddenSet.toList()));
    if (!batch) notifyListeners();

    return true;
  }

  Future<bool> banishApp(
    EzCP config, {
    required BuildContext context,
    required String id,
    int? lane,
    int? index,
  }) async {
    if (_banishedSet.contains(id)) return false;

    final AppInfo? currApp = _appMap[id];
    if (currApp == null) return false;
    final String name = currApp.name;

    final bool confirmed = await showDialog(
      context: context,
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

    _banishedSet.add(id);
    unawaited(EzCM.setStringList(banishedIDsKey, _banishedSet.toList()));

    final bool notified = await removeHomeApp(config, id: id, lane: lane, index: index);
    if (!notified) notifyListeners();

    return true;
  }

  Future<void> cloneMatrix(bool keepDark) async {
    if (keepDark) {
      _lightHomeMatrix = List<List<String>>.from(_darkHomeMatrix);
      _lightHomeSet = Set<String>.from(_darkHomeSet);

      unawaited(_saveLightMatrix(_lightHomeMatrix));
    } else {
      _darkHomeMatrix = List<List<String>>.from(_lightHomeMatrix);
      _darkHomeSet = Set<String>.from(_lightHomeSet);

      unawaited(_saveDarkMatrix(_darkHomeMatrix));
    }

    notifyListeners();
  }

  // Delete //

  Future<bool> removeHomeApp(
    EzCP config, {
    int? lane,
    int? index,
    required String id,
    bool batch = false,
  }) async {
    bool found = false;

    if (interlinked || config.isDark) {
      found = _darkHomeSet.contains(id);
      _darkHomeSet.remove(id);

      if (lane != null) {
        (index == null) ? _darkHomeMatrix[lane].remove(id) : _darkHomeMatrix[lane].removeAt(index);
      } else {
        for (final List<String> subList in _darkHomeMatrix) {
          final bool removed = subList.remove(id);
          if (removed) break;
        }
      }

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      found = _lightHomeSet.contains(id);
      _lightHomeSet.remove(id);

      if (lane != null) {
        (index == null)
            ? _lightHomeMatrix[lane].remove(id)
            : _lightHomeMatrix[lane].removeAt(index);
      } else {
        for (final List<String> subList in _lightHomeMatrix) {
          final bool removed = subList.remove(id);
          if (removed) break;
        }
      }

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    if (!batch) notifyListeners();
    return found;
  }

  Future<void> deleteFolder(
    EzCP config, {
    required int lane,
    required int index,
    bool batch = false,
  }) async {
    if (interlinked || config.isDark) {
      final List<String> entries = _darkHomeMatrix[lane][index].split(folderSplit);

      if (entries.isNotEmpty) {
        for (final String entry in entries) {
          _darkHomeSet.remove(entry);
        }
      }
      _darkHomeMatrix[lane].removeAt(index);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> entries = _lightHomeMatrix[lane][index].split(folderSplit);

      if (entries.isNotEmpty) {
        for (final String entry in entries) {
          _lightHomeSet.remove(entry);
        }
      }
      _lightHomeMatrix[lane].removeAt(index);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    if (!batch) notifyListeners();
  }

  /// Widget or Spacer: the things that don't need any extra tracking
  Future<void> deleteWS(
    EzCP config, {
    required int lane,
    required int index,
    bool batch = false,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].removeAt(index);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].removeAt(index);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    if (!batch) notifyListeners();
  }

  Future<void> deleteLane(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      final List<String> entries = _darkHomeMatrix[lane];

      for (int index = 0; index < entries.length; index++) {
        if (entries[index].isEmpty) continue;

        for (final String entry in entries) {
          final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
          final String? delim = splitMatch?.group(0);

          switch (delim) {
            case idSplit:
              await removeHomeApp(config, lane: lane, index: index, id: entry, batch: true);
              break;

            case folderSplit:
              await deleteFolder(config, lane: lane, index: index, batch: true);
              break;

            default:
              // Widgets and Spacers don't need extra cleanup
              break;
          }
        }
      }
      _darkHomeMatrix.removeAt(lane);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> entries = _lightHomeMatrix[lane];

      for (int index = 0; index < entries.length; index++) {
        if (entries[index].isEmpty) continue;

        for (final String entry in entries) {
          final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
          final String? delim = splitMatch?.group(0);

          switch (delim) {
            case idSplit:
              await removeHomeApp(config, lane: lane, index: index, id: entry, batch: true);
              break;

            case folderSplit:
              await deleteFolder(config, lane: lane, index: index, batch: true);
              break;

            default:
              // Widgets and Spacers don't need extra cleanup
              break;
          }
        }
      }
      _lightHomeMatrix.removeAt(lane);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  Future<void> _removeDeletedApp(String id) async {
    if (_banishedSet.contains(id)) {
      _banishedSet.remove(id);
      unawaited(EzCM.setStringList(banishedIDsKey, _banishedSet.toList()));
    }

    await showApp(id, batch: true);
    await removeHomeApp(
      Provider.of<EzCP>(ezRootNav.currentContext!, listen: false),
      id: id,
      batch: true,
    );

    _apps.remove(_appMap[id]);
    _appMap.remove(id);

    notifyListeners();
  }

  void cleanup(EzCP config, {required int lane, required List<int> entries}) {
    entries.sort((int a, int b) => b.compareTo(a));

    if (interlinked || config.isDark) {
      for (final int entry in entries) {
        final String element = _darkHomeMatrix[lane].removeAt(entry);
        _darkHomeSet.remove(element);
      }
    }

    if (interlinked || !config.isDark) {
      for (final int entry in entries) {
        final String element = _lightHomeMatrix[lane].removeAt(entry);
        _lightHomeSet.remove(element);
      }
    }

    notifyListeners();
  }

  // Dispose //

  @override
  void dispose() {
    _appEventSubscription?.cancel();
    super.dispose();
  }
}

// Local helpers  //

List<List<String>> _buildHomeMatrix(List<String> data) =>
    data.map((String outtie) => outtie.split(listSplit)).toList();

Future<bool> _saveDarkMatrix(List<List<String>> matrix) => EzCM.setStringList(
      darkHomeDataKey,
      matrix.map((List<String> innie) => innie.join(listSplit)).toList(),
    );

Future<bool> _saveLightMatrix(List<List<String>> matrix) => EzCM.setStringList(
      lightHomeDataKey,
      matrix.map((List<String> innie) => innie.join(listSplit)).toList(),
    );
