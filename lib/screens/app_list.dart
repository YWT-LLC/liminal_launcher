/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  ListSort listSort = LSConfig.safeLookup(EzCM.get(listSortKey));
  bool ascList = EzCM.get(ascListKey);
  bool wrap = EzCM.get(wrapListKey);
  bool searching = EzCM.get(autoSearchKey);

  bool atTop = true;
  bool atBottom = false;
  Timer? overscrollPause;

  bool verbose = false;
  ValueNotifier<double> rippleProgress = ValueNotifier<double>(0.0);

  // Define custom functions //

  Future<void> ripple(EzCP config, LongPressStartDetails details) async {
    if (!context.mounted) return;

    final Duration animDur = listRipple ? ezDuration(config.animDur) : Duration.zero;
    if (wrap || (animDur <= oneMS)) {
      setState(() => verbose = !verbose);
      return;
    }

    // Ripple transition to verbose
    final AnimationController rippleController = AnimationController(
      vsync: Overlay.of(context),
      duration: animDur,
    );
    rippleController.addListener(() => rippleProgress.value = rippleController.value);

    final OverlayEntry ripple = ywt.ezRipple(
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
    if (!scrollControl.hasClients) atBottom = true;
    widget.listConfig.localContent?.addListener(_onLocalContentChanged);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return Consumer2<EzCP, AppInfoProvider>(
      builder: (_, EzCP config, AppInfoProvider appInfo, __) {
        final ListAlignment hAlign = horizontalAlign(config);
        final ListAlignment vAlign = verticalAlign(config);

        return LiminalScaffold(
          config,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (LongPressStartDetails details) => ripple(config, details),
            onVerticalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! > ezSwipeV) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: EzCol(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: vAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              children: <Widget>[
                EzHeader(config),

                // List controls
                EzScrollView(
                  config,
                  showScrollHint: true,
                  scrollDirection: Axis.horizontal,
                  mainAxisAlignment: hAlign.mainAxis,
                  children: <Widget>[
                    // Sort by...
                    MenuAnchor(
                      builder: (_, MenuController controller, __) => EzIconButton(
                        config,
                        icon: const Icon(Icons.sort),
                        tooltip: l10n(config).aplSort(listSort.name(config)),
                        onPressed: () => toggleMenu(controller),
                      ),
                      menuChildren: ListSort.values
                          .map((ListSort type) => EzMenuButton(
                                config,
                                label: type.name(config),
                                textAlign: hAlign.textAlign,
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
                      tooltip: ascList ? l10n(config).aplAsc : l10n(config).aplDsc,
                      onPressed: () async {
                        await EzCM.setBool(ascListKey, !ascList);

                        appInfo.sort(listSort, !ascList);
                        setState(() => ascList = !ascList);
                      },
                    ),
                    config.rowSpacer,

                    if (!wideTiles(config)) ...<Widget>[
                      // Wrap
                      verbose
                          ? EzIconButton(
                              config,
                              enabled: false,
                              icon: EzIcon(config, Icons.list_outlined),
                              tooltip: l10n(config).gList,
                              onPressed: doNothing,
                            )
                          : (wrap
                              ? EzIconButton(
                                  config,
                                  icon: EzIcon(config, Icons.grid_3x3),
                                  tooltip: l10n(config).gWrap,
                                  onPressed: () async {
                                    await EzCM.setBool(wrapListKey, false);
                                    setState(() => wrap = false);
                                  },
                                )
                              : EzIconButton(
                                  config,
                                  icon: EzIcon(config, Icons.list_outlined),
                                  tooltip: l10n(config).gList,
                                  onPressed: () async {
                                    await EzCM.setBool(wrapListKey, true);
                                    setState(() => wrap = true);
                                  },
                                )),
                      config.rowSpacer,
                    ],

                    // Search
                    EzIconButton(
                      config,
                      icon: const Icon(Icons.search),
                      tooltip: l10n(config).gSearch,
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
                  ],
                ),

                // Page title (conditional)
                if (widget.listConfig.title != null) ...<Widget>[
                  config.margin,
                  widget.listConfig.title!,
                ],

                // Search field (conditional)
                EzAnimVis(
                  config,
                  mod: 0.667,
                  reverse: true,
                  forceFade: true,
                  forceType: EzTransitionType.slideY,
                  visible: searching,
                  kid: Padding(
                    padding: EdgeInsets.only(top: config.spacing),
                    child: EzTextField(
                      constraints: ezTextFieldConstraints(context, prop: 0.5),
                      controller: searchControl,
                      hintText: l10n(config).gSearch,
                      onChanged: (_) => setState(() {}),
                      validator: (_) => null,
                      autofocus: searching,
                    ),
                  ),
                ),

                // App list
                config.spacer,
                NotificationListener<ScrollNotification>(
                  // Notifications
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
                          overscrollPause = Timer(scrollDelay, () => setState(() => atTop = true));
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
                          overscrollPause = Timer(scrollDelay, () => setState(() => atTop = true));
                        } else {
                          atTop = false;
                        }
                        setState(
                          () => atBottom =
                              (notification.metrics.pixels == notification.metrics.maxScrollExtent),
                        );
                        break;
                    }

                    return false;
                  },
                  // App list content
                  child: Expanded(
                    child: (wrap && !verbose)
                        ? EzScrollView(
                            config,
                            controller: scrollControl,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: vAlign.mainAxis,
                            crossAxisAlignment: hAlign.crossAxis,
                            physics: const ClampingScrollPhysics(),
                            child: EzWrap(
                              alignment: vAlign.wrapAxis,
                              runAlignment: hAlign.wrapAxis,
                              crossAxisAlignment: vAlign.wrapCrossAxis,
                              children: appInfo.apps
                                  .where((AppInfo app) =>
                                      (appInfo
                                              .hybridIDs(config, widget.listConfig)
                                              .contains(app.id) ==
                                          widget.listConfig.include) &&
                                      (searching
                                          ? app.label
                                              .toLowerCase()
                                              .contains(searchControl.text.toLowerCase())
                                          : true))
                                  .map((AppInfo app) => Container(
                                        key: ValueKey<String>(app.id),
                                        padding: EzInsets.wrap(config.spacing),
                                        child: AppTile(
                                          config,
                                          appInfo: appInfo,
                                          state: TileState.standard,
                                          rippleProgress: rippleProgress,
                                          app: app,
                                          location: AppLocation.list,
                                          onSelected: widget.listConfig.onSelected,
                                          hAlign: hAlign,
                                          vAlign: vAlign,
                                          verbStart: listSort,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        : EzScrollView(
                            config,
                            controller: scrollControl,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: vAlign.mainAxis,
                            crossAxisAlignment: hAlign.crossAxis,
                            physics: const ClampingScrollPhysics(),
                            children: appInfo.apps
                                .where((AppInfo app) =>
                                    (appInfo
                                            .hybridIDs(config, widget.listConfig)
                                            .contains(app.id) ==
                                        widget.listConfig.include) &&
                                    (searching
                                        ? app.label
                                            .toLowerCase()
                                            .contains(searchControl.text.toLowerCase())
                                        : true))
                                .map((AppInfo app) => Container(
                                      key: ValueKey<String>(app.id),
                                      padding: EdgeInsets.symmetric(vertical: config.spacing / 2),
                                      width: wideTiles(config) ? null : double.infinity,
                                      child: AppTile(
                                        config,
                                        appInfo: appInfo,
                                        state: verbose ? TileState.verbose : TileState.standard,
                                        rippleProgress: rippleProgress,
                                        app: app,
                                        location: AppLocation.list,
                                        onSelected: widget.listConfig.onSelected,
                                        hAlign: hAlign,
                                        vAlign: vAlign,
                                        verbStart: listSort,
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
                  duration: ezDuration(config.animDur, nonZero: true),
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
                  duration: ezDuration(config.animDur, nonZero: true),
                  curve: Curves.easeOut,
                ),
                child: EzIcon(config, Icons.arrow_downward),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    widget.listConfig.localContent?.removeListener(_onLocalContentChanged);
    scrollControl.dispose();
    searchControl.dispose();
    super.dispose();
  }
}
