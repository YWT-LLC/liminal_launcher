/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

// TODO: delta should be swapped too when !standardFlow
// TODO: get the manifest exactly how you want it - be cognizant of SafeArea usage as you do
//       at least, the app list should draw underneath the nav bar... not sure what else. maybe everything, maybe nothing

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:oui_bios/oui_bios.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:after_layout/after_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_ui/open_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AfterLayoutMixin<HomeScreen> {
  // Define build data //

  int page = 0;
  int delta = 0;

  Timer? pagePosTimer;
  OverlayEntry? pagePosEntry;

  bool atBottom = false;
  bool atLeft = false;
  bool atRight = false;
  Timer? overscrollPause;

  bool editing = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define custom functions //

  Future<void> ripple(EzCP config, LongPressStartDetails details) async {
    if (!context.mounted) return;

    final Duration animDur = homeRipple ? ezDuration(config.animDur) : Duration.zero;
    if (animDur <= oneMS) {
      setState(() => editing = !editing);
      return;
    }

    // Ripple transition to editing
    final AnimationController rippleController = AnimationController(
      vsync: Overlay.of(context),
      duration: animDur,
    );
    rippleController.addListener(() => rippleProgress.value = rippleController.value);

    final OverlayEntry ripple = ezRipple(
      controller: rippleController,
      width: widthOf(context),
      height: heightOf(context),
      position: details.globalPosition,
      color: config.colors.primary,
      oMin: focusOpacity,
    );
    Overlay.of(context).insert(ripple);
    lastRipple = details.globalPosition;

    await rippleController.forward().whenComplete(() {
      setState(() => editing = !editing);
      ripple.remove();
      rippleController.dispose();
    });
    return;
  }

  Future<void> addModal(
    EzCP config,
    AppInfoProvider appInfo,
    int lane,
    ListAlignment hAlign,
    ListAlignment vAlign,
  ) async {
    final double screenWidth = widthOf(context);

    await ezModal(
      config,
      context: context,
      builder: (BuildContext mCon) => ezModalScroll(
        config,
        children: <Widget>[
          EzWrap(
            children: <Widget>[
              // Apps
              Padding(
                padding: EzInsets.wrap(config.spacing),
                child: EzElevatedIconButton(
                  config,
                  onPressed: () => context.goNamed(
                    appListPath,
                    extra: ListConfig(
                      listContent: <ListContent>{ListContent.hidden, ListContent.banished},
                      include: false,
                      onSelected: (AppInfo app) => appInfo.addApp(
                        config,
                        id: app.id,
                        lane: lane,
                        editNew: () => editApp(
                          config,
                          appInfo: appInfo,
                          pContext: context,
                          initConfig: AppConfig(
                            app: app,
                            name: app.label,
                            icon: null,
                            buttonType: null,
                            labelType: null,
                          ),
                          lane: lane,
                          index: appInfo.homeLane(config, lane).length - 1,
                        ),
                      ),
                      title: EzTextIconButton(
                        config,
                        onPressed: doNothing,
                        label: 'Home',
                        icon: EzIcon(config, Icons.add, color: config.colors.onSurface),
                        textStyle: config.labelStyle,
                      ),
                    ),
                  ),
                  label: 'Apps',
                  icon: EzIcon(config, Icons.apps),
                ),
              ),

              // Folder
              Padding(
                padding: EzInsets.wrap(config.spacing),
                child: EzElevatedIconButton(
                  config,
                  onPressed: () => appInfo.addFolder(
                    config,
                    lane: lane,
                    editNew: () => editFolder(
                      config,
                      appInfo: appInfo,
                      pContext: context,
                      initConfig: FolderConfig(
                        name: 'Folder',
                        icon: Icons.folder_outlined,
                        buttonType: null,
                        labelType: null,
                        appList: <String>[],
                      ),
                      lane: lane,
                      index: appInfo.homeLane(config, lane).length - 1,
                    ),
                  ),
                  label: 'Folder',
                  icon: EzIcon(config, Icons.folder_outlined),
                ),
              ),

              // Widgets
              Padding(
                padding: EzInsets.wrap(config.spacing),
                child: EzElevatedIconButton(
                  config,
                  onPressed: () => ezModal(
                    config,
                    context: context,
                    builder: (_) {
                      WidgetSize size = WidgetSize.tile;

                      return StatefulBuilder(
                        builder: (BuildContext wmCon, StateSetter setModal) => ezModalScroll(
                          config,
                          children: <Widget>[
                            // Clock
                            AddClock(
                              config,
                              appInfo: appInfo,
                              pContext: context,
                              lane: lane,
                              hAlign: hAlign,
                              vAlign: vAlign,
                            ),

                            // Divider (con size selector)
                            EzTitledDivider(
                              constraints: BoxConstraints(maxWidth: widthOf(wmCon) / 2),
                              EzDropdownMenu<WidgetSize>(
                                config,
                                enableSearch: false,
                                initialSelection: size,
                                widthEntry: WidgetSize.button.value,
                                dropdownMenuEntries: WidgetSize.values
                                    .map(
                                      (WidgetSize ws) => DropdownMenuEntry<WidgetSize>(
                                        value: ws,
                                        label: ezCamelToTitle(ws.value),
                                      ),
                                    )
                                    .toList(),
                                onSelected: (WidgetSize? choice) {
                                  if (choice == null) return;
                                  setModal(() => size = choice);
                                },
                              ),
                              height: config.spacing * 2,
                              margin: config.padding,
                            ),
                            config.spacer,

                            // Calendar
                            AddCalendar(config, appInfo: appInfo, lane: lane, size: size),
                            config.spacer,

                            // Search
                            AddSearch(
                              config,
                              appInfo: appInfo,
                              pContext: context,
                              lane: lane,
                              size: size,
                            ),
                            config.spacer,

                            // Timer
                            AddTimer(
                              config,
                              appInfo: appInfo,
                              pContext: context,
                              lane: lane,
                              size: size,
                            ),
                            config.spacer,

                            // Toggle media
                            AddToggleMedia(
                              config,
                              appInfo: appInfo,
                              pContext: context,
                              lane: lane,
                              size: size,
                            ),
                            config.spacer,

                            // Theme mode
                            AddThemeMode(config, appInfo: appInfo, lane: lane, size: size),
                            config.separator,
                          ],
                        ),
                      );
                    },
                  ),
                  label: 'Widgets',
                  icon: EzIcon(config, Icons.widgets),
                ),
              ),

              // Spacer
              Padding(
                padding: EzInsets.wrap(config.spacing),
                child: EzElevatedIconButton(
                  config,
                  onPressed: () async {
                    if (mCon.mounted) Navigator.of(mCon).pop();
                    final int index = await appInfo.addSpacer(config, lane: lane);
                    setState(() => editing = false);

                    if (mounted) {
                      await editSpacer(
                        config,
                        appInfo: appInfo,
                        context: context,
                        lane: lane,
                        index: index,
                      );
                    }
                  },
                  label: 'Spacer',
                  icon: EzIcon(config, Icons.space_bar),
                ),
              ),

              // Lane
              Padding(
                padding: EzInsets.wrap(config.spacing),
                child: EzElevatedIconButton(
                  config,
                  onPressed: () async {
                    if (appInfo.numLanes(config) == 1) {
                      await ezModal(
                        config,
                        context: context,
                        builder: (BuildContext mCon) => ezModalScroll(
                          config,
                          children: <Widget>[
                            // Title
                            Text(
                              'Multi-lane configuration',
                              textAlign: TextAlign.center,
                              style: config.titleStyle,
                            ),
                            config.spacer,

                            // Switches
                            EzSwitchPair(
                              config,
                              valueKey: config.isDark ? darkWideTilesKey : lightWideTilesKey,
                              text: 'Wide tiles',
                              afterChanged: (bool? value) async {
                                if (value == null) return;

                                if (interlinked) {
                                  await EzCM.setBool(
                                    config.isDark ? lightWideTilesKey : darkWideTilesKey,
                                    value,
                                  );
                                }
                              },
                            ),
                            EzSwitchPair(
                              config,
                              valueKey: config.isDark ? darkPagesKey : lightPagesKey,
                              text: 'Use pages',
                              afterChanged: (bool? value) async {
                                if (value == null) return;

                                if (interlinked) {
                                  await EzCM.setBool(
                                    config.isDark ? lightPagesKey : darkPagesKey,
                                    value,
                                  );
                                }
                              },
                            ),
                            config.spacer,

                            // Description
                            const Text(
                              '''When wide tiles is enabled, each lane with an item will be the width of one screen.
With wide tiles disabled, lanes will be sized by their widest item & your spacing setting.

When pages is enabled, lanes behave like pages on a traditional launcher.
With pages disabled, all lanes share one horizontal scroll.

Turn both on if you want a minimalist setup.
Turn both off if you want pixel perfect tile placement.

Or, something in-between.''',
                              textAlign: TextAlign.center,
                            ),
                            config.separator,
                          ],
                        ),
                      );
                    }

                    await appInfo.addLane(config);
                  },
                  label: 'Lane',
                  icon: EzIcon(config, Icons.view_column_outlined),
                ),
              ),
            ],
          ),
          EzSpacer(config.spacing / 2),

          // Screen space note
          EzRow(
            config,
            children: <Widget>[
              Text(
                '${(screenWidth / (config.iconSize + config.padding + config.spacing)).toStringAsFixed(2)} lanes on screen',
                textAlign: TextAlign.center,
                style: config.labelStyle,
              ),
              config.rowMargin,
              EzToolTipper(
                config,
                message:
                    '''With your current...\n\nicon size (${config.iconSize.toStringAsFixed(1)}),\npadding (${config.padding.toStringAsFixed(0)}),\n& spacing (${config.spacing.toStringAsFixed(1)})

...values, you can fit up to ${(screenWidth / (config.iconSize + config.padding + config.spacing)).toStringAsFixed(2)} lanes on your screen.${(config.iconSize != minIconSize && config.padding != minPadding && config.spacing != minSpacing) ? ' With the minimum values, you can fit up to ${(screenWidth / (minIconSize + minPadding + minSpacing)).toStringAsFixed(2)} lanes.' : ''}''',
              ),
            ],
          ),
          config.separator,
        ],
      ),
    );
  }

  Future<void> showPagePos(
    EzCP config,
    bool forward, {
    required int numLanes,
    required int lane,
  }) async {
    if (pagePosTimer?.isActive ?? false) _clearPagePos();

    final List<Widget> nodes = <Widget>[];
    for (int i = 0; i < numLanes; i++) {
      nodes.addAll(<Widget>[
        Container(
          constraints: BoxConstraints.tightFor(height: config.iconSize, width: config.iconSize),
          decoration: BoxDecoration(
            color: i == lane ? config.colors.primary : config.colors.surface,
            shape: BoxShape.circle,
          ),
        ),
        EzSpacer(config.padding, vertical: false),
      ]);
    }
    if (nodes.length > 2) nodes.removeLast();

    pagePosEntry = OverlayEntry(
      builder: (BuildContext oCon) => Positioned(
        bottom: safeBottom(context),
        left: 0,
        right: 0,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Center(
              child: EzScrollView(
                config,
                startCentered: true,
                thumbVisibility: false,
                scrollDirection: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(config.marginVal),
                    decoration: BoxDecoration(
                      borderRadius: config.buttonShape.radius,
                      color: config.colors.outline,
                    ),
                    child: EzRow(
                      config,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: forward ? nodes : nodes.reversed.toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(pagePosEntry!);
    pagePosTimer = Timer(const Duration(seconds: 1), _clearPagePos);
  }

  void _clearPagePos() {
    pagePosTimer?.cancel();

    if (pagePosEntry?.mounted ?? false) {
      pagePosEntry!.remove();
      pagePosEntry = null;
    }
  }

  /// Checks out of bounds, safe to always call directly
  void navPageDown(EzCP config, AppInfoProvider appInfo, int numLanes) {
    if (page <= 0) return;

    delta = -1;
    setState(() => page -= 1);

    showPagePos(
      config,
      LAConfig.buildLookup(
            appInfo.homeItem(config, lane: page, index: 0),
            Axis.horizontal,
            config,
          ) !=
          ListAlignment.end,
      numLanes: numLanes,
      lane: page,
    );
  }

  /// Checks out of bounds, safe to always call directly
  void navPageUp(EzCP config, AppInfoProvider appInfo, int numLanes) {
    if (page >= (numLanes - 1)) return;

    delta = 1;
    setState(() => page += 1);

    showPagePos(
      config,
      LAConfig.buildLookup(
            appInfo.homeItem(config, lane: page, index: 0),
            Axis.horizontal,
            config,
          ) !=
          ListAlignment.end,
      numLanes: numLanes,
      lane: page,
    );
  }

  Future<void> swipeUp(EzCP config, AppInfoProvider appInfo) async {
    if (marked.value.$1 != null || marked.value.$2 != null) return;

    (editing)
        ? await _navToHidden(config, appInfo)
        : context.goNamed(
            appListPath,
            extra: ListConfig(
              listContent: <ListContent>{ListContent.hidden, ListContent.banished},
              include: false,
              onSelected: (AppInfo app) async {
                if (ezRootIsMounted) Navigator.of(ezRootContext).pop();
                await launchApp(app);
              },
              title: null,
            ),
          );
  }

  Future<void> _navToHidden(EzCP config, AppInfoProvider appInfo) async {
    if (authForHidden(config)) {
      bool authed = false;
      try {
        authed = await liminalAuth(config, 'Authenticate to see hidden apps');
      } catch (e) {
        ezLog(e.toString());
      }

      if (!authed) return;
    }

    if (mounted) {
      context.goNamed(
        appListPath,
        extra: ListConfig(
          listContent: <ListContent>{ListContent.hidden},
          include: true,
          onSelected: (AppInfo app) async {
            if (ezRootIsMounted) Navigator.of(ezRootContext).pop();
            await launchApp(app);
          },
          title: EzTextIconButton(
            config,
            onPressed: doNothing,
            label: 'Hidden',
            icon: EzIcon(config, Icons.visibility_off, color: config.colors.onSurface),
            textStyle: config.labelStyle,
          ),
        ),
      );
    }
  }

  // Build custom Widgets //

  List<Widget> _buildTiles(
    EzCP config,
    AppInfoProvider appInfo,
    int lane, {
    required ListAlignment hAlign,
    required ListAlignment vAlign,
  }) {
    final List<String> entries = appInfo.homeLane(config, lane);

    final List<Widget> tiles = <Widget>[];
    final EdgeInsets tilePadding = EzInsets.wrap(config.spacing);

    for (int index = 1; index < entries.length; index++) {
      final String entry = entries[index];
      final LimPos pos = LimPos(lane: lane, index: index, hAlign: hAlign, vAlign: vAlign);

      final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
      final String? delim = splitMatch?.group(0);

      switch (delim) {
        case idSplit:
          final List<String> parts = entry.split(idSplit);

          final AppInfo? app = appInfo.appMap[<String>[parts[0], parts[1]].join(idSplit)];
          if (app == null) continue;

          tiles.add(
            Padding(
              key: ValueKey<String>('$lane-$index-${app.id}'),
              padding: tilePadding,
              child: AppTile(
                config,
                appInfo: appInfo,
                pos: pos,
                state: editing ? AppState.groupEdit : AppState.standard,
                rippleProgress: rippleProgress,
                app: app,
                location: AppLocation.home,
                onSelected: (AppInfo app) => launchApp(app),
              ),
            ),
          );
          break;

        case folderSplit:
          tiles.add(
            Padding(
              key: ValueKey<String>('$index-${entry.split(folderSplit)[0]}'),
              padding: tilePadding,
              child: FolderTile(
                config,
                appInfo: appInfo,
                pos: pos,
                state: editing ? AppState.groupEdit : AppState.standard,
                rippleProgress: rippleProgress,
              ),
            ),
          );
          break;

        case widgetSplit:
          tiles.add(
            Padding(
              key: ValueKey<String>('$index-${entry.split(widgetSplit)[0]}'),
              padding: tilePadding,
              child: renderWidget(
                config,
                appInfo: appInfo,
                pos: pos,
                state: editing ? AppState.groupEdit : AppState.standard,
                rippleProgress: rippleProgress,
              ),
            ),
          );
          break;

        case spacerSplit:
          tiles.add(
            Padding(
              key: ValueKey<String>('$index-spacer-$editing'),
              padding: editing ? tilePadding : EdgeInsets.zero,
              child: LimSpacer(
                config,
                appInfo: appInfo,
                pos: pos,
                state: editing ? AppState.groupEdit : AppState.standard,
                rippleProgress: rippleProgress,
                resizeCallback: () => setState(() => editing = false),
              ),
            ),
          );
          break;

        default:
          break;
      }
    }

    return tiles;
  }

  Widget _buildLane(
    EzCP config,
    AppInfoProvider appInfo, {
    required int numLanes,
    required int lane,
  }) {
    final ListAlignment hAlign = LAConfig.buildLookup(
      appInfo.homeItem(config, lane: lane, index: 0),
      Axis.horizontal,
      config,
    );
    final ListAlignment vAlign = LAConfig.buildLookup(
      appInfo.homeItem(config, lane: lane, index: 0),
      Axis.vertical,
      config,
    );

    return editing
        ? Builder(
            builder: (_) {
              final List<Widget> tiles = _buildTiles(
                config,
                appInfo,
                lane,
                hAlign: hAlign,
                vAlign: vAlign,
              );

              return StatefulBuilder(
                key: ValueKey<String>('lane-$lane'),
                builder: (_, StateSetter setList) => ReorderableListView(
                  shrinkWrap: true,
                  header: LaneHeader(
                    config,
                    appInfo: appInfo,
                    pContext: context,
                    numLanes: numLanes,
                    pos: LimPos(lane: lane, index: -1, hAlign: hAlign, vAlign: vAlign),
                    addModal: addModal,
                    navPageDown:
                        pages(config) ? () => navPageDown(config, appInfo, numLanes) : null,
                    navPageUp: pages(config) ? () => navPageUp(config, appInfo, numLanes) : null,
                  ),
                  onReorderItem: (int oldIndex, int newIndex) async {
                    if (oldIndex == newIndex) return;

                    final Widget element = tiles.removeAt(oldIndex);
                    tiles.insert(newIndex, element);

                    await appInfo.reorderLane(
                      config,
                      lane: lane,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    );

                    setList(() {});
                  },
                  children: tiles,
                ),
              );
            },
          )
        : EzScrollView(
            config,
            key: ValueKey<String>('lane-$lane'),
            mainAxisAlignment: vAlign.mainAxis,
            crossAxisAlignment: hAlign.crossAxis,
            physics: const ClampingScrollPhysics(),
            children: _buildTiles(config, appInfo, lane, hAlign: hAlign, vAlign: vAlign),
          );
  }

  Widget buildPage(
    EzCP config,
    AppInfoProvider appInfo, {
    required int numLanes,
    required int lane,
  }) =>
      ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: double.infinity, height: double.infinity),
        child: _buildLane(config, appInfo, numLanes: numLanes, lane: lane),
      );

  List<Widget> buildGrid(EzCP config, AppInfoProvider appInfo, int numLanes) {
    final List<Widget> lanes = <Widget>[];

    for (int lane = 0; lane < numLanes; lane++) {
      lanes.add(
        ValueListenableBuilder<double>(
          valueListenable: rippleProgress,
          builder: (_, double ripple, __) => ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: double.infinity,
              minWidth: appIconSize(config) + config.spacing,
              maxWidth: (editing && (ripple % 1.0 == 0))
                  ? appIconSize(config) * 3 + config.spargin
                  : widthOf(context),
            ),
            child: _buildLane(config, appInfo, numLanes: numLanes, lane: lane),
          ),
        ),
      );
    }
    return lanes;
  }

  // Init //

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    late final EzCP config = configWatcher(context);

    // Check for welcome message(s)
    if (!EzCM.get(shownIntroKey)) {
      if (context.mounted) await _welcome(config, context);

      final bool isGPlay = await isGPlayInstall();
      if (!kDebugMode && context.mounted && !isGPlay) await _free99(config, context);

      await EzCM.setBool(shownIntroKey, true);
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (editing) setState(() => editing = false);
      },
      child: Consumer2<EzCP, AppInfoProvider>(
        builder: (_, EzCP config, AppInfoProvider appInfo, __) {
          final int numLanes = appInfo.numLanes(config);
          final double headerSpacing = config.iconSize + config.padding + (config.spacing / 2);

          return LiminalScaffold(
            config,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPressStart: (LongPressStartDetails details) async => editing
                  ? await ripple(config, details)
                  : await canEdit(config, () => ripple(config, details)),
              onVerticalDragEnd: (DragEndDetails details) async {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0) await swipeUp(config, appInfo);
                }
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity != null && details.primaryVelocity! != 0) {
                  if (pages(config)) {
                    if (details.primaryVelocity! < 0) {
                      // Swipe right to left -> nav to right
                      standardFlow(config)
                          ? navPageUp(config, appInfo, numLanes)
                          : navPageDown(config, appInfo, numLanes);
                      return;
                    } else {
                      // Swipe left to right -> nav to left
                      standardFlow(config)
                          ? navPageDown(config, appInfo, numLanes)
                          : navPageUp(config, appInfo, numLanes);
                      return;
                    }
                  }

                  final AppInfo? toLaunch = editing
                      ? null
                      : ((details.primaryVelocity! < 0)
                          ? appInfo.appMap[leftSwipeID]
                          : appInfo.appMap[rightSwipeID]);

                  if (toLaunch != null) launchApp(toLaunch);
                }
              },
              // App list
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  switch (notification.runtimeType) {
                    case const (OverscrollNotification):
                      if (notification.metrics.axis == Axis.vertical) {
                        // Vertical overscroll
                        if ((notification as OverscrollNotification).overscroll > 0) {
                          if (atBottom) {
                            swipeUp(config, appInfo);
                            return true;
                          } else {
                            overscrollPause = Timer(scrollDelay, () => atBottom = true);
                            return true;
                          }
                        }
                      } else {
                        // Horizontal overscroll
                        AppInfo? toLaunch;

                        if ((notification as OverscrollNotification).overscroll < 0) {
                          if (atLeft) {
                            toLaunch = appInfo.appMap[rightSwipeID];
                          } else {
                            overscrollPause = Timer(scrollDelay, () => atLeft = true);
                            return true;
                          }
                        }

                        if (notification.overscroll > 0) {
                          if (atRight) {
                            toLaunch = appInfo.appMap[leftSwipeID];
                          } else {
                            overscrollPause = Timer(scrollDelay, () => atRight = true);
                            return true;
                          }
                        }

                        if (toLaunch != null) launchApp(toLaunch);
                        return true;
                      }
                      break;

                    case const (ScrollUpdateNotification):
                      if (notification.metrics.axis == Axis.vertical) {
                        // Vertical scroll
                        if (atBottom && notification.metrics.pixels < 0) {
                          atBottom = false;
                        }
                      } else {
                        // Horizontal scroll
                        if (atLeft && notification.metrics.pixels > 0) {
                          atLeft = false;
                        }
                        if (atRight && notification.metrics.pixels < 0) {
                          atRight = false;
                        }
                      }
                      break;

                    case const (ScrollEndNotification):
                      if (notification.metrics.axis == Axis.vertical) {
                        // Vertical end
                        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                          overscrollPause = Timer(scrollDelay, () => atBottom = true);
                        } else {
                          atBottom = false;
                        }
                      } else {
                        // Horizontal end
                        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                          atLeft = false;
                          overscrollPause = Timer(scrollDelay, () => atRight = true);
                        } else {
                          atRight = false;
                          overscrollPause = Timer(scrollDelay, () => atLeft = true);
                        }
                      }
                      break;
                  }
                  return false;
                },
                child: ValueListenableBuilder<double>(
                  valueListenable: rippleProgress,
                  builder: (_, double ripple, __) => Padding(
                    padding: editing
                        ? EdgeInsets.zero
                        : EdgeInsets.only(top: headerSpacing * (ripple % 1.0)),
                    child: pages(config)
                        ? EzFauxCarousel(
                            config,
                            position: page,
                            delta: delta,
                            child: buildPage(config, appInfo, numLanes: numLanes, lane: page),
                          )
                        : EzScrollView(
                            config,
                            mainAxisSize: MainAxisSize.max,
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            mainAxisAlignment: horizontalAlign(config).mainAxis,
                            crossAxisAlignment: verticalAlign(config).crossAxis,
                            children: buildGrid(config, appInfo, numLanes),
                          ),
                  ),
                ),
              ),
            ),
            fabs: editing
                ? <Widget>[
                    config.spacer,

                    // Settings
                    SettingsFAB(config, appInfo, () => context.goNamed(settingsPath)),
                  ]
                : null,
            isHome: true,
          );
        },
      ),
    );
  }
}

