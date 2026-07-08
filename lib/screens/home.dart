/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

// TODO: one part of ripple cleanup should be to instantly add a spacer for the header to eventually replace

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:after_layout/after_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

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

    final Duration animDur = ezDuration(config.animDur, mod: rippleMod);
    if (animDur <= Duration.zero) {
      setState(() => editing = !editing);
      return;
    }

    // Ripple transition to editing
    final AnimationController rippleController =
        AnimationController(vsync: Overlay.of(context), duration: animDur);
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

  List<Widget> _buildTiles(
    EzCP config,
    AppInfoProvider appInfo,
    int lane, {
    required ListAlignment hAlign,
    required ListAlignment vAlign,
  }) {
    final List<String> entries = appInfo.homeLane(config, lane);

    final List<String> tileEntries = entries.length == 1 ? <String>[] : entries.sublist(1);
    final EdgeInsets tilePadding = EzInsets.wrap(config.spacing);
    final List<Widget> tiles = <Widget>[];

    for (int index = 0; index < tileEntries.length; index++) {
      final String entry = tileEntries[index];

      final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
      final String? delim = splitMatch?.group(0);

      switch (delim) {
        case idSplit:
          final List<String> parts = entry.split(idSplit);

          final AppInfo? app = appInfo.appMap[<String>[parts[0], parts[1]].join(idSplit)];
          if (app == null) continue;

          tiles.add(Padding(
            key: ValueKey<String>('$lane-$index-${app.id}'),
            padding: tilePadding,
            child: AppTile(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              hAlign: hAlign,
              vAlign: vAlign,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
              app: app,
              location: AppLocation.home,
              onSelected: (AppInfo app) => launchApp(app),
            ),
          ));
          break;

        case folderSplit:
          tiles.add(Padding(
            key: ValueKey<String>('$index-${entry.split(folderSplit)[0]}'),
            padding: tilePadding,
            child: FolderTile(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              hAlign: hAlign,
              vAlign: vAlign,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
            ),
          ));
          break;

        case widgetSplit:
          tiles.add(Padding(
            key: ValueKey<String>('$index-${entry.split(widgetSplit)[0]}'),
            padding: tilePadding,
            child: renderWidget(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              hAlign: hAlign,
              vAlign: vAlign,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
            ),
          ));
          break;

        case spacerSplit:
          tiles.add(Padding(
            key: ValueKey<String>('$index-spacer-$editing'),
            padding: editing ? tilePadding : EdgeInsets.zero,
            child: LimSpacer(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
              resizeCallback: () => setState(() => editing = false),
            ),
          ));
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
        ? Builder(builder: (_) {
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
                header: MenuAnchor(
                  builder: (_, MenuController controller, __) => EzRow(
                    config,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: config.spacing / 2),
                        child: EzIconButton(
                          config,
                          onPressed: () => toggleMenu(controller),
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                  menuChildren: <Widget>[
                    // Delete/Dupe
                    SubmenuButton(
                      menuChildren: <Widget>[
                        MenuItemButton(
                          onPressed: () => appInfo.removeLane(config, context, lane),
                          child: EzIcon(config, Icons.delete),
                        ),
                        MenuItemButton(
                          onPressed: () => appInfo.dupeLane(config, lane),
                          child: EzIcon(config, Icons.copy),
                        ),
                      ],
                      child: EzIcon(config, Icons.build),
                    ),

                    // Add
                    MenuItemButton(
                      onPressed: () => addModal(config, appInfo, lane, hAlign, vAlign),
                      child: EzIcon(config, Icons.add),
                    ),

                    // Edit
                    MenuItemButton(
                      onPressed: () async {
                        final ListAlignment hDef = horizontalAlign(config);
                        final ListAlignment vDef = verticalAlign(config);
                        ListAlignment hA = hAlign;
                        ListAlignment vA = vAlign;
                        const double sizeMod = 0.333;

                        int pos = lane;

                        await ezModal(
                          config,
                          context: context,
                          builder: (_) {
                            List<Widget> buildNodes() {
                              final List<Widget> nodes = <Widget>[];

                              for (int i = 0; i < numLanes; i++) {
                                nodes.addAll(<Widget>[
                                  Container(
                                    constraints: BoxConstraints.tightFor(
                                      height: appIconSize(config),
                                      width: appIconSize(config),
                                    ),
                                    decoration: BoxDecoration(
                                      color: i == pos
                                          ? config.colors.secondary
                                          : i == lane // this order is important
                                              ? config.colors.tertiary
                                              : config.colors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        i.toString(),
                                        textAlign: TextAlign.center,
                                        style: config.labelStyle?.copyWith(
                                          color: i == pos
                                              ? config.colors.onSecondary
                                              : i == lane
                                                  ? config.colors.onTertiary
                                                  : config.colors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  EzSpacer(config.padding, vertical: false),
                                ]);
                              }
                              nodes.removeLast();

                              return nodes;
                            }

                            return StatefulBuilder(
                              builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
                                config,
                                children: <Widget>[
                                  // Move
                                  Text(
                                    'Move',
                                    textAlign: TextAlign.center,
                                    style: config.labelStyle,
                                  ),
                                  config.margin,
                                  EzRow(
                                    config,
                                    reverseHands: false,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      if (numLanes > 1)
                                        Padding(
                                          padding: EdgeInsets.only(right: config.padding),
                                          child: EzIconButton(
                                            config,
                                            enabled: pos > 0,
                                            icon: const Icon(Icons.keyboard_arrow_left),
                                            onPressed: () => setModal(() => pos -= 1),
                                          ),
                                        ),
                                      EzScrollView(
                                        config,
                                        startCentered: true,
                                        scrollDirection: Axis.horizontal,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: (hA == ListAlignment.end) // TODO: ltr check?
                                            ? buildNodes().reversed.toList()
                                            : buildNodes(),
                                      ),
                                      if (numLanes > 1)
                                        Padding(
                                          padding: EdgeInsets.only(left: config.padding),
                                          child: EzIconButton(
                                            config,
                                            enabled: pos < (numLanes - 1),
                                            icon: const Icon(Icons.keyboard_arrow_right),
                                            onPressed: () => setModal(() => pos += 1),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Divider
                                  EzTitledDivider(
                                    Text(
                                      'Align',
                                      textAlign: TextAlign.center,
                                      style: config.labelStyle,
                                    ),
                                    height: config.spacing * 3,
                                    margin: config.marginVal,
                                  ),

                                  // Align
                                  Container(
                                    color: config.colors.onSurface,
                                    height: heightOf(context) * sizeMod,
                                    width: widthOf(context) * sizeMod,
                                    child: Stack(children: <Widget>[
                                      // Background
                                      Container(
                                        decoration: BoxDecoration(
                                          color: config.colors.surface,
                                          image: (config.backgroundImagePath == noImageValue)
                                              ? null
                                              : config.backgroundImage,
                                        ),
                                        margin: EdgeInsets.all(config.marginVal * sizeMod),
                                      ),

                                      // Aligned circular icon (curr)
                                      Align(
                                        alignment: LAConfig.merge(h: hA, v: vA),
                                        child: Container(
                                          constraints: BoxConstraints.tightFor(
                                            height: appIconSize(config),
                                            width: appIconSize(config),
                                          ),
                                          decoration: BoxDecoration(
                                            color: config.colors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              pos.toString(),
                                              textAlign: TextAlign.center,
                                              style: config.labelStyle?.copyWith(
                                                color: config.colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Aligned circular icon (default)
                                      Align(
                                        alignment: LAConfig.merge(h: hDef, v: vDef),
                                        child: ClipOval(
                                          child: Image.asset(
                                            appIconPath,
                                            semanticLabel: 'Default list alignment',
                                            width: appIconSize(config),
                                            height: appIconSize(config),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  config.separator,

                                  // Controls
                                  EzWrap(children: <Widget>[
                                    // Horizontal
                                    SegmentedButton<ListAlignment>(
                                      segments: alignmentSegments,
                                      selected: <ListAlignment>{hA},
                                      showSelectedIcon: false,
                                      onSelectionChanged: (Set<ListAlignment>? choice) {
                                        if (choice?.first == null) return;
                                        setModal(() => hA = choice!.first);
                                      },
                                    ),
                                    config.spacer,

                                    // Vertical
                                    SegmentedButton<ListAlignment>(
                                      segments: alignmentSegments,
                                      direction: Axis.vertical,
                                      selected: <ListAlignment>{vA},
                                      showSelectedIcon: false,
                                      onSelectionChanged: (Set<ListAlignment>? choice) {
                                        if (choice?.first == null) return;
                                        setModal(() => vA = choice!.first);
                                      },
                                    ),
                                  ]),
                                  config.separator,
                                ],
                              ),
                            );
                          },
                        );

                        await ezNoTouch(() async => await appInfo.updateLane(
                              config,
                              startPos: lane,
                              currPos: pos,
                              hA: hA,
                              vA: vA,
                            ));
                      },
                      child: EzIcon(config, Icons.edit),
                    ),
                  ],
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
          })
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
      lanes.add(ValueListenableBuilder<double>(
        valueListenable: rippleProgress,
        builder: (_, double ripple, __) => ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: double.infinity,
            minWidth: appIconSize(config) + config.spacing,
            maxWidth: (editing && (ripple == 0.0 || ripple == 1.0))
                ? appIconSize(config) * 3 + config.spargin
                : widthOf(context),
          ),
          child: _buildLane(config, appInfo, numLanes: numLanes, lane: lane),
        ),
      ));
    }
    return lanes;
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
          EzWrap(children: <Widget>[
            // Apps
            Padding(
              padding: EzInsets.wrap(config.spacing),
              child: EzElevatedIconButton(
                config,
                onPressed: () => context.goNamed(
                  appListPath,
                  extra: ListConfig(
                    listContent: <ListContent>{
                      ListContent.hidden,
                      ListContent.banished,
                    },
                    include: false,
                    onSelected: (AppInfo app) => appInfo.addApp(config, lane: lane, id: app.id),
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
                onPressed: () => appInfo.addFolder(config, lane),
                label: 'Folder',
                icon: EzIcon(config, Icons.folder_outlined),
              ),
            ),

            // Widgets
            Padding(
              padding: EzInsets.wrap(config.spacing),
              child: EzElevatedIconButton(
                config,
                onPressed: () => ezModal(config, context: context, builder: (_) {
                  WidgetSize size = WidgetSize.system;
                  WidgetSize preview = bt2WS(config);

                  return StatefulBuilder(
                    builder: (BuildContext wmCon, StateSetter setModal) =>
                        ezModalScroll(config, children: <Widget>[
                      // Clock
                      AddClock(config, appInfo, lane, hAlign: hAlign, vAlign: vAlign),
                      EzTitledDivider(
                        constraints: BoxConstraints(maxWidth: widthOf(wmCon) / 2),
                        EzDropdownMenu<WidgetSize>(
                          config,
                          enableSearch: false,
                          initialSelection: size,
                          widthEntry: WidgetSize.system.value,
                          dropdownMenuEntries: WidgetSize.values
                              .map((WidgetSize ws) => DropdownMenuEntry<WidgetSize>(
                                    value: ws,
                                    label: ezCamelToTitle(ws.value),
                                  ))
                              .toList(),
                          onSelected: (WidgetSize? choice) {
                            if (choice == null) return;
                            size = choice;
                            preview = (choice == WidgetSize.system) ? bt2WS(config) : choice;

                            setModal(() {});
                          },
                        ),
                        height: config.spacing * 2,
                        margin: config.padding,
                      ),
                      config.spacer,

                      // Calendar
                      AddCalendar(config, appInfo, lane, save: size, preview: preview),
                      config.spacer,

                      // Search
                      AddSearch(config, appInfo, lane, save: size, preview: preview),
                      config.spacer,

                      // Timer
                      AddTimer(config, appInfo, lane, save: size, preview: preview),
                      config.spacer,

                      // Toggle media
                      AddToggleMedia(config, appInfo, lane, save: size, preview: preview),
                      config.spacer,

                      // Theme mode
                      AddThemeMode(config, appInfo, lane, save: size, preview: preview),
                      config.separator,
                    ]),
                  );
                }),
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
                  final int index = await appInfo.addSpacer(config, lane: lane);
                  if (mCon.mounted) Navigator.of(mCon).pop();
                  setState(() => editing = false);

                  if (context.mounted) {
                    await editSpacer(
                      config,
                      appInfo: appInfo,
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
                      builder: (BuildContext mCon) => ezModalScroll(config, children: <Widget>[
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
                          '''With wide tiles enabled, each lane with an item will be the width of one screen.
By default, pages are also enabled, so lanes behave like pages on a traditional launcher.
You can disable pages to have everything be a continuous scroll.
                          
With wide tiles disabled, lanes will be sized by the widest item & your spacing setting, and the pages setting is ignored.''',
                          textAlign: TextAlign.center,
                        ),
                        config.separator,
                      ]),
                    );
                  }

                  await appInfo.addLane(config);
                },
                label: 'Lane',
                icon: EzIcon(config, Icons.view_column_outlined),
              ),
            ),
          ]),
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
          constraints: BoxConstraints.tightFor(
            height: config.iconSize,
            width: config.iconSize,
          ),
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
    pagePosTimer = Timer(_showTime, _clearPagePos);
  }

  void _clearPagePos() {
    pagePosTimer?.cancel();

    if (pagePosEntry?.mounted ?? false) {
      pagePosEntry!.remove();
      pagePosEntry = null;
    }
  }

  Future<void> swipeUp(EzCP config, AppInfoProvider appInfo) async => (editing)
      ? await navToHidden(config, appInfo)
      : context.goNamed(
          appListPath,
          extra: ListConfig(
            listContent: <ListContent>{ListContent.hidden, ListContent.banished},
            include: false,
            onSelected: (AppInfo app) async {
              if (ezRootNav.currentContext!.mounted) {
                Navigator.of(ezRootNav.currentContext!).pop();
              }
              await launchApp(app);
            },
            title: null,
          ),
        );

  Future<void> navToHidden(EzCP config, AppInfoProvider appInfo) async {
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
            if (ezRootNav.currentContext!.mounted) {
              Navigator.of(ezRootNav.currentContext!).pop();
            }
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

  // Init //

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    final EzCP config = configWatcher(context);

    // Check for welcome message
    if (!EzCM.get(shownIntroKey)) {
      if (context.mounted) {
        await ezModal(
          config,
          context: context,
          builder: (_) => ezModalScroll(config, children: <Widget>[
            // Welcome
            Text(
              'Welcome to Liminal Launcher',
              textAlign: TextAlign.center,
              style: config.titleStyle,
            ),
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
                EzPlainText(
                  text: ', light ',
                  style: config.bodyStyle,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: EzIcon(config, Icons.light_mode),
                ),
                EzPlainText(
                  text: ', or both ',
                  style: config.bodyStyle,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: FaIcon(
                    FontAwesomeIcons.yinYang,
                    size: config.iconSize,
                  ),
                ),
                EzPlainText(
                  text: ' themes.',
                  style: config.bodyStyle,
                ),
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
          ]),
        );
      }

      final bool isGPlay = await isGPlayInstall();
      if (context.mounted && !isGPlay) {
        const String m1 = '''This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

If you want to support Liminal's development, or the development of more Empathetech software, please consider ''';
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
          builder: (_) => StatefulBuilder(builder: (BuildContext mCon, StateSetter setModal) {
            final Duration readTime = Duration(
                milliseconds:
                    ((ezReadingTime(config, <String>[m1, m2, m3].join()).inMilliseconds) / 2)
                        .ceil());

            Future<void>.delayed(readTime, () {
              if (mCon.mounted) setModal(() => read = true);
            });

            return ezModalScroll(config, children: <Widget>[
              EzHeader(config),

              // Title
              Text(
                'One more thing...',
                textAlign: TextAlign.center,
                style: config.titleStyle,
              ),
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
                    url: Uri.parse('https://www.empathetech.net/#/contribute'),
                    hint: 'Open a link to the Empathetic contribution options.',
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
                icon: read
                    ? EzIcon(config, Icons.done)
                    : EzCountdownTimer(config, duration: readTime),
                onPressed: () => read ? Navigator.of(mCon).pop() : doNothing(),
              ),
              config.separator,
            ]);
          }),
        );
      }

      await EzCM.setBool(shownIntroKey, true);
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer2<EzCP, AppInfoProvider>(builder: (_, EzCP config, AppInfoProvider appInfo, __) {
      final int numLanes = appInfo.numLanes(config);

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
                  // Swipe left (drag right)
                  if (page < (numLanes - 1)) {
                    delta = 1;
                    setState(() => page += 1);
                    showPagePos(
                      config,
                      LAConfig.buildLookup(appInfo.homeItem(config, lane: page, index: 0),
                              Axis.horizontal, config) !=
                          ListAlignment.end,
                      numLanes: numLanes,
                      lane: page,
                    );
                    return;
                  }
                } else {
                  // Swipe right (drag left)
                  if (page > 0) {
                    delta = -1;
                    setState(() => page -= 1);
                    showPagePos(
                      config,
                      LAConfig.buildLookup(appInfo.homeItem(config, lane: page, index: 0),
                              Axis.horizontal, config) !=
                          ListAlignment.end,
                      numLanes: numLanes,
                      lane: page,
                    );
                    return;
                  }
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
                    // TODO: not here... I think? If so, how does that change things? If not, add it
                    crossAxisAlignment: verticalAlign(config).crossAxis,
                    children: buildGrid(config, appInfo, numLanes),
                  ),
          ),
        ),
        fabs: editing
            ? <Widget>[
                config.spacer,

                // Add (iff one lane)
                if (numLanes == 1) ...<Widget>[
                  AddFAB(
                    config,
                    () => addModal(
                      config,
                      appInfo,
                      0,
                      LAConfig.buildLookup(
                          appInfo.homeItem(config, lane: 0, index: 0), Axis.horizontal, config),
                      LAConfig.buildLookup(
                          appInfo.homeItem(config, lane: 0, index: 0), Axis.vertical, config),
                    ),
                  ),
                  config.spacer,
                ],

                // Settings
                SettingsFAB(config, () => context.goNamed(settingsPath)),
              ]
            : null,
        isHome: true,
      );
    });
  }
}

const Duration _showTime = Duration(seconds: 1);
