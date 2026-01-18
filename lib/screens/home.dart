/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Define the fixed build data //

  late final AppInfoProvider appProvider =
      Provider.of<AppInfoProvider>(context);

  late final Map<String, dynamic> appListData = listData(
    listCheck: (String id) => !appProvider.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    refresh: refresh,
  );

  final bool wideTiles = EzConfig.get(wideTilesKey);
  bool atBottom = false;
  bool editing = false;

  late final OverlayState overlay = Overlay.of(context);
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define the contextual build data //

  late ListAlignment hAlign;
  late ListAlignment vAlign;

  late bool showTime;
  late String dateType;

  late bool listIcon;
  late LabelType listLabel;

  late bool folderIcon;
  late LabelType folderLabel;

  late List<Widget> homeTiles = homeA2T();

  // Define custom functions //

  /// home apps to tiles
  /// appProvider.homeList -> AppTile/AppFolder
  List<Widget> homeA2T() {
    final EdgeInsets tilePadding =
        EdgeInsets.symmetric(vertical: EzConfig.spacing / 2);
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < appProvider.homeList.length; index++) {
      final String item = appProvider.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: tilePadding,
          child: AppFolder(
            appProvider: appProvider,
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
        final AppInfo app = appProvider.appMap[parts[0]] ?? nullApp;
        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: tilePadding,
          child: AppTile(
            app: app,
            appProvider: appProvider,
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

  void refresh() {
    homeTiles = homeA2T();
    setState(() {});
  }

  Future<void> navToHidden(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) async {
    if (EzConfig.get(authForHiddenKey) == true) {
      // Check every time so no reset is required; O(1)
      bool authed = false;

      try {
        authed = await LocalAuthentication().authenticate(
          localizedReason: 'Authenticate to see hidden apps',
          persistAcrossBackgrounding: true,
          biometricOnly: false,
        );
      } catch (e) {
        ezLog(e.toString());
      }

      if (!authed) return;
    }

    if (context.mounted) {
      context.goNamed(
        appListPath,
        extra: listData(
          listCheck: (String id) => appProvider.hiddenSet.contains(id),
          onSelected: (String id) => launchApp(id),
          icon: EzTextBackground(EzRow(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Hidden\t', style: textTheme.labelLarge),
              EzIcon(
                Icons.visibility_off,
                color: colorScheme.onSurface,
              ),
            ],
          )),
          refresh: refresh,
        ),
      );
    }
  }

  // Define custom Widgets //

  Widget clock(TextTheme textTheme) =>
      (showTime || dateType != DateType.none.configValue)
          ? Padding(
              padding: EdgeInsets.only(
                top: vAlign == ListAlignment.start ? 0 : EzConfig.spacing,
                bottom: vAlign == ListAlignment.start ? EzConfig.spacing : 0,
              ),
              child: Clock(
                showTime: showTime,
                dateType: dateType,
                hAlign: hAlign,
                textTheme: textTheme,
              ),
            )
          : const SizedBox.shrink();

  // Init //

  void setContextualData(bool isDark) {
    if (isDark) {
      hAlign = ListAlignmentConfig.fromValue(EzConfig.get(darkHomeHAlignKey));
      vAlign = ListAlignmentConfig.fromValue(EzConfig.get(darkHomeVAlignKey));

      showTime = EzConfig.get(darkHomeTimeKey);
      dateType = EzConfig.get(darkHomeDateKey);

      listIcon = EzConfig.get(darkListIconKey);
      listLabel = LabelTypeConfig.fromValue(EzConfig.get(darkListLabelTypeKey));

      folderIcon = EzConfig.get(darkFolderIconKey);
      folderLabel =
          LabelTypeConfig.fromValue(EzConfig.get(darkFolderLabelTypeKey));
    } else {
      hAlign = ListAlignmentConfig.fromValue(EzConfig.get(lightHomeHAlignKey));
      vAlign = ListAlignmentConfig.fromValue(EzConfig.get(lightHomeVAlignKey));

      showTime = EzConfig.get(lightHomeTimeKey);
      dateType = EzConfig.get(lightHomeDateKey);

      listIcon = EzConfig.get(lightListIconKey);
      listLabel =
          LabelTypeConfig.fromValue(EzConfig.get(lightListLabelTypeKey));

      folderIcon = EzConfig.get(lightFolderIconKey);
      folderLabel =
          LabelTypeConfig.fromValue(EzConfig.get(lightFolderLabelTypeKey));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setContextualData(isDarkTheme(context));
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setContextualData(isDarkTheme(context));
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    const EzSpacer ezSpacer = EzSpacer();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Return the build //

    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (LongPressStartDetails details) async {
          if (!editing && (EzConfig.get(authToEditKey) == true)) {
            // Check every time so no reset is required; O(1)
            bool authed = false;

            try {
              authed = await LocalAuthentication().authenticate(
                localizedReason: 'Authenticate to edit the launcher',
                persistAcrossBackgrounding: true,
                biometricOnly: false,
              );
            } catch (e) {
              ezLog(e.toString());
            }

            if (!authed) return;
          }

          if (context.mounted && animDuration > Duration.zero) {
            // Ripple transition to editing
            final AnimationController rippleController =
                AnimationController(vsync: overlay, duration: animDuration);
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
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              if (editing) {
                await navToHidden(context, textTheme, colorScheme);
              } else {
                context.goNamed(appListPath, extra: appListData);
              }
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! != 0) {
            AppInfo? toLaunch;

            if (details.primaryVelocity! < 0) {
              // Swiped left
              if (editing) {
                doNothing();
              } else {
                toLaunch = appProvider.appMap[EzConfig.get(leftSwipeIDKey)];
              }
            } else {
              // Swiped right (==0 already handled)
              if (editing) {
                editing = false;
                refresh();
              } else {
                toLaunch = appProvider.appMap[EzConfig.get(rightSwipeIDKey)];
              }
            }

            if (toLaunch != null) launchApp(toLaunch.package);
          }
        },
        child: Column(
          mainAxisAlignment: vAlign.mainAxis,
          crossAxisAlignment: hAlign.crossAxis,
          children: <Widget>[
            // Clock I
            if (vAlign == ListAlignment.start) clock(textTheme),

            // App list
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is OverscrollNotification &&
                      notification.overscroll > 0) {
                    // Navigate on bottom overscroll
                    if (atBottom) {
                      if (editing) {
                        navToHidden(context, textTheme, colorScheme);
                      } else {
                        context.goNamed(appListPath, extra: appListData);
                      }

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
                    setState(() => atBottom = (notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent));
                  }
                  return false; // Let other notifications propagate
                },
                child: editing
                    ? ReorderableListView(
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
                          await appProvider.reorderHomeItem(
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
                        !appProvider.hiddenSet.contains(id) &&
                        !appProvider.homeSet.contains(id),
                    onSelected: (String id) => appProvider.addHomeApp(id),
                    refresh: refresh,
                    autoRefresh: true,
                    icon: EzTextBackground(EzRow(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Home\t', style: textTheme.labelLarge),
                        EzIcon(
                          Icons.add,
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
                appProvider.addHomeFolder();
                refresh();
              }),
              ezSpacer,

              // Settings
              SettingsFAB(context, () => context.goNamed(settingsHomePath)),
            ]
          : null,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