Future<void> _welcome(EzCP config, BuildContext context) => ezModal(
      config,
      context: context,
      builder: (_) => ezModalScroll(
        config,
        children: <Widget>[
          // Welcome
          Text('Welcome to Liminal Launcher',
              textAlign: TextAlign.center, style: config.titleStyle),
          config.centerLine,

          // Minimal-ish
          Text(
            "It's geared toward minimalism,\nbut has limitless customization.",
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
          config.centerLine,

          // Yin/Yang
          EzRichText(
            config,
            children: <InlineSpan>[
              EzPlainText(
                text:
                    '''Personalization is easy, and everything that needs explanation will have it. 

As a general rule: Liminal's appearance can be completely separate based on theme mode!

While in the relevant settings, you will see a toggle-able icon that indicates whether you're editing the dark ''',
                style: config.bodyStyle,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: EzIcon(config, Icons.dark_mode),
              ),
              EzPlainText(text: ', light ', style: config.bodyStyle),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: EzIcon(config, Icons.light_mode),
              ),
              EzPlainText(text: ', or both ', style: config.bodyStyle),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: FaIcon(FontAwesomeIcons.yinYang, size: config.iconSize),
              ),
              EzPlainText(text: ' themes.', style: config.bodyStyle),
            ],
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
          config.centerLine,

          // Have fun!
          Text(
            'Long press the home screen to get started.\nThank you, and enjoy!',
            textAlign: TextAlign.center,
            style: config.bodyStyle,
          ),
          config.separator,
        ],
      ),
    );

