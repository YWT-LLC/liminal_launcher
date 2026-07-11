/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppInfoProvider extends ChangeNotifier {
  //* Construct *//

  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  static const EventChannel _appEventChannel = EventChannel('$androidPackage/app_events');
  StreamSubscription<dynamic>? _appEventSubscription;

  Set<String> _darkHidden = Set<String>.from(EzCM.get(darkHiddenIDsKey));
  Set<String> _lightHidden = Set<String>.from(EzCM.get(lightHiddenIDsKey));

  Set<String> _darkBanished = Set<String>.from(EzCM.get(darkBanishIDsKey));
  Set<String> _lightBanished = Set<String>.from(EzCM.get(lightBanishIDsKey));

  late List<List<String>> _darkHomeMatrix;
  late List<List<String>> _lightHomeMatrix;

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{for (AppInfo app in apps) app.id: app} {
    // Build the matrices
    _darkHomeMatrix = _buildHomeMatrix(EzCM.get(darkHomeDataKey));
    _lightHomeMatrix = _buildHomeMatrix(EzCM.get(lightHomeDataKey));

    // Sort based on the user's preferences
    sort(ASConfig.safeLookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));

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
                  if (ezRootNav.currentContext != null && ezRootNav.currentContext!.mounted) {
                    await ezSnackBar(
                      configWatcher(ezRootNav.currentContext!),
                      context: ezRootNav.currentContext!,
                      message: 'Removing ${app.label}',
                    ).closed;
                  }
                  await _clearHomeOf(null, app.id, true);
                }
              }
              break;
          }
        }
      },
      onError: (dynamic error) => ezLog('Error listening to app events: $error'),
    );
  }

  /// Does notify
  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(ASConfig.safeLookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));
    notifyListeners();
  }

  //* Get *//

  List<AppInfo> get apps => _apps;
  Map<String, AppInfo> get appMap => _appMap;

  int numLanes(EzCP config) => config.isDark ? _darkHomeMatrix.length : _lightHomeMatrix.length;

  List<String> homeLane(EzCP config, int lane) =>
      config.isDark ? _darkHomeMatrix[lane] : _lightHomeMatrix[lane];

  String homeItem(EzCP config, {required int lane, required int index}) =>
      config.isDark ? _darkHomeMatrix[lane][index] : _lightHomeMatrix[lane][index];

  Set<String> hidden(EzCP config) => config.isDark ? _darkHidden : _lightHidden;
  Set<String> banished(EzCP config) => config.isDark ? _darkBanished : _lightBanished;

  Set<String> hybridIDs(EzCP config, ListConfig listConfig) => config.isDark
      ? <String>{
          if (listConfig.localContent != null) ...listConfig.localContent!.value,
          if (listConfig.listContent.contains(ListContent.hidden)) ..._darkHidden,
          if (listConfig.listContent.contains(ListContent.banished)) ..._darkBanished,
        }
      : <String>{
          if (listConfig.localContent != null) ...listConfig.localContent!.value,
          if (listConfig.listContent.contains(ListContent.hidden)) ..._lightHidden,
          if (listConfig.listContent.contains(ListContent.banished)) ..._lightBanished,
        };

  //* Put *//

  // Helpers //

  final ValueNotifier<bool> _invert = ValueNotifier<bool>(false);

  Timer? _addedTimer;
  OverlayEntry? _addedEntry;

  Future<void> _added(EzCP config) async {
    if (_addedTimer?.isActive ?? false) {
      _invert.value = !_invert.value;

      _addedTimer!.cancel();
      _addedTimer = Timer(_showTime, _clearAdded);

      return;
    }

    final double size = appIconSize(config) + config.marginVal;
    _addedEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: _invert,
              builder: (_, bool flipped, __) =>
                  Stack(alignment: Alignment.center, children: <Widget>[
                TweenAnimationBuilder<double>(
                  key: ValueKey<bool>(flipped),
                  tween: Tween<double>(begin: 1.0, end: 0.0),
                  duration: _showTime,
                  builder: (_, double progress, __) => CustomPaint(
                    size: Size(size, size),
                    painter: EzCountdownPainter(progress, config.colors.secondary),
                  ),
                ),
                EzIconButton(
                  config,
                  icon: const Icon(Icons.check),
                  style: IconButton.styleFrom(
                    backgroundColor: flipped ? config.colors.primary : config.colors.surface,
                    foregroundColor: flipped ? config.colors.surface : config.colors.primary,
                  ),
                  onPressed: _clearAdded,
                ),
              ]),
            ),
          ),
        ),
      ),
    );

    ezRootNav.currentState?.overlay?.insert(_addedEntry!);
    _addedTimer = Timer(_showTime, _clearAdded);
  }

  void _clearAdded() {
    _addedTimer?.cancel();

    if (_addedEntry?.mounted ?? false) {
      _addedEntry!.remove();
      _addedEntry = null;
    }

    _invert.value = false;
  }

  /// Doesn't notify
  void _add(bool dark, int lane, String entry) {
    if (dark) {
      _darkHomeMatrix[lane].add(entry);
      if (_darkHomeMatrix[lane][0] == '[]') _darkHomeMatrix[lane].removeAt(0);
    } else {
      _lightHomeMatrix[lane].add(entry);
      if (_lightHomeMatrix[lane][0] == '[]') _lightHomeMatrix[lane].removeAt(0);
    }
  }

  // Core //

  /// Does notify
  /// Shows added overlay
  Future<void> addApp(EzCP config, {required int lane, required String id}) async {
    final String entry = <String>[
      id,
      TCC.appEntry(id.split(idSplit)[1], null, null, null),
    ].join(idSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addFolder(EzCP config, int lane) async {
    final String entry = <String>[
      'Folder',
      TCC.folderEntry(Icons.folder_outlined, null, null),
    ].join(folderSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addCalendar(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.calendar.value,
      TCC.calendarEntry(WidgetSize.system),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addClock(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.clock.value,
      TCC.clockEntry(EzButtonShape.roundRect, null, true, TxtStile.headline, null, DateType.compact,
          TxtStile.label, null),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addSearch(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.search.value,
      TCC.searchEntry(WidgetSize.system, ecosia, Engine.defaultOrder.map((Engine e) => e.value)),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addTimer(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.timer.value,
      TCC.timerEntry(WidgetSize.system, '00:00:00'),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addToggleMedia(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.toggleMedia.value,
      TCC.mediaEntry(WidgetSize.system),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addThemeModeWidget(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.themeMode.value,
      TCC.themeModeEntry(WidgetSize.system),
    ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _add(true, lane, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _add(false, lane, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Doesn't show added overlay (assumes the helper overlay will be or is already opened)
  Future<int> addSpacer(
    EzCP config, {
    double? height,
    double? width,
    required int lane,
    int? index,
  }) async {
    int pos = 0;
    final String entry = <String>[
      (height ?? config.spacing).toString(),
      (width ?? appIconSize(config)).toString(),
    ].join(spacerSplit);

    if (interlinked || config.isDark) {
      pos = index ?? _darkHomeMatrix[lane].length;

      index == null ? _add(true, lane, entry) : _darkHomeMatrix[lane].insert(index, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      pos = index ?? _lightHomeMatrix[lane].length;

      index == null ? _add(false, lane, entry) : _lightHomeMatrix[lane].insert(index, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    return pos;
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addLane(EzCP config) async {
    final List<String> entry = <String>[TCC.laneEntry(null, null)];

    if (interlinked || config.isDark) {
      _darkHomeMatrix.add(entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.add(entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> dupeItem(EzCP config, {required int lane, required int index}) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].insert(index, _darkHomeMatrix[lane][index]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].insert(index, _lightHomeMatrix[lane][index]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> dupeLane(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix.insert(lane, List<String>.from(_darkHomeMatrix[lane]));
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.insert(lane, List<String>.from(_lightHomeMatrix[lane]));
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config));
  }

  // Patch //

  void sort(AppSort sort, bool asc) {
    _apps.sort(switch (sort) {
      AppSort.name => (AppInfo a, AppInfo b) =>
          asc ? a.label.compareTo(b.label) : b.label.compareTo(a.label),
      AppSort.publisher => (AppInfo a, AppInfo b) =>
          asc ? a.package.compareTo(b.package) : b.package.compareTo(a.package),
      AppSort.date => (AppInfo a, AppInfo b) =>
          asc ? a.installDate.compareTo(b.installDate) : b.installDate.compareTo(a.installDate),
      AppSort.size => (AppInfo a, AppInfo b) =>
          asc ? a.packageSize.compareTo(b.packageSize) : b.packageSize.compareTo(a.packageSize),
    });

    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    await ezNoTouch(() async {
      _darkHidden = Set<String>.from(EzCM.get(darkHiddenIDsKey));
      _lightHidden = Set<String>.from(EzCM.get(lightHiddenIDsKey));

      _darkBanished = Set<String>.from(EzCM.get(darkBanishIDsKey));
      _lightBanished = Set<String>.from(EzCM.get(lightBanishIDsKey));

      _darkHomeMatrix = _buildHomeMatrix(EzCM.get(darkHomeDataKey));
      _lightHomeMatrix = _buildHomeMatrix(EzCM.get(lightHomeDataKey));
    });

    notifyListeners();
  }

  /// Does notify
  Future<void> updateApp(
    EzCP config, {
    required int lane,
    required int index,
    required String id,
    required String extra,
  }) async {
    final String entry = <String>[id, extra].join(idSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Does notify
  Future<void> updateFolder(
    EzCP config, {
    required int lane,
    required int index,
    required String name,
    required String extra,
    required List<String> ids,
  }) async {
    final String entry = <String>[
      name,
      extra,
      if (ids.isNotEmpty) ...ids,
    ].join(folderSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Does notify
  Future<void> updateWidget(
    EzCP config,
    WidWidGetGet type,
    String extra, {
    required int lane,
    required int index,
  }) async {
    final String entry = <String>[type.value, extra].join(widgetSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Does notify
  Future<void> updateSpacer(
    EzCP config, {
    required double height,
    required double width,
    required int lane,
    required int index,
  }) async {
    final String entry = <String>[height.toString(), width.toString()].join(spacerSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Optionally [notify]s (default false)
  Future<void> reorderLane(
    EzCP config, {
    required int lane,
    required int oldIndex,
    required int newIndex,
    bool notify = false,
  }) async {
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

    if (notify) notifyListeners();
  }

  /// Does notify
  Future<void> moveItemUpLane(EzCP config, {required int lane, required int index}) async {
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

  /// Does notify
  Future<void> moveItemDownLane(EzCP config, {required int lane, required int index}) async {
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

  Future<void> _reorderLanes(EzCP config, int oldPos, int newPos) async {
    if (interlinked || config.isDark) {
      final List<String> lane = _darkHomeMatrix.removeAt(oldPos);
      _darkHomeMatrix.insert(newPos, lane);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> lane = _lightHomeMatrix.removeAt(oldPos);
      _lightHomeMatrix.insert(newPos, lane);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }
  }

  Future<void> updateLane(
    EzCP config, {
    required int startPos,
    required int currPos,
    required ListAlignment hA,
    required ListAlignment vA,
  }) async {
    final String configEntry = (hA == horizontalAlign(config) && vA == verticalAlign(config))
        ? TCC.laneEntry(null, null)
        : TCC.laneEntry(hA, vA);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[startPos][0] = configEntry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[startPos][0] = configEntry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    if (startPos != currPos) await _reorderLanes(config, startPos, currPos);
    notifyListeners();
  }

  /// Does notify
  /// Calls [ezNoTouch] when saving changes
  Future<void> hideApp(EzCP config, BuildContext context, String id) async {
    if (interlinked || config.isDark) {
      if (_darkHidden.contains(id)) return;
      final bool worthAsk = !interlinked && !_lightHidden.contains(id);

      if (_darkHidden.isEmpty || worthAsk) {
        await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title:
                Text(_darkHidden.isEmpty ? 'Reminder' : 'Want to...', textAlign: TextAlign.center),
            content: Text(
              <String>[
                _darkHidden.isEmpty ? 'Swipe up while editing to open the hidden apps list.' : '',
                (_darkHidden.isEmpty && worthAsk) ? '\n\n' : '',
                worthAsk ? 'Hide for light mode too?' : '',
              ].join(),
              textAlign: TextAlign.center,
            ),
            actions: worthAsk
                ? <Widget>[
                    EzAction(
                      config,
                      text: config.ezL10n.gYes,
                      onPressed: () {
                        _lightHidden.add(id);
                        unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
                      },
                    ),
                    EzAction(
                      config,
                      text: config.ezL10n.gNo,
                      onPressed: () => Navigator.of(dCon).pop(),
                    ),
                  ]
                : null,
            needsClose: !worthAsk,
          ),
        );
      }

      _darkHidden.add(id);
      unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
    }

    if (interlinked || !config.isDark) {
      if (_lightHidden.contains(id)) return;
      final bool worthAsk = !interlinked && !_darkHidden.contains(id);

      if (worthAsk && context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title:
                Text(_lightHidden.isEmpty ? 'Reminder' : 'Want to...', textAlign: TextAlign.center),
            content: Text(
              <String>[
                _lightHidden.isEmpty
                    ? 'Swipe up while editing to open the hidden apps list.\n\n'
                    : '',
                'Hide for dark mode too?',
              ].join(),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gYes,
                onPressed: () {
                  _darkHidden.add(id);
                  unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
                },
              ),
              EzAction(
                config,
                text: config.ezL10n.gNo,
                onPressed: () => Navigator.of(dCon).pop(),
              ),
            ],
            needsClose: false,
          ),
        );
      }

      _lightHidden.add(id);
      unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
    }

    await _clearHomeOf(config, id, false);
  }

  /// Does notify, as long as not [batch]
  Future<bool> showApp(EzCP config, String id, {bool batch = false}) async {
    if (interlinked || config.isDark) {
      if (!_darkHidden.contains(id)) return false;
      final bool worthAsk = !batch && !interlinked && _lightHidden.contains(id);

      if (worthAsk && ezRootNav.currentContext != null && ezRootNav.currentContext!.mounted) {
        await showDialog(
          context: ezRootNav.currentContext!,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: const Text('Want to...', textAlign: TextAlign.center),
            content: const Text('show for light mode too?', textAlign: TextAlign.center),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gYes,
                onPressed: () {
                  _lightHidden.remove(id);
                  unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
                },
              ),
              EzAction(
                config,
                text: config.ezL10n.gNo,
                onPressed: () => Navigator.of(dCon).pop(),
              ),
            ],
            needsClose: false,
          ),
        );
      }

      _darkHidden.remove(id);
      unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
    }

    if (interlinked || !config.isDark) {
      if (!_lightHidden.contains(id)) return false;
      final bool worthAsk = !batch && !interlinked && _darkHidden.contains(id);

      if (worthAsk && ezRootNav.currentContext != null && ezRootNav.currentContext!.mounted) {
        await showDialog(
          context: ezRootNav.currentContext!,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: const Text('Want to...', textAlign: TextAlign.center),
            content: const Text('show for dark mode too?', textAlign: TextAlign.center),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gYes,
                onPressed: () {
                  _darkHidden.remove(id);
                  unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
                },
              ),
              EzAction(
                config,
                text: config.ezL10n.gNo,
                onPressed: () => Navigator.of(dCon).pop(),
              ),
            ],
            needsClose: false,
          ),
        );
      }

      _lightHidden.remove(id);
      unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
    }

    if (!batch) notifyListeners();
    return true;
  }

  /// Does notify
  /// Calls [ezNoTouch] when saving changes
  Future<bool> banishApp(EzCP config, BuildContext context, String id) async {
    if (interlinked || config.isDark) {
      if (_darkBanished.contains(id)) return false;

      final AppInfo? currApp = _appMap[id];
      if (currApp == null) return false;

      final String? choice = await showDialog(
        context: context,
        builder: (BuildContext dCon) => EzAlertDialog(
          config,
          title: Text(
            'Banish ${currApp.label}?',
            textAlign: TextAlign.center,
          ),
          content: _darkBanished.isEmpty
              ? Text(
                  '''When you banish an app, it will still be installed but not appear in Liminal at all.
Banished apps can only be opened from the system settings, or via app link.

The simplest way to restore/un-banish ${currApp.label} is to uninstall it from the system settings, then reinstall.

Banishing is useful for utility apps that also waste time. For example, you may want to banish your web browser(s).
That way, you can use online menus when you go out, and reduce doom scrolling when you stay in.

Reminder: banishing is just for UX, not for security.
For example: if an app has always on location permissions, banishing it will not affect that.''',
                  textAlign: TextAlign.center,
                )
              : Text(
                  'The simplest way to restore/un-banish ${currApp.label} is to uninstall it from the system settings, then reinstall.',
                  textAlign: TextAlign.center,
                ),
          actions: interlinked
              ? ezActionPair(
                  config,
                  onConfirm: () => Navigator.of(dCon).pop('both'),
                  confirmMsg: config.ezL10n.gContinue,
                  confirmIsDestructive: true,
                  onDeny: () => Navigator.of(dCon).pop(),
                )
              : <Widget>[
                  EzAction(
                    config,
                    text: config.ezL10n.gBothThemes,
                    onPressed: () => Navigator.of(dCon).pop('both'),
                  ),
                  EzAction(
                    config,
                    text: config.ezL10n.gDarkTheme,
                    onPressed: () => Navigator.of(dCon).pop('dark'),
                  ),
                  EzAction(
                    config,
                    text: config.ezL10n.gCancel,
                    onPressed: () => Navigator.of(dCon).pop(),
                  ),
                ],
          needsClose: false,
        ),
      );

      switch (choice) {
        case 'dark':
          _darkBanished.add(id);
          unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
          break;

        case 'both':
          _darkBanished.add(id);
          _lightBanished.add(id);
          unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
          unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
          break;

        default:
          // doNothing
          break;
      }

      if (choice == null) return false;
    }

    if (interlinked || !config.isDark) {
      if (_lightBanished.contains(id)) return false;

      if (!interlinked && context.mounted) {
        final AppInfo? currApp = _appMap[id];
        if (currApp == null) return false;

        final String? choice = await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: Text(
              'Banish ${currApp.label}?',
              textAlign: TextAlign.center,
            ),
            content: _lightBanished.isEmpty
                ? Text(
                    '''When you banish an app, it will still be installed but not appear in Liminal at all.
Banished apps can only be opened from the system settings, or via app link.

The simplest way to restore/un-banish ${currApp.label} is to uninstall it from the system settings, then reinstall.

Banishing is useful for utility apps that also waste time. For example, you may want to banish your web browser(s).
That way, you can use online menus when you go out, and reduce doom scrolling when you stay in.

Reminder: banishing is just for UX, not for security.
For example: if an app has always on location permissions, banishing it will not affect that.''',
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'The simplest way to restore/un-banish ${currApp.label} is to uninstall it from the system settings, then reinstall.',
                    textAlign: TextAlign.center,
                  ),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gBothThemes,
                onPressed: () => Navigator.of(dCon).pop('both'),
              ),
              EzAction(
                config,
                text: config.ezL10n.gDarkTheme,
                onPressed: () => Navigator.of(dCon).pop('light'),
              ),
              EzAction(
                config,
                text: config.ezL10n.gCancel,
                onPressed: () => Navigator.of(dCon).pop(),
              ),
            ],
            needsClose: false,
          ),
        );

        switch (choice) {
          case 'light':
            _lightBanished.add(id);
            unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
            break;

          case 'both':
            _darkBanished.add(id);
            _lightBanished.add(id);
            unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
            unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
            break;

          default:
            // doNothing
            break;
        }

        if (choice == null) return false;
      }

      _lightBanished.add(id);
      unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
    }

    await _clearHomeOf(config, id, false);
    return true;
  }

  /// Does notify
  Future<void> cloneMatrix(bool keepDark) async {
    if (keepDark) {
      final List<List<String>> homeCopy = List<List<String>>.from(_darkHomeMatrix);
      final Set<String> hiddenCopy = Set<String>.from(_darkHidden);
      final Set<String> banishedCopy = Set<String>.from(_darkBanished);

      _lightHomeMatrix = homeCopy;
      _lightHidden = hiddenCopy;
      _lightBanished = banishedCopy;

      unawaited(_saveLightMatrix(homeCopy));
      unawaited(EzCM.setStringList(lightHiddenIDsKey, hiddenCopy.toList()));
      unawaited(EzCM.setStringList(lightBanishIDsKey, banishedCopy.toList()));
    } else {
      final List<List<String>> homeCopy = List<List<String>>.from(_lightHomeMatrix);
      final Set<String> hiddenCopy = Set<String>.from(_lightHidden);
      final Set<String> banishedCopy = Set<String>.from(_lightBanished);

      _darkHomeMatrix = homeCopy;
      _darkHidden = hiddenCopy;
      _darkBanished = banishedCopy;

      unawaited(_saveDarkMatrix(homeCopy));
      unawaited(EzCM.setStringList(darkHiddenIDsKey, hiddenCopy.toList()));
      unawaited(EzCM.setStringList(darkBanishIDsKey, banishedCopy.toList()));
    }

    notifyListeners();
  }

  // Delete //

  /// Does notify, as long as not [batch]
  Future<void> removeItem(
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

  /// Full [ezNoTouch], then notifies
  // TODO: handful of issues here, audit && fix
  Future<void> _clearHomeOf(EzCP? config, String id, bool deleting) async {
    await ezNoTouch(() async {
      if (config == null || interlinked || config.isDark) {
        final List<List<String>> copy = List<List<String>>.from(_darkHomeMatrix);

        if (deleting) {
          if (_darkHidden.contains(id)) {
            _darkHidden.remove(id);
            unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
          }
          if (_darkBanished.contains(id)) {
            _darkBanished.remove(id);
            unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
          }
        }

        for (int lane = 0; lane < copy.length; lane++) {
          for (int index = copy[lane].length - 1; index >= 0; index--) {
            final String item = _darkHomeMatrix[lane][index];

            final RegExpMatch? splitMatch = tileRegex.firstMatch(item);
            final String? delim = splitMatch?.group(0);

            switch (delim) {
              case idSplit:
                if (item.startsWith(id)) _darkHomeMatrix[lane].removeAt(index);
                break;

              case folderSplit:
                final List<String> parts = item.split(folderSplit);

                if (parts.length > 2) {
                  final List<String> keeping = List<String>.from(parts.sublist(2));
                  keeping.removeWhere((String entry) => entry.startsWith(id));

                  if (keeping.length != (parts.length - 2)) {
                    _darkHomeMatrix[lane][index] =
                        <String>[parts[0], parts[1], ...keeping].join(folderSplit);
                  }
                }
                break;

              default:
                // doNothing
                break;
            }
          }
        }

        if (config != null && !interlinked) {
          _apps.remove(_appMap[id]);
          _appMap.remove(id);
        }
      }

      if (config == null || interlinked || !config.isDark) {
        final List<List<String>> copy = List<List<String>>.from(_lightHomeMatrix);

        if (deleting) {
          if (_lightHidden.contains(id)) {
            _lightHidden.remove(id);
            unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
          }
          if (_lightBanished.contains(id)) {
            _lightBanished.remove(id);
            unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
          }
        }

        for (int lane = 0; lane < copy.length; lane++) {
          for (int index = copy[lane].length - 1; index >= 0; index--) {
            final String item = _lightHomeMatrix[lane][index];

            final RegExpMatch? splitMatch = tileRegex.firstMatch(item);
            final String? delim = splitMatch?.group(0);

            switch (delim) {
              case idSplit:
                if (item.startsWith(id)) _lightHomeMatrix[lane].removeAt(index);
                break;

              case folderSplit:
                final List<String> parts = item.split(folderSplit);

                if (parts.length > 2) {
                  final List<String> keeping = List<String>.from(parts.sublist(2));
                  keeping.removeWhere((String entry) => entry.startsWith(id));

                  if (keeping.length != (parts.length - 2)) {
                    _lightHomeMatrix[lane][index] =
                        <String>[parts[0], parts[1], ...keeping].join(folderSplit);
                  }
                }
                break;

              default:
                // doNothing
                break;
            }
          }
        }

        _apps.remove(_appMap[id]);
        _appMap.remove(id);
      }
    });

    notifyListeners();
  }

  /// Does notify
  /// Includes optional confirm dialog
  Future<void> removeLane(
    EzCP config,
    BuildContext context,
    int lane, {
    bool confirm = false,
  }) async {
    if (confirm) {
      final bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext dCon) => EzAlertDialog(
          config,
          title: Text('Delete lane $lane?', textAlign: TextAlign.center),
          actions: ezActionPair(
            config,
            onConfirm: () => Navigator.of(dCon).pop(true),
            onDeny: () => Navigator.of(dCon).pop(false),
          ),
          needsClose: false,
        ),
      );

      if (!confirmed) return;
    }

    if (interlinked || config.isDark) {
      _darkHomeMatrix.removeAt(lane);
      if (_darkHomeMatrix.isEmpty) _darkHomeMatrix.add(<String>[TCC.laneEntry(null, null)]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.removeAt(lane);
      if (_lightHomeMatrix.isEmpty) _lightHomeMatrix.add(<String>[TCC.laneEntry(null, null)]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
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

//* Shared helpers  *//

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

const Duration _showTime = Duration(seconds: 2);
