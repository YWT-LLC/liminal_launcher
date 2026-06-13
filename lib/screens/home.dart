/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

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

  bool atBottom = false;
  Timer? overscrollPause;

  bool editing = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  List<int> _janitor = <int>[];

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

  /// appProvider.homeList -> AppTile/FolderTile
  List<Widget> buildTiles(EzCP config, AppInfoProvider appInfo) {
    final EdgeInsets tilePadding = EdgeInsets.symmetric(vertical: config.spacing / 2);
    final List<Widget> tileList = <Widget>[];
    final List<int> errors = <int>[];

    for (int index = 0; index < appInfo.homeList.length; index++) {
      final String item = appInfo.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: tilePadding,
          child: FolderTile(
            config,
            appInfo: appInfo,
            index: index,
            state: editing ? AppState.groupEdit : AppState.standard,
            rippleProgress: rippleProgress,
          ),
        ));
      } else {
        final AppInfo? app = appInfo.appMap[parts[0]];
        if (app == null) {
          errors.add(index);
          continue;
        }

        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: tilePadding,
          child: AppTile(
            config,
            appInfo: appInfo,
            app: app,
            location: AppLocation.home,
            state: editing ? AppState.groupEdit : AppState.standard,
            onSelected: (AppInfo app) => launchApp(app),
            rippleProgress: rippleProgress,
          ),
        ));
      }
    }

    _janitor = errors;
    return tileList;
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
  void afterFirstLayout(BuildContext context) async {
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
                      '''Personalizing your launcher should be straightforward, with one potential exception: the dark and light theme appearances can be completely separate!
                
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
                  text: " themes.\n\nLong press the home screen to edit, and you're off!",
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
    return Consumer2<AppInfoProvider, EzCP>(builder: (_, AppInfoProvider appInfo, EzCP config, __) {
      final bool topClock = topAlign.contains(vAlign(config));
      final double clockSpacing = (config.spacing * 2) - (config.padding + (config.spacing / 2));
      final Widget clockSpacer =
          (clockSpacing > 0 ? EzSpacer(clockSpacing) : const SizedBox.shrink());

      return LiminalScaffold(
        config,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (LongPressStartDetails details) async => editing
              ? await ripple(config, details)
              : await canEdit(config, () => ripple(config, details)),
          onVerticalDragEnd: (DragEndDetails details) async {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                await swipeUp(config, appInfo);
              }
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity != null && details.primaryVelocity! != 0) {
              AppInfo? toLaunch;

              if (details.primaryVelocity! < 0) {
                // Swiped left
                toLaunch = editing ? null : appInfo.appMap[leftSwipeID(config)];
              } else {
                // Swiped right
                if (editing) {
                  setState(() => editing = false);
                } else {
                  toLaunch = appInfo.appMap[rightSwipeID(config)];
                }
              }

              if (toLaunch != null) launchApp(toLaunch);
            }
          },
          child: EzCol(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: vAlign(config).mainAxis,
            crossAxisAlignment: hAlign(config).crossAxis,
            children: <Widget>[
              // Clock I
              if (topClock) ...<Widget>[Clock(config), clockSpacer],

              // App list
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    switch (notification.runtimeType) {
                      case const (OverscrollNotification):
                        if (notification.metrics.axis == Axis.vertical &&
                            (notification as OverscrollNotification).overscroll <= 0) {
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
                  child: Container(
                    alignment: LAConfig.merge(h: hAlign(config), v: vAlign(config)),
                    child: editing
                        ? Builder(builder: (_) {
                            final List<Widget> tiles = buildTiles(config, appInfo);

                            return StatefulBuilder(
                              builder: (_, StateSetter setList) => ReorderableListView(
                                shrinkWrap: true,
                                onReorderItem: (int oldIndex, int newIndex) {
                                  if (oldIndex == newIndex) return;

                                  final Widget element = tiles.removeAt(oldIndex);
                                  tiles.insert(newIndex, element);

                                  appInfo.reorderHome(oldIndex, newIndex);
                                  setList(() {});
                                },
                                children: tiles,
                              ),
                            );
                          })
                        : EzScrollView(
                            config,
                            mainAxisAlignment: vAlign(config).mainAxis,
                            crossAxisAlignment: hAlign(config).crossAxis,
                            physics: const ClampingScrollPhysics(),
                            children: buildTiles(config, appInfo),
                          ),
                  ),
                ),
              ),

              // Clock II
              if (!topClock) ...<Widget>[clockSpacer, Clock(config)],
            ],
          ),
        ),
        fabs: editing
            ? <Widget>[
                config.spacer,

                // Add app
                AddAppFAB(
                  config,
                  () => context.goNamed(
                    appListPath,
                    extra: ListConfig(
                      listContent: <ListContent>{
                        ListContent.home,
                        ListContent.hidden,
                        ListContent.banished,
                      },
                      include: false,
                      onSelected: (AppInfo app) => appInfo.addHomeApp(app.id),
                      title: EzTextIconButton(
                        config,
                        onPressed: doNothing,
                        label: 'Home',
                        icon: EzIcon(config, Icons.add, color: config.colors.onSurface),
                        textStyle: config.labelStyle,
                      ),
                    ),
                  ),
                ),
                config.spacer,

                // Add folder
                AddFolderFAB(config, appInfo.addHomeFolder),
                config.spacer,

                // Settings
                SettingsFAB(
                  config,
                  () => context.goNamed(settingsPath),
                ),
              ]
            : null,
        isHome: true,
      );
    });
  }

  @override
  void dispose() {
    if (_janitor.isNotEmpty) Provider.of<AppInfoProvider>(context, listen: false).cleanup(_janitor);
    super.dispose();
  }
}
