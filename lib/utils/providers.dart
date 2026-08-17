/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    sort(LSConfig.safeLookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));

    // Listen to events (installs, external deletes, etc.)
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

            final List<AppInfo> uninstalled =
                _apps.where((AppInfo app) => app.package == packageName).toList();

            if (uninstalled.isNotEmpty) {
              for (final AppInfo app in uninstalled) {
                if (ezRootIsMounted && ezRootContext.mounted) {
                  await ezSnackBar(
                    configWatcher(ezRootContext),
                    context: ezRootContext,
                    message: 'Removing ${app.label}',
                  ).closed;
                }
                await _clearHomeOf(null, app.id, true);
              }
            }
            break;
        }
      }
    }, onError: (dynamic error) => ezLog('Error listening to app events: $error'));
  }

  /// Does notify
  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(LSConfig.safeLookup(EzCM.get(listSortKey)), EzCM.get(ascListKey));
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

  Timer? _addedTimer;
  OverlayEntry? _addedEntry;
  final ValueNotifier<bool> _flipped = ValueNotifier<bool>(false);

  Future<void> _added(EzCP config, {required Future<void> Function()? editNew}) async {
    if (_addedTimer?.isActive ?? false) _clearAdded(setFlipped: !_flipped.value);

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
              valueListenable: _flipped,
              builder: (_, bool flipped, __) => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 0.0),
                duration: breatheTime,
                builder: (_, double progress, __) => Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CustomPaint(
                      size: Size(size, size),
                      painter: EzCountdownPainter(progress, config.colors.secondaryContainer),
                    ),
                    (editNew != null)
                        ? EzIconButton(
                            config,
                            icon: Icon(progress > 0.667 ? Icons.check : Icons.edit),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  flipped ? config.colors.primary : config.colors.surface,
                              foregroundColor:
                                  flipped ? config.colors.surface : config.colors.primary,
                            ),
                            onPressed: () async {
                              _clearAdded();
                              ezCloseAll();
                              await editNew();
                            },
                          )
                        : EzIconButton(
                            config,
                            icon: const Icon(Icons.check),
                            onPressed: _clearAdded,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    ezRootOverlay?.insert(_addedEntry!);
    _addedTimer = Timer(breatheTime, _clearAdded);
  }

  void _clearAdded({bool setFlipped = false}) {
    _addedTimer?.cancel();

    if (_addedEntry?.mounted ?? false) {
      _addedEntry!.remove();
      _addedEntry = null;
    }

    _flipped.value = setFlipped;
  }

  // Core //

  /// Does notify
  /// Shows added overlay
  Future<void> addApp(
    EzCP config, {
    required int lane,
    required String id,
    required Future<void> Function() editNew,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].add(<String>[id, defaultAppEntry(id.split(idSplit)[1])].join(idSplit));
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].add(<String>[id, defaultAppEntry(id.split(idSplit)[1])].join(idSplit));
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: editNew));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addWidget(
    EzCP config, {
    required WWGG type,
    required Future<void> Function()? editNew,
    required int lane,
  }) async {
    // Must be a function! (or twice local like the others)
    String entry() => <String>[
          type.value,
          switch (type) {
            WWGG.clock => defaultClockEntry(),
            WWGG.event => defaultEventEntry(),
            WWGG.search => defaultSearchEntry(),
            WWGG.timer => defaultTimerEntry(),
            WWGG.themeMode => defaultThemeWidgetEntry(),
            WWGG.toggleMedia => defaultMediaEntry(),
          },
        ].join(widgetSplit);

    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].add(entry());
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].add(entry());
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: editNew));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addFolder(
    EzCP config, {
    required int lane,
    required Future<void> Function() editNew,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane]
          .add(<String>[l10n(config).hsFolder, defaultFolderEntry()].join(folderSplit));
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane]
          .add(<String>[l10n(config).hsFolder, defaultFolderEntry()].join(folderSplit));
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: editNew));
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

    if (interlinked || config.isDark) {
      pos = index ?? _darkHomeMatrix[lane].length;
      final String entry = <String>[
        (height ?? config.spacing).toString(),
        (width ?? appIconSize(config)).toString(),
      ].join(spacerSplit);

      index == null ? _darkHomeMatrix[lane].add(entry) : _darkHomeMatrix[lane].insert(index, entry);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      pos = index ?? _lightHomeMatrix[lane].length;
      final String entry = <String>[
        (height ?? config.spacing).toString(),
        (width ?? appIconSize(config)).toString(),
      ].join(spacerSplit);

      index == null
          ? _lightHomeMatrix[lane].add(entry)
          : _lightHomeMatrix[lane].insert(index, entry);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    return pos;
  }

  /// Does notify
  /// Shows added overlay
  Future<void> addLane(EzCP config) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix.add(<String>[defaultLaneEntry()]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.add(<String>[defaultLaneEntry()]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: null));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> dupeItem(
    EzCP config, {
    required int lane,
    required int index,
    required Future<void> Function()? editNew,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane].insert(index, _darkHomeMatrix[lane][index]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane].insert(index, _lightHomeMatrix[lane][index]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: editNew));
  }

  /// Does notify
  /// Shows added overlay
  Future<void> dupeLane(
    EzCP config, {
    required int lane,
    required Future<void> Function() editNew,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix.insert(lane, List<String>.from(_darkHomeMatrix[lane]));
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.insert(lane, List<String>.from(_lightHomeMatrix[lane]));
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    unawaited(_added(config, editNew: editNew));
  }

  // Patch //

  void sort(ListSort sort, bool asc) {
    _apps.sort(switch (sort) {
      ListSort.name => (AppInfo a, AppInfo b) =>
          asc ? a.label.compareTo(b.label) : b.label.compareTo(a.label),
      ListSort.publisher => (AppInfo a, AppInfo b) =>
          asc ? a.package.compareTo(b.package) : b.package.compareTo(a.package),
      ListSort.date => (AppInfo a, AppInfo b) =>
          asc ? a.installDate.compareTo(b.installDate) : b.installDate.compareTo(a.installDate),
      ListSort.size => (AppInfo a, AppInfo b) =>
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
  Future<void> updateSpacing(
    EzCP config, {
    required int lane,
    required int index,
    required String entry,
  }) async {
    if (interlinked || config.isDark) {
      final String? delim = tileRegex.firstMatch(_darkHomeMatrix[lane][index])?.group(0);

      switch (delim) {
        case idSplit:
          final List<String> bigParts = _darkHomeMatrix[lane][index].split(idSplit);
          final List<String> lilParts = bigParts[2].split(configSplit);

          lilParts[0] = entry;
          bigParts[2] = lilParts.join(configSplit);
          _darkHomeMatrix[lane][index] = bigParts.join(idSplit);
          break;

        case folderSplit:
          final List<String> bigParts = _darkHomeMatrix[lane][index].split(folderSplit);
          final List<String> lilParts = bigParts[1].split(configSplit);

          lilParts[0] = entry;
          bigParts[1] = lilParts.join(configSplit);
          _darkHomeMatrix[lane][index] = bigParts.join(folderSplit);
          break;

        case widgetSplit:
          final List<String> bigParts = _darkHomeMatrix[lane][index].split(widgetSplit);
          final List<String> lilParts = bigParts[1].split(configSplit);

          lilParts[0] = entry;
          bigParts[1] = lilParts.join(configSplit);
          _darkHomeMatrix[lane][index] = bigParts.join(widgetSplit);
          break;

        case spacerSplit:
          final List<String> parts = _darkHomeMatrix[lane][index].split(spacerSplit);
          final List<String> values = entry.split(colon);

          parts[0] = values[0];
          parts[1] = values[1];
          _darkHomeMatrix[lane][index] = parts.join(spacerSplit);
          break;

        default:
          break;
      }
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      final String? delim = tileRegex.firstMatch(_lightHomeMatrix[lane][index])?.group(0);

      switch (delim) {
        case idSplit:
          final List<String> bigParts = _lightHomeMatrix[lane][index].split(idSplit);
          final List<String> lilParts = bigParts[2].split(configSplit);

          lilParts[0] = entry;
          bigParts[2] = lilParts.join(configSplit);
          _lightHomeMatrix[lane][index] = bigParts.join(idSplit);
          break;

        case folderSplit:
          final List<String> bigParts = _lightHomeMatrix[lane][index].split(folderSplit);
          final List<String> lilParts = bigParts[1].split(configSplit);

          lilParts[0] = entry;
          bigParts[1] = lilParts.join(configSplit);
          _lightHomeMatrix[lane][index] = bigParts.join(folderSplit);
          break;

        case widgetSplit:
          final List<String> bigParts = _lightHomeMatrix[lane][index].split(widgetSplit);
          final List<String> lilParts = bigParts[1].split(configSplit);

          lilParts[0] = entry;
          bigParts[1] = lilParts.join(configSplit);
          _lightHomeMatrix[lane][index] = bigParts.join(widgetSplit);
          break;

        case spacerSplit:
          final List<String> parts = _lightHomeMatrix[lane][index].split(spacerSplit);
          final List<String> values = entry.split(colon);

          parts[0] = values[0];
          parts[1] = values[1];
          _lightHomeMatrix[lane][index] = parts.join(spacerSplit);
          break;

        default:
          break;
      }
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

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
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = <String>[id, extra].join(idSplit);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = <String>[id, extra].join(idSplit);
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
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = <String>[
        name,
        extra,
        if (ids.isNotEmpty) ...ids,
      ].join(folderSplit);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = <String>[
        name,
        extra,
        if (ids.isNotEmpty) ...ids,
      ].join(folderSplit);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
  }

  /// Does notify
  Future<void> updateWidget(
    EzCP config,
    WWGG type,
    String extra, {
    required int lane,
    required int index,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[lane][index] = <String>[type.value, extra].join(widgetSplit);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[lane][index] = <String>[type.value, extra].join(widgetSplit);
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
    required String entry,
    required int startPos,
    required int currPos,
  }) async {
    if (interlinked || config.isDark) {
      _darkHomeMatrix[startPos][0] = entry;
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix[startPos][0] = entry;
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    if (startPos != currPos) await _reorderLanes(config, startPos, currPos);
    notifyListeners();
  }

  /// Does notify
  /// Calls [ezNoTouch] when saving changes
  Future<void> hideApp(EzCP config, BuildContext context, String id) async {
    bool? both;

    if (interlinked || config.isDark) {
      if (_darkHidden.contains(id)) return;
      final bool worthAsk = !interlinked && !_lightHidden.contains(id);

      if (_darkHidden.isEmpty || worthAsk) {
        both = await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: Text(
              _darkHidden.isEmpty ? l10n(config).pReminder : l10n(config).pWantTo,
              textAlign: TextAlign.center,
            ),
            content: Text(
              <String>[
                _darkHidden.isEmpty ? l10n(config).pHiddenReminder : '',
                (_darkHidden.isEmpty && worthAsk) ? '\n\n' : '',
                worthAsk ? l10n(config).pHideLightToo : '',
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
                        Navigator.of(dCon).pop(true);
                      },
                    ),
                    EzAction(
                      config,
                      text: config.ezL10n.gNo,
                      onPressed: () => Navigator.of(dCon).pop(false),
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
        both = await showDialog(
          context: context,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: Text(
              _lightHidden.isEmpty ? l10n(config).pReminder : l10n(config).pWantTo,
              textAlign: TextAlign.center,
            ),
            content: Text(
              <String>[
                _lightHidden.isEmpty ? l10n(config).pHiddenReminder : '',
                (_lightHidden.isEmpty && worthAsk) ? '\n\n' : '',
                worthAsk ? l10n(config).pHideDarkToo : '',
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
                  Navigator.of(dCon).pop(true);
                },
              ),
              EzAction(
                config,
                text: config.ezL10n.gNo,
                onPressed: () => Navigator.of(dCon).pop(false),
              ),
            ],
            needsClose: false,
          ),
        );
      }

      _lightHidden.add(id);
      unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
    }

    await _clearHomeOf(config, id, both ?? interlinked);
  }

  /// Does notify, as long as not [batch]
  Future<bool> showApp(EzCP config, String id, {bool batch = false}) async {
    if (interlinked || config.isDark) {
      if (!_darkHidden.contains(id)) return false;
      final bool worthAsk = !batch && !interlinked && _lightHidden.contains(id);

      if (worthAsk && ezRootIsMounted) {
        await showDialog(
          context: ezRootContext,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: Text(l10n(config).pWantTo, textAlign: TextAlign.center),
            content: Text(l10n(config).pShowLightToo, textAlign: TextAlign.center),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gYes,
                onPressed: () {
                  _lightHidden.remove(id);
                  unawaited(EzCM.setStringList(lightHiddenIDsKey, _lightHidden.toList()));
                },
              ),
              EzAction(config, text: config.ezL10n.gNo, onPressed: () => Navigator.of(dCon).pop()),
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

      if (worthAsk && ezRootIsMounted && ezRootContext.mounted) {
        await showDialog(
          context: ezRootContext,
          builder: (BuildContext dCon) => EzAlertDialog(
            config,
            title: Text(l10n(config).pWantTo, textAlign: TextAlign.center),
            content: Text(l10n(config).pShowDarkToo, textAlign: TextAlign.center),
            actions: <Widget>[
              EzAction(
                config,
                text: config.ezL10n.gYes,
                onPressed: () {
                  _darkHidden.remove(id);
                  unawaited(EzCM.setStringList(darkHiddenIDsKey, _darkHidden.toList()));
                },
              ),
              EzAction(config, text: config.ezL10n.gNo, onPressed: () => Navigator.of(dCon).pop()),
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
  Future<bool> banishApp(EzCP config, BuildContext context, AppInfo app) async {
    const String curr = 'curr'; // not for user, don't translate
    const String both = 'both';

    final String? choice = await showDialog(
      context: context,
      builder: (BuildContext dCon) => EzAlertDialog(
        config,
        title: Text(l10n(config).pBanishApp(app.label), textAlign: TextAlign.center),
        content: _darkBanished.isEmpty
            ? Text(
                l10n(config).pWhatBanish(l10n(config).pUnBanish(app.label)),
                textAlign: TextAlign.center,
              )
            : Text(l10n(config).pUnBanish(app.label), textAlign: TextAlign.center),
        actions: interlinked
            ? ezActionPair(
                config,
                onConfirm: () => Navigator.of(dCon).pop(both),
                confirmMsg: config.ezL10n.gContinue,
                confirmIsDestructive: true,
                onDeny: () => Navigator.of(dCon).pop(),
              )
            : <Widget>[
                EzAction(
                  config,
                  text: config.ezL10n.gBothThemes,
                  onPressed: () => Navigator.of(dCon).pop(both),
                ),
                EzAction(
                  config,
                  text: config.isDark ? config.ezL10n.gDarkTheme : config.ezL10n.gLightTheme,
                  onPressed: () => Navigator.of(dCon).pop(curr),
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
      case curr:
        if (config.isDark) {
          _darkBanished.add(app.id);
          unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
        } else {
          _lightBanished.add(app.id);
          unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
        }
        break;

      case both:
        _darkBanished.add(app.id);
        _lightBanished.add(app.id);
        unawaited(EzCM.setStringList(darkBanishIDsKey, _darkBanished.toList()));
        unawaited(EzCM.setStringList(lightBanishIDsKey, _lightBanished.toList()));
        break;

      default:
        return false;
    }

    await _clearHomeOf(config, app.id, choice == both);
    return true;
  }

  /// Does notify
  Future<void> cloneMatrix(bool keepDark) async {
    if (keepDark) {
      final List<List<String>> homeCopy =
          _darkHomeMatrix.map((List<String> lane) => List<String>.from(lane)).toList();

      final Set<String> hiddenCopy = Set<String>.from(_darkHidden);
      final Set<String> banishedCopy = Set<String>.from(_darkBanished);

      _lightHomeMatrix = homeCopy;
      _lightHidden = hiddenCopy;
      _lightBanished = banishedCopy;

      unawaited(_saveLightMatrix(homeCopy));
      unawaited(EzCM.setStringList(lightHiddenIDsKey, hiddenCopy.toList()));
      unawaited(EzCM.setStringList(lightBanishIDsKey, banishedCopy.toList()));
    } else {
      final List<List<String>> homeCopy =
          _lightHomeMatrix.map((List<String> lane) => List<String>.from(lane)).toList();

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
  Future<void> _clearHomeOf(EzCP? config, String id, bool both) async {
    await ezNoTouch(() async {
      if (config == null || both || config.isDark) {
        final List<List<String>> copy = List<List<String>>.from(_darkHomeMatrix);

        if (config == null) {
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
                    _darkHomeMatrix[lane][index] = <String>[
                      parts[0],
                      parts[1],
                      ...keeping,
                    ].join(folderSplit);
                  }
                }
                break;

              default:
                // doNothing
                break;
            }
          }
        }

        unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
      }

      if (config == null || both || !config.isDark) {
        final List<List<String>> copy = List<List<String>>.from(_lightHomeMatrix);

        if (config == null) {
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
                    _lightHomeMatrix[lane][index] = <String>[
                      parts[0],
                      parts[1],
                      ...keeping,
                    ].join(folderSplit);
                  }
                }
                break;

              default:
                // doNothing
                break;
            }
          }
        }

        unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
      }

      if (config == null) {
        _apps.remove(_appMap[id]);
        _appMap.remove(id);
      }
    });

    notifyListeners();
  }

  /// Does notify
  /// Includes optional confirm dialog
  Future<bool> removeLane(
    EzCP config,
    BuildContext context,
    int lane, {
    bool confirm = true,
  }) async {
    if (confirm) {
      final bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext dCon) => EzAlertDialog(
          config,
          title: Text(l10n(config).pRemoveLane(lane), textAlign: TextAlign.center),
          actions: ezActionPair(
            config,
            onConfirm: () => Navigator.of(dCon).pop(true),
            onDeny: () => Navigator.of(dCon).pop(false),
          ),
          needsClose: false,
        ),
      );

      if (!confirmed) return false;
    }

    if (interlinked || config.isDark) {
      _darkHomeMatrix.removeAt(lane);
      if (_darkHomeMatrix.isEmpty) _darkHomeMatrix.add(<String>[defaultLaneEntry()]);
      unawaited(_saveDarkMatrix(List<List<String>>.from(_darkHomeMatrix)));
    }

    if (interlinked || !config.isDark) {
      _lightHomeMatrix.removeAt(lane);
      if (_lightHomeMatrix.isEmpty) _lightHomeMatrix.add(<String>[defaultLaneEntry()]);
      unawaited(_saveLightMatrix(List<List<String>>.from(_lightHomeMatrix)));
    }

    notifyListeners();
    return true;
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
