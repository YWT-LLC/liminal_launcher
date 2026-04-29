/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:after_layout/after_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super(key: ValueKey<int>(EzConfig.seed));

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AfterLayoutMixin<HomeScreen> {
  // Define build data //

  bool atBottom = false;
  bool editing = false;

  late final OverlayState overlay = Overlay.of(context);
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  late List<Widget> homeTiles = homeA2T();

  // Define custom functions //

  /// home apps to tiles
  /// appProvider.homeList -> AppTile/AppFolder
  /// TODO: post-audit(s): I don't like this... should prolly be in build
  List<Widget> homeA2T() {
    final EdgeInsets tilePadding = EdgeInsets.symmetric(vertical: EzConfig.spacing / 2);
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < appInfo.homeList.length; index++) {
      final String item = appInfo.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: tilePadding,
          child: AppFolder(
            index: index,
            editing: editing ? null : false,
            onEdit: refresh,
            rippleProgress: rippleProgress,
          ),
        ));
      } else {
        final AppInfo app = appInfo.appMap[parts[0]] ?? nullApp;

        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: tilePadding,
          child: AppTile(
            app: app,
            onHomeScreen: true,
            onSelected: (String id) => launchApp(id),
            editing: editing ? null : false,
            onEdit: refresh,
            rippleProgress: rippleProgress,
          ),
        ));
      }
    }

    return tileList;
  }

  void refresh() {
    homeTiles = homeA2T();
    setState(() {});
  }

  Future<void> swipeUp() async {
    if (editing) {
      await navToHidden(context);
    } else {
      context.goNamed(
        appListPath,
        extra: ListConfig(
          ids: <String>{...appInfo.hiddenSet, ...appInfo.banishedSet},
          include: false,
          onSelected: (String id) => launchApp(id),
          title: null,
        ),
      );
    }
  }

  Future<void> navToHidden(BuildContext context) async {
    if (bool.tryParse(await EzConfig.secGet(authForHiddenKey)) == true) {
      // Check every time so no reset is required; O(1)
      bool authed = false;

      try {
        authed = await liminalAuth('Authenticate to see hidden apps');
      } catch (e) {
        ezLog(e.toString());
      }

      if (!authed) return;
    }

    if (context.mounted) {
      context.goNamed(
        appListPath,
        extra: ListConfig(
          ids: appInfo.hiddenSet,
          include: true,
          onSelected: (String id) => launchApp(id),
          title: EzTextBackground(EzRow(
            children: <Widget>[
              Text('Hidden\t', style: EzConfig.styles.labelLarge),
              EzIcon(
                Icons.visibility_off,
                color: EzConfig.colors.onSurface,
              ),
            ],
          )),
        ),
      );
    }
  }

  // Define custom Widgets //

  Widget clock() => (homeTime || homeDate != DateType.none)
      ? Padding(
          padding: EdgeInsets.only(
            top: vAlign == ListAlignment.start ? 0 : EzConfig.spacing,
            bottom: vAlign == ListAlignment.start ? EzConfig.spacing : 0,
          ),
          child: const Clock(),
        )
      : const SizedBox.shrink();

  // Init //

  @override
  void afterFirstLayout(BuildContext context) async {
    // Check for welcome message
    if (!EzConfig.get(shownIntroKey)) {
      final bool isGPlay = await isGPlayInstall();

      if (context.mounted) {
        await ezModal(
          context: context,
          builder: (_) => EzScrollView(
            children: <Widget>[
              Text(
                'Welcome to Liminal Launcher',
                textAlign: TextAlign.center,
                style: EzConfig.styles.titleLarge,
              ),
              Text(
                'I hope it serves you well!',
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              EzConfig.centerLine,
              Text(
                "It's geared toward minimalism, but with limitless customization.\nWho said minimal has to be boring?",
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              EzConfig.centerLine,
              EzRichText(
                <InlineSpan>[
                  EzPlainText(
                    text:
                        '''Personalizing your launcher should be straightforward, with one potential exception: the dark and light theme appearances can be completely separate!
                
While in the relevant settings, you will see a toggle-able icon that indicates whether you're editing the dark ''',
                    style: EzConfig.styles.bodyLarge,
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: EzIcon(Icons.dark_mode),
                  ),
                  EzPlainText(
                    text: ', light ',
                    style: EzConfig.styles.bodyLarge,
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: EzIcon(Icons.light_mode),
                  ),
                  EzPlainText(
                    text: ', or both ',
                    style: EzConfig.styles.bodyLarge,
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: FaIcon(
                      FontAwesomeIcons.yinYang,
                      size: EzConfig.iconSize,
                    ),
                  ),
                  EzPlainText(
                    text: " themes.\n\nLong press the home screen to edit, and you're off!",
                    style: EzConfig.styles.bodyLarge,
                  ),
                ],
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              if (!isGPlay) ...<Widget>[
                EzConfig.divider,
                EzRichText(
                  <InlineSpan>[
                    const EzPlainText(
                      text: '''This version is not from the Play Store, so it should have been free.
Rest assured, the free version of Liminal will always be identical to the Google Play version.

If you want to support Liminal's development, or the development of more Empathetech software, please consider ''',
                    ),
                    EzInlineLink(
                      'contributing',
                      style: EzConfig.styles.bodyLarge,
                      textAlign: TextAlign.center,
                      url: Uri.parse('https://www.empathetech.net/#/contribute'),
                      hint: 'Open a link to the Empathetic contribution options.',
                    ),
                    const EzPlainText(
                      text:
                          '.\n\nThis is the only non-tutorial pop-up, and its only appearance this install.',
                    ),
                  ],
                  style: EzConfig.styles.bodyLarge,
                  textBackground: false,
                  textAlign: TextAlign.center,
                ),
              ],
              EzConfig.centerLine,
              Text(
                'Thank you, and enjoy!',
                textAlign: TextAlign.center,
                style: EzConfig.styles.bodyLarge,
              ),
              EzConfig.separator,
            ],
          ),
        );
      }
      await EzConfig.setBool(shownIntroKey, true);
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => LiminalScaffold(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (LongPressStartDetails details) async {
            if (!editing && (bool.tryParse(await EzConfig.secGet(authToEditKey)) == true)) {
              // Check every time so no reset is required; O(1)
              bool authed = false;

              try {
                authed = await liminalAuth('Authenticate to edit the launcher');
              } catch (e) {
                ezLog(e.toString());
              }

              if (!authed) return;
            }

            final Duration animDur = ezAnimDuration();
            if (context.mounted && animDur > Duration.zero) {
              // Ripple transition to editing
              final AnimationController rippleController =
                  AnimationController(vsync: overlay, duration: animDur);
              rippleController.addListener(() => rippleProgress.value = rippleController.value);

              final OverlayEntry ripple = ezRipple(
                controller: rippleController,
                width: widthOf(context),
                height: heightOf(context),
                position: details.globalPosition,
                color: EzConfig.colors.primary,
                oMin: focusOpacity,
              );
              overlay.insert(ripple);
              lastRipple = details.globalPosition;

              await rippleController.forward().whenComplete(() {
                rippleProgress = ValueNotifier<double>(0.0);
                editing = !editing;
                refresh();

                ripple.remove();
                rippleController.dispose();
              });
              return;
            }

            // Full transition to editing
            editing = !editing;
            refresh();
          },
          onVerticalDragEnd: (DragEndDetails details) async {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                await swipeUp();
              }
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity != null && details.primaryVelocity! != 0) {
              AppInfo? toLaunch;

              if (details.primaryVelocity! < 0) {
                // Swiped left
                if (editing) {
                  doNothing();
                } else {
                  toLaunch = appInfo.appMap[leftSwipeID];
                }
              } else {
                // Swiped right
                if (editing) {
                  editing = false;
                  refresh();
                } else {
                  toLaunch = appInfo.appMap[rightSwipeID];
                }
              }

              if (toLaunch != null) launchApp(toLaunch.package);
            }
          },
          child: EzCol(
            mainAxisAlignment: vAlign.mainAxis,
            crossAxisAlignment: hAlign.crossAxis,
            children: <Widget>[
              // Clock I
              if (vAlign == ListAlignment.start) clock(),

              // App list
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is OverscrollNotification && notification.overscroll > 0) {
                      if (atBottom) {
                        swipeUp();
                        return true;
                      } else {
                        setState(() => atBottom = true);
                        return true;
                      }
                    } else if (notification is ScrollUpdateNotification) {
                      if (atBottom && notification.metrics.pixels < 0) {
                        setState(() => atBottom = false);
                      }
                    } else if (notification is ScrollEndNotification) {
                      setState(() => atBottom =
                          (notification.metrics.pixels == notification.metrics.maxScrollExtent));
                    }
                    return false; // Let other notifications propagate
                  },
                  child: editing
                      ? ReorderableListView(
                          // TODO: post-audit(s): I sure do hope (and doubt) this still works
                          // TODO: post-audit(s): using on start, on end, and a timer based on hold time: implement put in folder
                          // TODO: post-audit(s): add long hold delay controls to button design, efui up
                          onReorder: (int oldIndex, int newIndex) async {
                            if (oldIndex == newIndex) return;

                            // Local UI update first
                            final Widget toMove = homeTiles.removeAt(oldIndex);
                            homeTiles.insert(
                              oldIndex < newIndex ? newIndex - 1 : newIndex,
                              toMove,
                            );
                            setState(() {});

                            // Storage update
                            await appInfo.reorderHomeItem(
                              oldIndex: oldIndex,
                              newIndex: newIndex,
                            );
                            refresh();
                          },
                          children: homeTiles,
                        )
                      : ConstrainedBox(
                          constraints: wideTiles
                              ? BoxConstraints(minWidth: widthOf(context) * 0.8)
                              : const BoxConstraints(),
                          child: EzScrollView(
                            mainAxisAlignment: vAlign.mainAxis,
                            crossAxisAlignment: hAlign.crossAxis,
                            physics: const ClampingScrollPhysics(),
                            children: homeTiles,
                          ),
                        ),
                ),
              ),

              // Clock II
              if (vAlign == ListAlignment.end) clock(),
            ],
          ),
        ),
        fabs: editing
            ? <Widget>[
                EzConfig.spacer,

                // Add app
                AddAppFAB(() => context.goNamed(
                      appListPath,
                      extra: ListConfig(
                        ids: <String>{
                          ...appInfo.homeSet,
                          ...appInfo.hiddenSet,
                          ...appInfo.banishedSet,
                        },
                        include: false,
                        onSelected: (String id) => appInfo.addHomeApp(id),
                        title: EzTextBackground(EzRow(
                          children: <Widget>[
                            Text('Home\t', style: EzConfig.styles.labelLarge),
                            EzIcon(
                              Icons.add,
                              color: EzConfig.colors.onSurface,
                            ),
                          ],
                        )),
                      ),
                    )),
                EzConfig.spacer,

                // Add folder
                AddFolderFAB(() async {
                  await appInfo.addHomeFolder();
                  refresh();
                }),
                EzConfig.spacer,

                // Settings
                SettingsFAB(() => context.goNamed(settingsHomePath)),
              ]
            : null,
      );
}
