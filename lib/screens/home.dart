/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:after_layout/after_layout.dart';

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

  Offset _tmpVertSwipeStart = Offset.zero;
  late final double trayOffset = heightOf(context) * 0.925;

  // Define custom functions //

  Future<void> ripple(EzProvider config, PositionedGestureDetails details) async {
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
      fill: config.primaryFill,
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
    EzProvider config,
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
              ezWrap(
                config,
                child: EzElevatedIconButton(
                  config,
                  onPressed: () => context.goNamed(
                    appListScreenName,
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
                            tp: nullTPS,
                            app: app,
                            name: app.label,
                            icon: null,
                            iconSize: null,
                            buttonType: null,
                            labelType: null,
                            labelStyle: null,
                            textColor: null,
                            iconFill: null,
                            backgroundFill: null,
                            outlineFill: null,
                          ),
                          lane: lane,
                          index: appInfo.homeLane(config, lane).length - 1,
                        ),
                      ),
                      title: EzTextIconButton(
                        config,
                        onPressed: doNothing,
                        label: l10n(config).hsHome,
                        icon: EzIcon(config, Icons.add, fill: config.onSurfaceFiller),
                        textStyle: config.labelStyle,
                      ),
                    ),
                  ),
                  label: l10n(config).hsApp,
                  icon: EzIcon(config, Icons.apps),
                ),
              ),

              // Folder
              ezWrap(
                config,
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
                        tp: nullTPS,
                        appList: <String>[],
                        name: l10n(config).hsFolder,
                        icon: Icons.folder_outlined,
                        iconSize: null,
                        buttonType: null,
                        labelType: null,
                        labelStyle: null,
                        textColor: null,
                        iconFill: null,
                        backgroundFill: null,
                        outlineFill: null,
                      ),
                      lane: lane,
                      index: appInfo.homeLane(config, lane).length - 1,
                      appearance: false,
                    ),
                  ),
                  label: l10n(config).hsFolder,
                  icon: EzIcon(config, Icons.folder_outlined),
                ),
              ),

              // Widgets
              ezWrap(
                config,
                child: EzElevatedIconButton(
                  config,
                  onPressed: () => ezModal(
                    config,
                    context: context,
                    builder: (_) {
                      WWGGSize size = WWGGSize.tile;

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
                              config,
                              title: EzFlipFlop(
                                config,
                                onLabel: l10n(config).gTile,
                                offLabel: l10n(config).gButton,
                                init: true,
                                onChanged: (bool tile) =>
                                    setModal(() => size = tile ? WWGGSize.tile : WWGGSize.button),
                              ),
                              height: config.spacing * 2,
                            ),
                            config.spacer,

                            // Event
                            AddEvent(
                              config,
                              appInfo: appInfo,
                              pContext: context,
                              lane: lane,
                              size: size,
                            ),
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
                  label: l10n(config).hsWidget,
                  icon: EzIcon(config, Icons.widgets),
                ),
              ),

              // Spacer
              ezWrap(
                config,
                child: EzElevatedIconButton(
                  config,
                  onPressed: () async {
                    if (mCon.mounted) Navigator.of(mCon).pop();

                    final int index = await appInfo.addSpacer(config, lane: lane);
                    setState(() => editing = false);

                    if (mounted) {
                      setState(() => marked.value = LimPos(
                            lane: lane,
                            index: index,
                            hAlign: hAlign,
                            vAlign: vAlign,
                          ));
                      await editSpacing(config, appInfo: appInfo, context: context);
                    }
                  },
                  label: l10n(config).hsSpacer,
                  icon: EzIcon(config, Icons.space_bar),
                ),
              ),

              // Lane
              ezWrap(config, child: AddLane(config, appInfo: appInfo)),
            ],
          ),
          config.halfSpacer,

          // Screen space note
          EzRow(config, children: <Widget>[
            Flexible(
              child: Text(
                '${(screenWidth / (config.iconSize + config.padding + config.spacing)).toStringAsFixed(2)}${l10n(config).hsScreenLanes}',
                textAlign: TextAlign.center,
                style: config.labelStyle,
              ),
            ),
            config.rowMargin,
            EzToolTipper(
              config,
              message:
                  '${l10n(config).hsWithCurr}${config.iconSize.toStringAsFixed(1)}${l10n(config).hsPadding}${config.padding.toStringAsFixed(0)}${l10n(config).hsSpacing}${config.spacing.toStringAsFixed(1)})\n\n${l10n(config).hsCanFit}${(screenWidth / (config.iconSize + config.padding + config.spacing)).toStringAsFixed(2)}${l10n(config).hsScreenLanes}${(config.iconSize != ywt.minIconSize && config.padding != ywt.minPadding && config.spacing != ywt.minSpacing) ? '${l10n(config).hsWithMin}${(screenWidth / (ywt.minIconSize + ywt.minPadding + ywt.minSpacing)).toStringAsFixed(2)}${l10n(config).hsLanes}' : ''}',
            ),
          ]),
          config.separator,
        ],
      ),
    );
  }

  Future<void> showPagePos(
    EzProvider config,
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
          decoration: config.boxDeco(
            fill: i == lane ? config.primaryFill : config.surfaceFill,
            shape: BoxShape.circle,
          ),
        ),
        EzSpacer(config.padding, vertical: false),
      ]);
    }
    if (nodes.length > 2) nodes.removeLast();

    pagePosEntry = EzOverlayEntry(
      bottom: safeBottom(context),
      left: 0,
      right: 0,
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
              decoration: config.boxDeco(fill: config.outlineFiller),
              child: EzRow(
                config,
                mainAxisAlignment: MainAxisAlignment.center,
                children: forward ? nodes : nodes.reversed.toList(),
              ),
            ),
          ],
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
  Future<bool> navPageDown(EzProvider config, AppInfoProvider appInfo, int numLanes) async {
    if (page <= 0) return false;

    delta = standardFlow(config) ? -1 : 1;
    setState(() => page -= 1);

    unawaited(showPagePos(
      config,
      LAConfig.buildLookup(
            appInfo.homeItem(config, lane: page, index: 0),
            Axis.horizontal,
            config,
          ) !=
          ListAlignment.end,
      numLanes: numLanes,
      lane: page,
    ));

    return true;
  }

  /// Checks out of bounds, safe to always call directly
  Future<bool> navPageUp(EzProvider config, AppInfoProvider appInfo, int numLanes) async {
    if (page >= (numLanes - 1)) return false;

    delta = standardFlow(config) ? 1 : -1;
    setState(() => page += 1);

    unawaited(showPagePos(
      config,
      LAConfig.buildLookup(
            appInfo.homeItem(config, lane: page, index: 0),
            Axis.horizontal,
            config,
          ) !=
          ListAlignment.end,
      numLanes: numLanes,
      lane: page,
    ));

    return true;
  }

  Future<void> swipeUp(EzProvider config, AppInfoProvider appInfo) async => (editing)
      ? await _navToHidden(config, appInfo)
      : context.goNamed(
          appListScreenName,
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

  Future<void> _navToHidden(EzProvider config, AppInfoProvider appInfo) async {
    if (authForHidden(config)) {
      bool authed = false;
      try {
        authed = await liminalAuth(config, l10n(config).hsHiddenAuth);
      } catch (e) {
        ezLog(e.toString());
      }

      if (!authed) return;
    }

    if (mounted) {
      context.goNamed(
        appListScreenName,
        extra: ListConfig(
          listContent: <ListContent>{ListContent.hidden},
          include: true,
          onSelected: (AppInfo app) async {
            if (ezRootIsMounted) Navigator.of(ezRootContext).pop();
            await launchApp(app);
            if (resetAfterOpened(config)) setState(() => editing = false);
          },
          title: EzTextIconButton(
            config,
            onPressed: doNothing,
            label: l10n(config).gHidden,
            icon: EzIcon(
              config,
              Icons.visibility_off,
              fill: config.onSurfaceFiller,
            ),
            textStyle: config.labelStyle,
          ),
        ),
      );
    }
  }

  // Build custom Widgets //

  List<Widget> _buildTiles(
    EzProvider config,
    AppInfoProvider appInfo,
    int lane, {
    required ListAlignment hAlign,
    required ListAlignment vAlign,
  }) {
    final List<String> entries = appInfo.homeLane(config, lane);

    final List<Widget> tiles = <Widget>[];
    void editReset() => setState(() => editing = false);

    for (int index = 1; index < entries.length; index++) {
      final String entry = entries[index];
      final LimPos pos = LimPos(lane: lane, index: index, hAlign: hAlign, vAlign: vAlign);

      final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
      final String? delim = splitMatch?.group(0);

      switch (delim) {
        case idSplit:
          final List<String> items = entry.split(idSplit);

          final AppInfo? app = appInfo.appMap[<String>[items[0], items[1]].join(idSplit)];
          if (app == null) continue;

          final List<String> data = items[2].split(configSplit);

          tiles.add(
            marked.value == pos
                ? ValueListenableBuilder<EdgeInsets>(
                    key: ValueKey<String>('$lane-$index-${app.id}'),
                    valueListenable: editTilePadding,
                    builder: (_, EdgeInsets padding, __) => Container(
                      padding: padding,
                      decoration: config.boxDeco(
                        border: config.boxBorder(fill: config.secondaryContainerFill),
                        borderRadius: config.buttonShape.textRadius,
                        fill: config.secondaryFill,
                        opacity: focusOpacity,
                      ),
                      child: AppTile(
                        config,
                        appInfo: appInfo,
                        app: app,
                        onSelected: (_) async => doNothing,
                        location: AppLocation.home,
                        state: editing ? TileState.groupEdit : TileState.standard,
                        rippleProgress: rippleProgress,
                        pos: pos,
                        editReset: editReset,
                        data: data,
                      ),
                    ),
                  )
                : Padding(
                    key: ValueKey<String>('$lane-$index-${app.id}'),
                    padding: tilePadding(config, data[0], editing),
                    child: AppTile(
                      config,
                      appInfo: appInfo,
                      app: app,
                      onSelected: (AppInfo app) async {
                        editingMarked ? setState(() => marked.value = pos) : await launchApp(app);
                      },
                      location: AppLocation.home,
                      state: editing ? TileState.groupEdit : TileState.standard,
                      rippleProgress: rippleProgress,
                      pos: pos,
                      editReset: editReset,
                      data: data,
                    ),
                  ),
          );
          break;

        case folderSplit:
          final List<String> items = entry.split(folderSplit);
          final List<String> data = items[1].split(configSplit);

          tiles.add(
            marked.value == pos
                ? ValueListenableBuilder<EdgeInsets>(
                    key: ValueKey<String>('$index-${entry.split(folderSplit)[0]}'),
                    valueListenable: editTilePadding,
                    builder: (_, EdgeInsets padding, __) => Container(
                      padding: padding,
                      decoration: config.boxDeco(
                        border: config.boxBorder(fill: config.secondaryContainerFill),
                        borderRadius: config.buttonShape.textRadius,
                        fill: config.secondaryFill,
                        opacity: focusOpacity,
                      ),
                      child: FolderTile(
                        config,
                        appInfo: appInfo,
                        state: editing ? TileState.groupEdit : TileState.standard,
                        rippleProgress: rippleProgress,
                        editReset: editReset,
                        name: items[0],
                        appList: items.length > 2 ? items.sublist(2) : <String>[],
                        pos: pos,
                        data: data,
                      ),
                    ),
                  )
                : Padding(
                    key: ValueKey<String>('$index-${entry.split(folderSplit)[0]}'),
                    padding: tilePadding(config, data[0], editing),
                    child: FolderTile(
                      config,
                      appInfo: appInfo,
                      state: editing ? TileState.groupEdit : TileState.standard,
                      rippleProgress: rippleProgress,
                      editReset: editReset,
                      name: items[0],
                      appList: items.length > 2 ? items.sublist(2) : <String>[],
                      pos: pos,
                      data: data,
                    ),
                  ),
          );
          break;

        case widgetSplit:
          final List<String> items = entry.split(widgetSplit);
          final List<String> data = items[1].split(configSplit);

          tiles.add(
            marked.value == pos
                ? ValueListenableBuilder<EdgeInsets>(
                    key: ValueKey<String>('$index-${entry.split(widgetSplit)[0]}'),
                    valueListenable: editTilePadding,
                    builder: (_, EdgeInsets padding, __) => EzOpaqueGD(
                      onTap: doNothing,
                      kid: Container(
                        padding: padding,
                        decoration: config.boxDeco(
                          border: config.boxBorder(fill: config.secondaryContainerFill),
                          borderRadius: config.buttonShape.textRadius,
                          fill: config.secondaryFill,
                          opacity: focusOpacity,
                        ),
                        child: drawWidget(
                          config,
                          appInfo: appInfo,
                          typeString: items[0],
                          state: editing ? TileState.groupEdit : TileState.standard,
                          rippleProgress: rippleProgress,
                          editReset: editReset,
                          pos: pos,
                          data: data,
                        ),
                      ),
                    ),
                  )
                : EzOpaqueGD(
                    key: ValueKey<String>('$index-${entry.split(widgetSplit)[0]}'),
                    onTap: editingMarked ? () => setState(() => marked.value = pos) : null,
                    absorb: editingMarked,
                    kid: Padding(
                      padding: tilePadding(config, data[0], editing),
                      child: drawWidget(
                        config,
                        appInfo: appInfo,
                        typeString: items[0],
                        state: editing ? TileState.groupEdit : TileState.standard,
                        rippleProgress: rippleProgress,
                        editReset: editReset,
                        pos: pos,
                        data: data,
                      ),
                    ),
                  ),
          );
          break;

        case spacerSplit:
          tiles.add(
            Padding(
              key: ValueKey<String>('$index-spacer-$editing'),
              padding: tilePadding(config, zeroTPS, editing),
              child: LimSpacer(
                config,
                appInfo: appInfo,
                pos: pos,
                state: editing ? TileState.groupEdit : TileState.standard,
                rippleProgress: rippleProgress,
                stateCheck: () => setState(() => editing = false),
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
    EzProvider config,
    AppInfoProvider appInfo, {
    required int numLanes,
    required int lane,
    required ListAlignment hAlign,
    required ListAlignment vAlign,
  }) =>
      editing
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
                        oldIndex: (oldIndex + 1),
                        newIndex: (newIndex + 1), // +1 for config entry
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: vAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              children: _buildTiles(config, appInfo, lane, hAlign: hAlign, vAlign: vAlign),
            );

  Widget buildPage(
    EzProvider config,
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

    return Container(
      constraints: const BoxConstraints.tightFor(height: double.infinity, width: double.infinity),
      alignment: LAConfig.merge(h: hAlign, v: vAlign),
      child: _buildLane(
        config,
        appInfo,
        numLanes: numLanes,
        lane: lane,
        hAlign: hAlign,
        vAlign: vAlign,
      ),
    );
  }

  List<Widget> buildGrid(EzProvider config, AppInfoProvider appInfo, int numLanes) {
    final List<Widget> lanes = <Widget>[];

    for (int lane = 0; lane < numLanes; lane++) {
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

      lanes.add(
        ValueListenableBuilder<double>(
          valueListenable: rippleProgress,
          builder: (_, double ripple, __) => ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: double.infinity,
              minWidth: appIconSize(config) + config.spacing,
              maxWidth: (editing && (ripple % 1.0 == 0))
                  ? (appIconSize(config) * 3) + (config.spargin * 2)
                  : widthOf(context),
            ),
            child: Align(
              alignment: LAConfig.merge(h: hAlign, v: vAlign),
              widthFactor: 1.0,
              child: _buildLane(
                config,
                appInfo,
                numLanes: numLanes,
                lane: lane,
                hAlign: hAlign,
                vAlign: vAlign,
              ),
            ),
          ),
        ),
      );
    }
    return lanes;
  }

  // Init //

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // Check for welcome message(s)
    if (!EzManager.get(shownIntroKey)) {
      if (context.mounted) await context.pushNamed(welcomeScreenName);
      await EzManager.setBool(shownIntroKey, true);
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
      child: Consumer2<EzProvider, AppInfoProvider>(
        builder: (_, EzProvider config, AppInfoProvider appInfo, __) {
          final int numLanes = appInfo.numLanes(config);
          final double headerSpacing = config.iconSize + config.padding + (config.spacing / 2);

          return LiminalScaffold(
            config,
            body: Semantics(
              label: l10n(config).hsHomeHint,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (LongPressStartDetails details) async => editing
                    ? await ripple(config, details)
                    : await canEdit(config, () => ripple(config, details)),
                onVerticalDragStart: (DragStartDetails details) =>
                    _tmpVertSwipeStart = details.globalPosition,
                onVerticalDragEnd: (DragEndDetails details) async {
                  if (details.primaryVelocity != null) {
                    if (editingMarked ||
                        !(details.primaryVelocity! < -ezSwipeV) ||
                        _tmpVertSwipeStart.dy > trayOffset) {
                      return;
                    }
                    await swipeUp(config, appInfo);
                  }
                },
                onHorizontalDragEnd: (DragEndDetails details) async {
                  if (details.primaryVelocity != null && details.primaryVelocity! != 0) {
                    if (pages(config)) {
                      if (details.primaryVelocity! < -ezSwipeV) {
                        // Swipe right to left -> nav to right
                        final bool moved = await (standardFlow(config)
                            ? navPageUp(config, appInfo, numLanes)
                            : navPageDown(config, appInfo, numLanes));

                        if (moved) return;
                      }

                      if (details.primaryVelocity! > ezSwipeV) {
                        // Swipe left to right -> nav to left
                        final bool moved = await (standardFlow(config)
                            ? navPageDown(config, appInfo, numLanes)
                            : navPageUp(config, appInfo, numLanes));

                        if (moved) return;
                      }
                    }
                    if (editing || editingMarked) return;

                    final AppInfo? toLaunch = ((details.primaryVelocity! < -ezSwipeV)
                        ? appInfo.appMap[leftSwipeID]
                        : appInfo.appMap[rightSwipeID]);

                    if (toLaunch != null) await launchApp(toLaunch);
                  }
                },
                // App list
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    switch (notification.runtimeType) {
                      case const (OverscrollNotification):
                        if (notification.metrics.axis == Axis.vertical) {
                          if (editingMarked) return true;

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
                          if (editing || editingMarked) return true;

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
                              mainAxisAlignment: horizontalAlign(config).mainAxis,
                              crossAxisAlignment: verticalAlign(config).crossAxis,
                              children: buildGrid(config, appInfo, numLanes),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            fabs: editing
                ? <Widget>[
                    config.spacer,
                    SettingsFAB(config, appInfo, () {
                      context.goNamed(settingsScreenName);
                      if (resetAfterEdit(config)) setState(() => editing = false);
                    }),
                  ]
                : null,
            isHome: true,
          );
        },
      ),
    );
  }
}
