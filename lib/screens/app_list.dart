/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:efui_bios/efui_bios.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ListConfig {
  final Widget? title;
  final Set<String> ids;
  final bool include;
  final Future<void> Function(String id) onSelected;

  /// How the [AppListScreen] should behave
  const ListConfig({
    required this.title,
    required this.ids,
    required this.include,
    required this.onSelected,
  });
}

class AppListScreen extends StatefulWidget {
  final ListConfig config;

  AppListScreen(this.config) : super(key: ValueKey<int>(EzConfig.seed));

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Define the build data //

  late Set<String> ids = widget.config.ids;

  final ScrollController scrollControl = ScrollController();
  final TextEditingController searchControl = TextEditingController();

  AppSort listSort = ASConfig.lookup(EzConfig.get(listSortKey));
  bool ascList = EzConfig.get(ascListKey);
  bool searching = EzConfig.get(autoSearchKey);

  bool atTop = true;
  bool atBottom = false;
  Timer? closePause;

  bool verbose = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define custom functions //

  void onRemove(String id) => setState(() => ids.remove(id));

  // Return the build //

  @override
  Widget build(BuildContext context) => LiminalScaffold(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (LongPressStartDetails details) async {
            final Duration animDur = ezAnimDuration(mod: rippleMod);

            if (context.mounted) {
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
                color: EzConfig.colors.primary,
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
          },
          onVerticalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                Navigator.of(context).pop();
              }
            }
          },
          child: EzCol(
            mainAxisAlignment: vAlign.mainAxis,
            crossAxisAlignment: hAlign.crossAxis,
            children: <Widget>[
              EzHeader(),

              // List controls
              EzScrollView(
                scrollDirection: Axis.horizontal,
                mainAxisAlignment: hAlign.mainAxis,
                crossAxisAlignment: vAlign.crossAxis,
                children: <Widget>[
                  // Sort by...
                  MenuAnchor(
                    builder: (_, MenuController controller, __) => EzIconButton(
                      onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                      icon: const Icon(Icons.sort),
                    ),
                    menuChildren: AppSort.values
                        .map((AppSort type) => EzMenuButton(
                              label: type.name.replaceRange(0, 1, type.name[0].toUpperCase()),
                              textAlign: hAlign.textAlign,
                              onPressed: () async {
                                await EzConfig.setString(listSortKey, type.value);

                                appInfo.sort(type, ascList);
                                setState(() => listSort = type);
                              },
                            ))
                        .toList(),
                  ),
                  EzConfig.rowSpacer,

                  // Order
                  EzIconButton(
                    icon: Icon(
                      ascList ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () async {
                      ascList = !ascList;
                      await EzConfig.setBool(ascListKey, ascList);

                      appInfo.sort(listSort, ascList);
                      setState(() {});
                    },
                  ),
                  EzConfig.rowSpacer,

                  // Search
                  AnimatedContainer(
                    duration: ezAnimDuration(),
                    width: searching ? 200 : null,
                    curve: Curves.easeInOut,
                    child: EzRow(
                      children: <Widget>[
                        EzIconButton(
                          icon: const Icon(Icons.search),
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
                          EzMargin(vertical: false),
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
              if (widget.config.title != null) ...<Widget>[
                EzConfig.margin,
                widget.config.title!,
              ],
              EzConfig.spacer,

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
                        closePause = Timer(
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
                        closePause = Timer(
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
                    mainAxisSize: MainAxisSize.max,
                    controller: scrollControl,
                    physics: const ClampingScrollPhysics(),
                    children: appInfo.apps
                        .where((AppInfo app) =>
                            (ids.contains(app.id) == widget.config.include) &&
                            (searching
                                ? app.name.toLowerCase().contains(searchControl.text.toLowerCase())
                                : true))
                        .map((AppInfo app) => Padding(
                              key: ValueKey<String>(app.id),
                              padding: EdgeInsets.symmetric(vertical: EzConfig.spacing / 2),
                              child: AppTile(
                                app: app,
                                location: AppLocation.list,
                                state: verbose ? AppState.verbose : AppState.standard,
                                onSelected: widget.config.onSelected,
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
          EzConfig.spacer,

          // Scroll to top
          EzAnimHide(
            mod: 0.5,
            visible: !atTop,
            size: EzConfig.theme.floatingActionButtonTheme.sizeConstraints!.biggest,
            kid: FloatingActionButton(
              heroTag: 'scroll_up_FAB',
              onPressed: () => scrollControl.animateTo(
                0,
                duration: ezAnimDuration(),
                curve: Curves.easeOut,
              ),
              child: EzIcon(Icons.arrow_upward),
            ),
          ),
          EzConfig.spacer,

          // Scroll to bottom
          EzAnimHide(
            mod: 0.5,
            visible: !atBottom,
            size: EzConfig.theme.floatingActionButtonTheme.sizeConstraints!.biggest,
            kid: FloatingActionButton(
              heroTag: 'scroll_down_FAB',
              onPressed: () => scrollControl.animateTo(
                scrollControl.position.maxScrollExtent,
                duration: ezAnimDuration(),
                curve: Curves.easeOut,
              ),
              child: EzIcon(Icons.arrow_downward),
            ),
          ),
        ],
      );

  @override
  void dispose() {
    scrollControl.dispose();
    searchControl.dispose();
    super.dispose();
  }
}
