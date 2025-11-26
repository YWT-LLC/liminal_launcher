/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Gather the fixed theme data //

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  final ListAlignment hAlign =
      ListAlignmentConfig.fromValue(EzConfig.get(homeHAlignKey));
  final ListAlignment vAlign =
      ListAlignmentConfig.fromValue(EzConfig.get(homeVAlignKey));

  final bool listIcon = EzConfig.get(listIconKey);
  final LabelType listLabel =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  final bool folderIcon = EzConfig.get(folderIconKey);
  final LabelType folderLabel =
      LabelTypeConfig.fromValue(EzConfig.get(folderLabelTypeKey));

  // Define the build data //

  final bool homeTime = EzConfig.get(homeTimeKey);
  final bool homeDate = EzConfig.get(homeDateKey);

  late final AppInfoProvider listener = Provider.of<AppInfoProvider>(context);
  late final AppInfoProvider editor =
      Provider.of<AppInfoProvider>(context, listen: false);

  late List<Widget> homeTiles = homeA2T();

  late final Map<String, dynamic> appListData = listData(
    listCheck: (String id) => !listener.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    refresh: refresh,
  );

  bool atBottom = false;

  bool editing = false;
  late final OverlayState overlay = Overlay.of(context);
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define custom functions //

  void refresh() {
    homeTiles = homeA2T();
    setState(() {});
  }

  /// home apps to tiles
  /// listener.homeList -> AppTile/AppFolder
  List<Widget> homeA2T() {
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < listener.homeList.length; index++) {
      final String item = listener.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppFolder(
            listener: listener,
            editor: editor,
            index: index,
            hAlign: hAlign,
            folderLabel: folderLabel,
            folderIcon: listIcon,
            appIcon: listIcon,
            appLabel: listLabel,
            editing: editing ? null : false,
            refresh: refresh,
            rippleProgress: rippleProgress,
          ),
        ));
      } else {
        final AppInfo app = listener.appMap[parts[0]] ?? nullApp;
        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppTile(
            app: app,
            listener: listener,
            editor: editor,
            onHomeScreen: true,
            hAlign: hAlign,
            labelType: listLabel,
            showIcon: listIcon,
            onSelected: (String id) => launchApp(id),
            editing: editing ? null : false,
            refresh: refresh,
            rippleProgress: rippleProgress,
          ),
        ));
      }
    }

    return tileList;
  }

  // Define custom Widgets //

  Widget clock(TextTheme textTheme) => (homeTime || homeDate)
      ? Padding(
          padding: EdgeInsets.only(
            top: vAlign == ListAlignment.start ? 0 : spacing,
            bottom: vAlign == ListAlignment.start ? spacing : 0,
          ),
          child: Clock(
            homeTime: homeTime,
            homeDate: homeDate,
            hAlign: hAlign,
            textTheme: textTheme,
          ),
        )
      : const SizedBox.shrink();

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (LongPressStartDetails details) async {
          final bool needAuth = !editing && (EzConfig.get(authToEditKey));
          // Check every time so no reset is required; O(1)

          if (needAuth) {
            bool authed = false;

            try {
              authed = await LocalAuthentication().authenticate(
                localizedReason: 'Authenticate to continue',
              );
            } catch (e) {
              if (context.mounted) {
                ezLogAlert(context, message: e.toString());
              }
            }

            if (!authed) return;
          }

          if (context.mounted) {
            // Ripple transition to editing
            final AnimationController rippleController =
                AnimationController(vsync: overlay, duration: rippleDuration);
            rippleController.addListener(
                () => rippleProgress.value = rippleController.value);

            final OverlayEntry ripple = ezRipple(
              controller: rippleController,
              width: widthOf(context),
              height: heightOf(context),
              position: details.globalPosition,
              color: colorScheme.primary,
              oMin: crucialOT,
            );
            overlay.insert(ripple);
            lastRipple = details.globalPosition;

            rippleController.forward().whenComplete(() {
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
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              context.goNamed(
                appListPath,
                extra: editing
                    ? listData(
                        listCheck: (String id) =>
                            listener.hiddenSet.contains(id),
                        onSelected: (String id) => launchApp(id),
                        icon: EzTextBackground(EzRow(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Hidden\t', style: textTheme.labelLarge),
                            EzIcon(
                              PlatformIcons(context).eyeSlash,
                              color: colorScheme.onSurface,
                            ),
                          ],
                        )),
                        refresh: refresh,
                      )
                    : appListData,
              );
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! != 0) {
            AppInfo? toLaunch;

            if (details.primaryVelocity! < 0) {
              if (editing) {
                doNothing();
              } else {
                toLaunch = listener.appMap[EzConfig.get(leftSwipeIDKey)];
              }
            } else {
              if (editing) {
                editing = false;
                refresh();
              } else {
                toLaunch = listener.appMap[EzConfig.get(rightSwipeIDKey)];
              }
            }

            if (toLaunch != null) launchApp(toLaunch.package);
          }
        },
        child: Column(
          mainAxisAlignment: vAlign.mainAxis,
          crossAxisAlignment: hAlign.crossAxis,
          children: <Widget>[
            if (vAlign == ListAlignment.start) clock(textTheme),

            // App list
            editing
                ? NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is OverscrollNotification &&
                          notification.overscroll > 0) {
                        // Navigate on bottom overscroll
                        if (atBottom) {
                          context.goNamed(
                            appListPath,
                            extra: listData(
                              listCheck: (String id) =>
                                  listener.hiddenSet.contains(id),
                              onSelected: (String id) => launchApp(id),
                              icon: EzTextBackground(EzRow(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('Hidden\t', style: textTheme.labelLarge),
                                  EzIcon(
                                    PlatformIcons(context).eyeSlash,
                                    color: colorScheme.onSurface,
                                  ),
                                ],
                              )),
                              refresh: refresh,
                            ),
                          );
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
                            (notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent));
                      }
                      return false; // Let other notifications propagate
                    },
                    child: Expanded(
                      child: ReorderableListView(
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
                          await editor.reorderHomeItem(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          );
                          refresh();
                        },
                        children: homeTiles,
                      ),
                    ),
                  )
                : EzScrollView(
                    mainAxisAlignment: vAlign.mainAxis,
                    crossAxisAlignment: hAlign.crossAxis,
                    children: homeTiles,
                  ),

            if (vAlign == ListAlignment.end) clock(textTheme),
          ],
        ),
      ),
      fabs: editing
          ? <Widget>[
              ezSpacer,

              // Add app
              AddAppFAB(
                context,
                () => context.goNamed(
                  appListPath,
                  extra: listData(
                    listCheck: (String id) =>
                        !listener.hiddenSet.contains(id) &&
                        !listener.homeSet.contains(id),
                    onSelected: (String id) => editor.addHomeApp(id),
                    refresh: refresh,
                    autoRefresh: true,
                    icon: EzTextBackground(EzRow(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Home\t', style: textTheme.labelLarge),
                        EzIcon(
                          PlatformIcons(context).add,
                          color: colorScheme.onSurface,
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              ezSpacer,

              // Add folder
              AddFolderFAB(context, () {
                editor.addHomeFolder();
                refresh();
              }),
              ezSpacer,

              // Settings
              SettingsFAB(context, () => context.goNamed(settingsHomePath))
            ]
          : null,
    );
  }
}
