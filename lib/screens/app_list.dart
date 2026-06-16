/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppListScreen extends StatefulWidget {
  final ListConfig listConfig;

  const AppListScreen(this.listConfig, {super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Define the build data //

  final ScrollController scrollControl = ScrollController();
  final TextEditingController searchControl = TextEditingController();

  bool searching = autoSearch;
  AppSort listSort = ASConfig.lookup(EzCM.get(listSortKey));
  bool ascList = EzCM.get(ascListKey);

  bool atTop = true;
  bool atBottom = false;
  Timer? overscrollPause;

  bool verbose = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define custom functions //

  Future<void> ripple(EzCP config, LongPressStartDetails details) async {
    if (!context.mounted) return;

    final Duration animDur = ezDuration(config.animDur, mod: rippleMod);
    if (animDur <= Duration.zero) {
      setState(() => verbose = !verbose);
      return;
    }

    // Ripple transition to verbose
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
      setState(() => verbose = !verbose);
      ripple.remove();
      rippleController.dispose();
    });
    return;
  }

  // Init //

  void _onLocalContentChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.listConfig.localContent?.addListener(_onLocalContentChanged);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppInfoProvider, EzCP>(builder: (_, AppInfoProvider appInfo, EzCP config, __) {
      final ListAlignment hA = hAlign(config);
      final ListAlignment vA = vAlign(config);

      return LiminalScaffold(
        config,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (LongPressStartDetails details) => ripple(config, details),
          onVerticalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                Navigator.of(context).pop();
              }
            }
          },
          child: EzCol(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: vA.mainAxis,
            crossAxisAlignment: hA.crossAxis,
            children: <Widget>[
              EzHeader(config),

              // List controls
              EzScrollView(
                config,
                showScrollHint: true,
                scrollDirection: Axis.horizontal,
                mainAxisAlignment: hA.mainAxis,
                children: <Widget>[
                  // Sort by...
                  MenuAnchor(
                    builder: (_, MenuController controller, __) => EzIconButton(
                      config,
                      onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                      icon: EzIcon(config, Icons.sort),
                    ),
                    menuChildren: AppSort.values
                        .map((AppSort type) => EzMenuButton(
                              config,
                              label: type.name.replaceRange(0, 1, type.name[0].toUpperCase()),
                              textAlign: hA.textAlign,
                              onPressed: () async {
                                await EzCM.setString(listSortKey, type.value);

                                appInfo.sort(type, ascList);
                                setState(() => listSort = type);
                              },
                            ))
                        .toList(),
                  ),
                  config.rowSpacer,

                  // Order
                  EzIconButton(
                    config,
                    icon: Icon(ascList ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () async {
                      await EzCM.setBool(ascListKey, ascList);

                      appInfo.sort(listSort, ascList);
                      setState(() => ascList = !ascList);
                    },
                  ),
                  config.rowSpacer,

                  // Search
                  AnimatedContainer(
                    duration: ezDuration(config.animDur),
                    width: searching ? 200 : null,
                    curve: Curves.easeInOut,
                    child: EzRow(
                      config,
                      children: <Widget>[
                        EzIconButton(
                          config,
                          icon: EzIcon(config, Icons.search),
                          onPressed: () {
                            if (searching) {
                              closeKeyboard(context);
                              searchControl.clear();
                              setState(() => searching = false);
                            } else {
                              setState(() => searching = true);
                            }
                          },
                        ),
                        if (searching) ...<Widget>[
                          config.rowMargin,
                          Expanded(
                            child: TextField(
                              controller: searchControl,
                              autofocus: searching,
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.listConfig.title != null) widget.listConfig.title!,
              EzSpacer((config.spacing * 2) - ((config.spacing * 0.5) + config.marginVal)),

              // App list
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  switch (notification.runtimeType) {
                    case const (OverscrollNotification):
                      if (notification.metrics.axis == Axis.horizontal ||
                          (notification as OverscrollNotification).overscroll >= 0) {
                        return false;
                      }

                      if (atTop) {
                        Navigator.of(context).pop();
                        return true;
                      } else {
                        overscrollPause = Timer(
                          scrollDelay,
                          () => setState(() => atTop = true),
                        );
                        return true;
                      }

                    case const (ScrollUpdateNotification):
                      if (notification.metrics.axis == Axis.horizontal) return false;

                      if (atTop && notification.metrics.pixels > 0) {
                        setState(() => atTop = false);
                      }
                      if (atBottom &&
                          notification.metrics.pixels < notification.metrics.maxScrollExtent) {
                        setState(() => atBottom = false);
                      }
                      break;

                    case const (ScrollEndNotification):
                      if (notification.metrics.axis == Axis.horizontal) return false;

                      if (notification.metrics.pixels == 0) {
                        overscrollPause = Timer(
                          scrollDelay,
                          () => setState(() => atTop = true),
                        );
                      } else {
                        atTop = false;
                      }
                      setState(() => atBottom =
                          (notification.metrics.pixels == notification.metrics.maxScrollExtent));
                      break;
                  }

                  return false;
                },
                child: Expanded(
                  child: EzScrollView(
                    config,
                    controller: scrollControl,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: vA.mainAxis,
                    crossAxisAlignment: hA.crossAxis,
                    physics: const ClampingScrollPhysics(),
                    children: appInfo.apps
                        .where((AppInfo app) =>
                            (appInfo.hybridIDs(config, widget.listConfig).contains(app.id) ==
                                widget.listConfig.include) &&
                            (searching
                                ? app.name.toLowerCase().contains(searchControl.text.toLowerCase())
                                : true))
                        .map((AppInfo app) => Padding(
                              key: ValueKey<String>(app.id),
                              padding: EdgeInsets.symmetric(vertical: config.spacing / 2),
                              child: AppTile(
                                config,
                                appInfo: appInfo,
                                app: app,
                                location: AppLocation.list,
                                state: verbose ? AppState.verbose : AppState.standard,
                                onSelected: widget.listConfig.onSelected,
                                rippleProgress: rippleProgress,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        fabs: <Widget>[
          config.spacer,

          // Scroll to top
          EzAnimHide(
            config,
            mod: 0.5,
            visible: !atTop,
            size: config.theme.floatingActionButtonTheme.sizeConstraints!.biggest,
            kid: FloatingActionButton(
              heroTag: 'scroll_up_FAB',
              onPressed: () => scrollControl.animateTo(
                0,
                duration: ezDuration(config.animDur),
                curve: Curves.easeOut,
              ),
              child: EzIcon(config, Icons.arrow_upward),
            ),
          ),
          config.spacer,

          // Scroll to bottom
          EzAnimHide(
            config,
            mod: 0.5,
            visible: !atBottom,
            size: config.theme.floatingActionButtonTheme.sizeConstraints!.biggest,
            kid: FloatingActionButton(
              heroTag: 'scroll_down_FAB',
              onPressed: () => scrollControl.animateTo(
                scrollControl.position.maxScrollExtent,
                duration: ezDuration(config.animDur),
                curve: Curves.easeOut,
              ),
              child: EzIcon(config, Icons.arrow_downward),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    widget.listConfig.localContent?.removeListener(_onLocalContentChanged);
    scrollControl.dispose();
    searchControl.dispose();
    super.dispose();
  }
}