Future<void> _free99(EzCP config, BuildContext context) async {
  const String m1 = '''This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

If you want to support Liminal's development, or the development of more cool software, please consider ''';
  const String m2 = 'contributing';
  const String m3 =
      '.\n\nThis is the only non-tutorial pop-up, and its only appearance this install.';

  bool read = false;

  await ezModal(
    config,
    context: context,
    enableDrag: false,
    isDismissible: false,
    showDragHandle: false,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) {
        final Duration readTime = Duration(
          milliseconds:
              ((ezReadingTime(config, <String>[m1, m2, m3].join()).inMilliseconds) / 3).ceil(),
        );

        Future<void>.delayed(readTime, () {
          if (mCon.mounted) setModal(() => read = true);
        });

        return ezModalScroll(
          config,
          children: <Widget>[
            EzHeader(config),

            // Title
            Text('One more thing...', textAlign: TextAlign.center, style: config.titleStyle),
            config.centerLine,

            // Message
            EzRichText(
              config,
              children: <InlineSpan>[
                const EzPlainText(text: m1),
                EzInlineLink(
                  config,
                  text: m2,
                  style: config.bodyStyle,
                  textAlign: TextAlign.center,
                  url: Uri.parse('https://www.ywt.llc/#/contribute'),
                  hint: 'Open a link to contribution options.',
                ),
                const EzPlainText(text: m3),
              ],
              style: config.bodyStyle,
              textBackground: false,
              textAlign: TextAlign.center,
            ),
            config.separator,

            // Leave after (half) read
            EzTextIconButton(
              config,
              label: 'Okay',
              style: TextButton.styleFrom(backgroundColor: config.colors.surfaceContainer),
              icon:
                  read ? EzIcon(config, Icons.done) : EzCountdownTimer(config, duration: readTime),
              onPressed: () => read ? Navigator.of(mCon).pop() : doNothing(),
            ),
            config.separator,
          ],
        );
      },
    ),
  );
}
