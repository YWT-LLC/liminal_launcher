/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

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

  final Set<String> _darkHidden = Set<String>.from(EzCM.get(darkHiddenIDsKey));
  final Set<String> _lightHidden = Set<String>.from(EzCM.get(lightHiddenIDsKey));

  final Set<String> _darkBanished = Set<String>.from(EzCM.get(darkBanishIDsKey));
  final Set<String> _lightBanished = Set<String>.from(EzCM.get(lightBanishIDsKey));

  late List<List<String>> _darkHomeMatrix;
  late List<List<String>> _lightHomeMatrix;

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{for (AppInfo app in apps) app.id: app} {
    // Build the matrices
    _darkHomeMatrix = _buildHomeMatrix(EzCM.get(darkHomeDataKey));
    _lightHomeMatrix = _buildHomeMatrix(EzCM.get(lightHomeDataKey));

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

  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(ASConfig.lookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));
    notifyListeners();
  }

  //* Get *//

  List<AppInfo> get apps => _apps;
  Map<String, AppInfo> get appMap => _appMap;

  int numLanes(EzCP config) => config.isDark ? _darkHomeMatrix.length : _lightHomeMatrix.length;

  List<String> homeLane(EzCP config, int lane) =>
      config.isDark ? _darkHomeMatrix[lane] : _darkHomeMatrix[lane];

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

  Timer? _showTimer;
  OverlayEntry? _activeEntry;

  Future<void> _added(EzCP config) async {
    if (_showTimer?.isActive ?? false) {
      _invert.value = !_invert.value;

      _showTimer!.cancel();
      _showTimer = Timer(_showTime, _clearOverlay);

      return;
    }

    final double size = appIconSize(config) + config.marginVal;
    _activeEntry = OverlayEntry(
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
                  onPressed: _clearOverlay,
                ),
              ]),
            ),
          ),
        ),
      ),
    );

    ezRootNav.currentState?.overlay?.insert(_activeEntry!);
    _showTimer = Timer(_showTime, _clearOverlay);
  }

  void _clearOverlay() {
    _showTimer?.cancel();

    if (_activeEntry?.mounted ?? false) {
      _activeEntry!.remove();
      _activeEntry = null;
    }

    _invert.value = false;
  }

  // Core //

  Future<void> addApp(EzCP config, {required int lane, required String id}) async {
    final String entry = <String>[
      id,
      TCC.appEntry(id.split(idSplit)[0], null, null),
    ].join(idSplit);

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

  Future<void> addFolder(EzCP config, int lane) async {
    final String entry = <String>[
      'Folder',
      TCC.folderEntry(Icons.folder_outlined, null),
    ].join(folderSplit);

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

  Future<void> addCalendar(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.calendar.value,
      TCC.calendarEntry(WidgetSize.system),
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

  Future<void> addClock(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.clock.value,
      TCC.clockEntry(null, true, TxtStile.headline, null, DateType.compact, TxtStile.label, null),
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

  Future<void> addSearch(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.search.value,
      TCC.searchEntry(WidgetSize.system, Engine.ecosia),
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

  Future<void> addTimer(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.timer.value,
      TCC.timerEntry(WidgetSize.system, '00:00:00'),
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

  Future<void> addMedia(EzCP config, int lane) async {
    final String entry = <String>[
      WidWidGetGet.toggleMedia.value,
      TCC.mediaEntry(WidgetSize.system),
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

      index == null ? _darkHomeMatrix[lane].add(entry) : _darkHomeMatrix[lane].insert(index, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      pos = index ?? _lightHomeMatrix[lane].length;

      index == null
          ? _lightHomeMatrix[lane].add(entry)
          : _lightHomeMatrix[lane].insert(index, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    return pos;
  }

  // TODO: I prolly need to replace []s right? print and check and shit
  Future<void> addLane(EzCP config) async {
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

    // Don't notifyListeners();
  }

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

  // TODO: test
  Future<void> moveLaneUp(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      final List<String> col = _darkHomeMatrix.removeAt(lane);
      _darkHomeMatrix.insert(lane, col);

      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final List<String> col = _lightHomeMatrix.removeAt(lane);
      _lightHomeMatrix.insert(lane, col);

      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  // TODO: test
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

  // TODO: take a brain break, then get back to your audits. resume at the top of remove/delete/hide/etc
  // TODO: include hidden in clone && ask to double hide/banish when split
  Future<void> hideApp(EzCP config, BuildContext context, String id) async {
    if (interlinked || config.isDark) {
      if (_darkHidden.contains(id)) return;

      if (_darkHidden.isEmpty || !interlinked) {
        await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title:
                Text(_darkHidden.isEmpty ? 'Reminder' : 'Want to...', textAlign: TextAlign.center),
            content: Text(
              <String>[
                _darkHidden.isEmpty ? 'Swipe up while editing to open the hidden apps list.' : '',
                (_darkHidden.isEmpty && !interlinked) ? '\n\n' : '',
                interlinked ? '' : 'Hide for light mode too?',
              ].join(),
              textAlign: TextAlign.center,
            ),
            actions: interlinked
                ? null
                : <Widget>[
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
                  ],
            needsClose: interlinked,
          ),
        );
      }

      _darkHidden.add(id);
      unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
    }

    if (interlinked || !config.isDark) {
      if (_lightHidden.contains(id)) return;

      if (!interlinked && context.mounted) {
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
                'Hide for light mode too?',
              ].join(),
              textAlign: TextAlign.center,
            ),
            actions: interlinked
                ? null
                : <Widget>[
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
                  ],
            needsClose: interlinked,
          ),
        );
      }

      _lightHidden.add(id);
      unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
    }

    await _clearHomeOf(config, id, false);
  }

  Future<bool> showApp(EzCP config, String id, {bool batch = false}) async {
    if (interlinked || config.isDark) {
      if (!_darkHidden.contains(id)) return false;

      if (!batch &&
          !interlinked &&
          ezRootNav.currentContext != null &&
          ezRootNav.currentContext!.mounted) {
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

      if (!batch &&
          !interlinked &&
          ezRootNav.currentContext != null &&
          ezRootNav.currentContext!.mounted) {
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

  Future<void> cloneMatrix(bool keepDark) async {
    if (keepDark) {
      _lightHomeMatrix = List<List<String>>.from(_darkHomeMatrix);
      unawaited(_saveLightMatrix(_darkHomeMatrix));
    } else {
      _darkHomeMatrix = List<List<String>>.from(_lightHomeMatrix);
      unawaited(_saveDarkMatrix(_lightHomeMatrix));
    }

    notifyListeners();
  }

  // Delete //

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

  // TODO: Check all calls to make sure you're not doing two
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

                  _darkHomeMatrix[lane][index] =
                      <String>[parts[0], parts[1], ...keeping].join(folderSplit);
                }
                break;

              default:
                // doNothing
                break;
            }
          }
        }

        if (!interlinked) {
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

                  _lightHomeMatrix[lane][index] =
                      <String>[parts[0], parts[1], ...keeping].join(folderSplit);
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

  Future<void> removeLane(EzCP config, int lane) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix.removeAt(lane);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.removeAt(lane);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  // TODO: double check the use of this
  void cleanup(EzCP config, {required int lane, required List<int> entries}) {
    entries.sort((int a, int b) => b.compareTo(a));

    if (interlinked || config.isDark) {
      for (final int entry in entries) {
        _darkHomeMatrix[lane].removeAt(entry);
      }
    }

    if (interlinked || !config.isDark) {
      for (final int entry in entries) {
        _lightHomeMatrix[lane].removeAt(entry);
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
