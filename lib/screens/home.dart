/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'dart:math';
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

  bool atBottom = false;
  Timer? overscrollPause;

  bool editing = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  final Map<int, List<int>> _janitor = <int, List<int>>{};

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

  List<Widget> buildGrid(EzCP config, AppInfoProvider appInfo) {
    final List<Widget> lanes = <Widget>[];
    final int numLanes = appInfo.numLanes(config);

    final double minWidth = appIconSize(config) + config.spacing;
    final double maxWidth = max(minWidth, widthOf(context) / numLanes);

    for (int lane = 0; lane < numLanes; lane++) {
      lanes.add(ConstrainedBox(
        constraints: // TODO: this needs more tweaking now that all kinds can coexist
            BoxConstraints(minHeight: double.infinity, minWidth: minWidth, maxWidth: maxWidth),
        child: editing
            ? Builder(builder: (_) {
                final List<Widget> tiles = _buildTiles(config, appInfo, lane);

                return StatefulBuilder(
                  key: ValueKey<String>('lane-$lane'),
                  builder: (_, StateSetter setList) => ReorderableListView(
                    shrinkWrap: true,
                    onReorderItem: (int oldIndex, int newIndex) {
                      if (oldIndex == newIndex) return;

                      final Widget element = tiles.removeAt(oldIndex);
                      tiles.insert(newIndex, element);

                      appInfo.reorderHomeList(
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
                mainAxisAlignment: vAlign(config).mainAxis,
                crossAxisAlignment: hAlign(config).crossAxis,
                physics: const ClampingScrollPhysics(),
                children: _buildTiles(config, appInfo, lane),
              ),
      ));
    }

    return lanes;
  }

  /// appProvider.homeList -> AppTile/FolderTile
  List<Widget> _buildTiles(EzCP config, AppInfoProvider appInfo, int lane) {
    final List<String> entries = appInfo.homeList(config, lane);
    final EdgeInsets tilePadding = EdgeInsets.symmetric(vertical: config.spacing / 2);

    final List<Widget> toReturn = <Widget>[];
    final List<int> errors = <int>[];

    for (int index = 0; index < entries.length; index++) {
      final String entry = entries[index];

      final RegExpMatch? splitMatch = tileRegex.firstMatch(entry);
      final String? delim = splitMatch?.group(0);

      switch (delim) {
        case idSplit:
          final AppInfo? app = appInfo.appMap[entry];
          if (app == null) {
            errors.add(index);
            continue;
          }

          toReturn.add(Padding(
            key: ValueKey<String>(app.id),
            padding: tilePadding,
            child: AppTile(
              config,
              appInfo: appInfo,
              app: app,
              location: AppLocation.home,
              lane: lane,
              state: editing ? AppState.groupEdit : AppState.standard,
              onSelected: (AppInfo app) => launchApp(app),
              rippleProgress: rippleProgress,
            ),
          ));
          break;

        case folderSplit:
          toReturn.add(Padding(
            key: ValueKey<String>('$index-${entry.split(folderSplit)[0]}'),
            padding: tilePadding,
            child: FolderTile(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
            ),
          ));
          break;

        case widgetSplit:
          toReturn.add(Padding(
            key: ValueKey<String>('$index-${entry.split(widgetSplit)[0]}'),
            padding: tilePadding,
            child: renderWidget(
              config,
              appInfo: appInfo,
              lane: lane,
              index: index,
              state: editing ? AppState.groupEdit : AppState.standard,
              rippleProgress: rippleProgress,
            ),
          ));
          break;

        case spacerSplit:
          final List<String> data = entry.split(spacerSplit);
          final double height = double.tryParse(data[0]) ?? config.spacing;
          final double width = double.tryParse(data[1]) ?? appIconSize(config);

          toReturn.add(LimSpacer(
            config,
            key: ValueKey<String>('$index-$height-$width-$editing'),
            height: height,
            width: width,
            state: editing ? AppState.groupEdit : AppState.standard,
          ));
          break;

        default:
          break;
      }
    }

    _janitor[lane] = errors;

    if (editing && appInfo.numLanes(config) > 1) {
      toReturn.insert(
        0,
        EzRow(
          config,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          key: ValueKey<String>('lane-$lane-controls'),
          children: <Widget>[
            Padding(
              padding: tilePadding,
              child: MenuAnchor(
                builder: (_, MenuController controller, __) => EzIconButton(
                  config,
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  icon: EzIcon(config, Icons.edit),
                ),
                menuChildren: <Widget>[
                  // Left
                  if (lane > 0) // TODO: wurks in end mode? centa?
                    MenuItemButton(
                      onPressed: doNothing,
                      child: EzIcon(config, Icons.keyboard_arrow_left),
                    ),

                  // Begone
                  MenuItemButton(
                    onPressed: () => appInfo.deleteLane(config, lane),
                    child: EzIcon(config, Icons.delete),
                  ),

                  // Right
                  if (lane < appInfo.numLanes(config) - 1)
                    MenuItemButton(
                      onPressed: doNothing,
                      child: EzIcon(config, Icons.keyboard_arrow_right),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return toReturn;
  }

  Future<void> swipeUp(EzCP config, AppInfoProvider appInfo) async => (editing)
      ? await navToHidden(config, appInfo)
      : context.goNamed(
          appListPath,
          extra: ListConfig(
            listContent: <ListContent>{ListContent.hidden, ListContent.banished},
            include: false,
            onSelected: (AppInfo app) => launchApp(app),
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
          onSelected: (AppInfo app) => launchApp(app),
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
      final bool isGPlay = await isGPlayInstall();

      if (context.mounted) {
        await ezModal(
          config,
          context: context,
          builder: (_) => ezModalScroll(config, children: <Widget>[
            Text(
              'Welcome to Liminal Launcher',
              textAlign: TextAlign.center,
              style: config.titleStyle,
            ),
            Text(
              'I hope it serves you well!',
              textAlign: TextAlign.center,
              style: config.bodyStyle,
            ),
            config.centerLine,
            Text(
              "It's geared toward minimalism, but with limitless customization.\nWho said minimal has to be boring?",
              textAlign: TextAlign.center,
              style: config.bodyStyle,
            ),
            config.centerLine,
            EzRichText(
              config,
              children: <InlineSpan>[
                EzPlainText(
                  text:
                      '''Personalizing your launcher is simple, with one potential exception: most settings (appearance AND app list) can be completely separate for dark/light themes!
                
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
                  text: ' themes.\n\nLong press the home screen to get started!',
                  style: config.bodyStyle,
                ),
              ],
              textAlign: TextAlign.center,
              style: config.bodyStyle,
            ),
            if (!isGPlay) ...<Widget>[
              config.divider,
              EzRichText(
                config,
                children: <InlineSpan>[
                  const EzPlainText(
                    text: '''This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

If you want to support Liminal's development, or the development of more Empathetech software, please consider ''',
                  ),
                  EzInlineLink(
                    config,
                    text: 'contributing',
                    style: config.bodyStyle,
                    textAlign: TextAlign.center,
                    url: Uri.parse('https://www.empathetech.net/#/contribute'),
                    hint: 'Open a link to the Empathetic contribution options.',
                  ),
                  const EzPlainText(
                    text:
                        '.\n\nThis is the only non-tutorial pop-up, and its only appearance this install.',
                  ),
                ],
                style: config.bodyStyle,
                textBackground: false,
                textAlign: TextAlign.center,
              ),
            ],
            config.centerLine,
            Text(
              'Thank you, and enjoy!',
              textAlign: TextAlign.center,
              style: config.bodyStyle,
            ),
            config.separator,
          ]),
        );
      }
      await EzCM.setBool(shownIntroKey, true);
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer2<EzCP, AppInfoProvider>(builder: (_, EzCP config, AppInfoProvider appInfo, __) {
      // Widget layer setup stuffs

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
              final AppInfo? toLaunch = editing
                  ? null
                  : ((details.primaryVelocity! < 0)
                      ? appInfo.appMap[leftSwipeID]
                      : appInfo.appMap[rightSwipeID]);

              if (toLaunch != null) launchApp(toLaunch);
            }
          },
          child: EzCol(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: vAlign(config).mainAxis,
            crossAxisAlignment: hAlign(config).crossAxis,
            children: <Widget>[
              // TODO: implement top widgets

              // App list
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    switch (notification.runtimeType) {
                      case const (OverscrollNotification):
                        if (notification.metrics.axis == Axis.vertical &&
                            (notification as OverscrollNotification).overscroll > 0) {
                          if (atBottom) {
                            swipeUp(config, appInfo);
                            return true;
                          } else {
                            overscrollPause = Timer(
                              scrollDelay,
                              () => setState(() => atBottom = true),
                            );
                            return true;
                          }
                        }
                        break;

                      case const (ScrollUpdateNotification):
                        if (atBottom && notification.metrics.pixels < 0) {
                          setState(() => atBottom = false);
                        }
                        break;

                      case const (ScrollEndNotification):
                        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                          overscrollPause = Timer(
                            scrollDelay,
                            () => setState(() => atBottom = true),
                          );
                        } else {
                          setState(() => atBottom = false);
                        }
                        break;
                    }
                    return false;
                  },
                  child: EzScrollView(
                    config,
                    showScrollHint: homeHints,
                    mainAxisSize: MainAxisSize.max,
                    scrollDirection: Axis.horizontal,
                    mainAxisAlignment: hAlign(config).mainAxis,
                    crossAxisAlignment: vAlign(config).crossAxis,
                    children: buildGrid(config, appInfo),
                  ),
                ),
              ),

              // TODO: implement bottom widgets
            ],
          ),
        ),
        fabs: editing
            ? <Widget>[
                config.spacer,

                // Add (iff one list)
                if (appInfo.numLanes(config) == 1) ...<Widget>[
                  AddFAB(config, () async {
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
                                      ListContent.home,
                                      ListContent.hidden,
                                      ListContent.banished,
                                    },
                                    include: false,
                                    onSelected: (AppInfo app) => appInfo.addHomeApp(
                                      config,
                                      lane: 0,
                                      id: app.id,
                                    ),
                                    title: EzTextIconButton(
                                      config,
                                      onPressed: doNothing,
                                      label: 'Home',
                                      icon:
                                          EzIcon(config, Icons.add, color: config.colors.onSurface),
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
                                onPressed: () => appInfo.addHomeFolder(config, 0),
                                label: 'Folder',
                                icon: EzIcon(config, Icons.folder_open),
                              ),
                            ),

                            // Widgets
                            Padding(
                              padding: EzInsets.wrap(config.spacing),
                              child: EzElevatedIconButton(
                                config,
                                onPressed: () => ezModal(config, context: context, builder: (_) {
                                  WidgetSize size = WidgetSize.system;
                                  WidgetSize prevSize = bt2WS(config);

                                  return StatefulBuilder(
                                    builder: (BuildContext wCon, StateSetter setModal) =>
                                        ezModalScroll(config, children: <Widget>[
                                      EzDropdownMenu<WidgetSize>(
                                        config,
                                        enableSearch: false,
                                        initialSelection: size,
                                        widthEntry: WidgetSize.unbound.value,
                                        dropdownMenuEntries: WidgetSize.values
                                            .map((WidgetSize ws) => DropdownMenuEntry<WidgetSize>(
                                                  value: ws,
                                                  label: ezCamelToTitle(ws.value),
                                                ))
                                            .toList(),
                                        onSelected: (WidgetSize? choice) {
                                          if (choice == null) return;
                                          size = choice;
                                          prevSize = (choice == WidgetSize.system)
                                              ? bt2WS(config)
                                              : choice;

                                          setModal(() {});
                                        },
                                      ),
                                      config.separator,

                                      // Calendar
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.calendar,
                                              size,
                                            ),
                                            icon: EzIcon(config, Icons.edit_calendar),
                                          ),
                                      },
                                      config.spacer,

                                      // Clock
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.clock,
                                              size,
                                            ),
                                            icon: EzIcon(config, Icons.watch),
                                          ),
                                      },
                                      // TODO: differentiate these two
                                      config.spacer,

                                      // Search
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.search,
                                              size,
                                              extra: <String>[Engine.ducks.value],
                                            ),
                                            icon: EzIcon(config, Icons.search),
                                          ),
                                      },
                                      config.spacer,

                                      // Stopwatch
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.stopwatch,
                                              size,
                                            ),
                                            icon: EzIcon(config, Icons.watch),
                                          ),
                                      }, // TODO: THIS'UN
                                      config.spacer,

                                      // Timer
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.timer,
                                              size,
                                            ),
                                            icon: EzIcon(config, Icons.timer),
                                          ),
                                      },
                                      config.spacer,

                                      // Toggle media
                                      switch (prevSize) {
                                        _ => EzIconButton(
                                            config,
                                            onPressed: () => appInfo.addHomeWidget(
                                              config,
                                              0,
                                              WidWidGetGet.toggleMedia,
                                              size,
                                            ),
                                            icon: EzIcon(config, Icons.headphones),
                                          ),
                                      },
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
                                onPressed: doNothing,
                                label: 'Spacer',
                                icon: EzIcon(config, Icons.space_bar),
                              ),
                            ),

                            // Lane
                            Padding(
                              padding: EzInsets.wrap(config.spacing),
                              child: EzElevatedIconButton(
                                config,
                                onPressed: () => appInfo.addHomeLane(config),
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

...settings, you can fit up to ${(screenWidth / (config.iconSize + config.padding + config.spacing)).toStringAsFixed(2)} lanes on your screen. With the minimum values, you could fit up to ${(screenWidth / (minIconSize + minPadding + minSpacing)).toStringAsFixed(2)} lanes.''',
                              ), // TODO: second part doesn't appear iff already at min
                            ],
                          ),
                          config.separator,
                        ],
                      ),
                    );
                  }),
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

  @override
  void dispose() {
    final AppInfoProvider appWatcher = Provider.of<AppInfoProvider>(context, listen: false);

    if (_janitor.isNotEmpty) {
      _janitor.forEach((int lane, List<int> entries) => appWatcher.cleanup(
            configWatcher(context),
            lane: lane,
            entries: entries,
          ));
    }

    super.dispose();
  }
}
