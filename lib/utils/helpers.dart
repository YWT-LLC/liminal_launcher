/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

WidgetSize bt2WS(EzCP config) => switch (listBT(config)) {
      ButtonType.icon || ButtonType.eIcon => WidgetSize.button,
      _ => WidgetSize.tile,
    };

Future<void> canEdit(EzCP config, Future<void> Function() onSuccess) async {
  if (!authToEdit(config)) {
    await onSuccess.call();
    return;
  }

  bool authed = false;
  try {
    authed = await liminalAuth(config, 'Authenticate to edit the launcher');
  } catch (e) {
    ezLog(e.toString());
  }

  if (authed) await onSuccess.call();
}

Future<void> canToggleMenu(EzCP config, MenuController c) =>
    canEdit(config, () async => toggleMenu(c));

Future<IconData?> chooseIcon(EzCP config, BuildContext context) => ezModal(
      config,
      context: context,
      builder: (_) {
        bool outlined = false;

        return StatefulBuilder(
          builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
            config,
            children: <Widget>[
              // Switcher
              SegmentedButton<bool>(
                segments: <ButtonSegment<bool>>[
                  const ButtonSegment<bool>(
                    value: false,
                    label: Text('Solid', textAlign: TextAlign.center),
                  ),
                  const ButtonSegment<bool>(
                    value: true,
                    label: Text('Outlined', textAlign: TextAlign.center),
                  ),
                ],
                selected: <bool>{outlined},
                showSelectedIcon: false,
                onSelectionChanged: (Set<bool> selected) =>
                    setModal(() => outlined = selected.first),
              ),
              config.spacer,

              // Icons
              GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity == null) return;

                  if (details.primaryVelocity! < -100) {
                    // RTL -> nav right
                    if (outlined) return;
                    setModal(() => outlined = true);
                  }

                  if (details.primaryVelocity! > 100) {
                    // LTR -> nav left
                    if (!outlined) return;
                    setModal(() => outlined = false);
                  }
                },
                child: EzWrap(
                  children: (outlined ? outlinedIconChoices : solidIconChoices)
                      .map((IconData icon) => Padding(
                            padding: EzInsets.wrap(config.spacing),
                            child: EzIconButton(
                              config,
                              icon: Icon(icon),
                              onPressed: () => Navigator.of(mCon).pop(icon),
                            ),
                          ))
                      .toList(),
                ),
              ),
              config.spacer,
            ],
          ),
        );
      },
    );

Future<void> editSpacer(
  EzCP config, {
  required AppInfoProvider appInfo,
  required int lane,
  required int index,
}) async {
  // Define build data //

  final int numLanes = appInfo.numLanes(config);
  int currLane = lane;
  int currIndex = index;

  final List<String> data = appInfo.homeList(config, lane)[index].split(spacerSplit);
  final double hBack = double.tryParse(data[0]) ?? config.spacing;
  final double wBack = double.tryParse(data[1]) ?? appIconSize(config);
  double height = hBack;
  double width = wBack;

  editSpacerHeight.value = height;
  editSpacerWidth.value = width;
  marked.value = (lane, index);

  Axis axis = Axis.vertical;

  final bool? keep = await ezRootNav.currentState!.push(
    PageRouteBuilder<bool>(
      opaque: false,
      transitionsBuilder: (_, __, ___, Widget child) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => StatefulBuilder(builder: (_, StateSetter setOverlay) {
        final double maxHeight = heightOf(ezRootNav.currentContext!) / 2;
        final double maxWidth = widthOf(ezRootNav.currentContext!) / 2;

        // Define custom functions //

        void quickValue(double value) {
          if (axis == Axis.vertical) {
            height = value;
            editSpacerHeight.value = value;
          } else {
            width = value;
            editSpacerWidth.value = value;
          }
          setOverlay(() {});
        }

        // Return the build //

        return Material(
          type: MaterialType.transparency,
          child: Stack(children: <Widget>[
            // Top
            Positioned(
              top: safeTop(ezRootNav.currentContext!),
              left: 0,
              right: 0,
              child: Center(
                child: EzScrollView(
                  config,
                  startCentered: true,
                  showScrollHint: true,
                  mainAxisSize: MainAxisSize.max,
                  scrollDirection: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Slider select
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        config,
                        icon: Icon((axis == Axis.vertical) ? Icons.height : Icons.horizontal_rule),
                        onPressed: () => toggleMenu(c),
                      ),
                      menuChildren: Axis.values
                          .map((Axis a) => EzMenuButton(
                                config,
                                label: a.name,
                                icon: EzIcon(
                                  config,
                                  (a == Axis.vertical) ? Icons.height : Icons.horizontal_rule,
                                ),
                                onPressed: () => setOverlay(() => axis = a),
                              ))
                          .toList(),
                    ),
                    config.rowSpacer,

                    // Move (lane) up
                    if (numLanes > 1) ...<Widget>[
                      EzIconButton(
                        config,
                        icon: const Icon(Icons.add),
                        enabled: currLane < (numLanes - 1),
                        onPressed: () async {
                          final int nextLane = currLane + 1;
                          final int nextIndex = appInfo.homeList(config, nextLane).length;

                          marked.value = (nextLane, nextIndex);
                          await appInfo.moveUpLane(config, lane: currLane, index: currIndex);

                          currLane = nextLane;
                          currIndex = nextIndex;
                          setOverlay(() {});
                        },
                      ),
                      config.rowSpacer,
                    ],

                    // Move (item) up
                    EzIconButton(
                      config,
                      icon: Icon((vAlign(config) == ListAlignment.end)
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                      enabled: currIndex < (appInfo.homeList(config, currLane).length - 1),
                      onPressed: () async {
                        final int nextIndex = currIndex + 1;

                        marked.value = (currLane, nextIndex);
                        await appInfo.moveItemUp(config, lane: currLane, index: currIndex);

                        setOverlay(() => currIndex = nextIndex);
                      },
                    ),
                    config.rowSpacer,

                    // Key/quick values
                    MenuAnchor(
                      builder: (_, MenuController c, __) => EzIconButton(
                        config,
                        icon: const Icon(Icons.key),
                        onPressed: () => toggleMenu(c),
                      ),
                      menuChildren: <Widget>[
                        MenuItemButton(
                          onPressed: () => quickValue(config.marginVal),
                          child: Text('Margin: ${config.marginVal}'),
                        ),
                        MenuItemButton(
                          onPressed: () => quickValue(config.padding),
                          child: Text('Padding: ${config.padding}'),
                        ),
                        MenuItemButton(
                          onPressed: () => quickValue(config.spacing),
                          child: Text('Spacing: ${config.spacing}'),
                        ),
                        MenuItemButton(
                          onPressed: () => quickValue(config.iconSize),
                          child: Text('Icon size: ${config.iconSize}'),
                        ),
                        MenuItemButton(
                          onPressed: () => quickValue(appIconSize(config)),
                          child: Text('App icon size: ${appIconSize(config)}'),
                        ),
                      ],
                    ),
                    config.rowSpacer,

                    // Moved (item) down
                    EzIconButton(
                      config,
                      icon: Icon((vAlign(config) == ListAlignment.end)
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up),
                      enabled: currIndex > 0,
                      onPressed: () async {
                        final int nextIndex = currIndex - 1;

                        marked.value = (currLane, nextIndex);
                        await appInfo.moveItemDown(config, lane: currLane, index: currIndex);

                        setOverlay(() => currIndex = nextIndex);
                      },
                    ),
                    config.rowSpacer,

                    // Move (lane) down
                    if (numLanes > 1) ...<Widget>[
                      EzIconButton(
                        config,
                        icon: const Icon(Icons.remove),
                        enabled: currLane > 0,
                        onPressed: () async {
                          final int nextLane = currLane - 1;
                          final int nextIndex = appInfo.homeList(config, nextLane).length;

                          marked.value = (nextLane, nextIndex);
                          await appInfo.moveDownLane(config, lane: currLane, index: currIndex);

                          currLane = nextLane;
                          currIndex = nextIndex;
                          setOverlay(() {});
                        },
                      ),
                      config.rowSpacer,
                    ],

                    // Edits
                    MenuAnchor(
                      builder: (_, MenuController controller, __) => EzIconButton(
                        config,
                        icon: const Icon(Icons.build),
                        onPressed: () => toggleMenu(controller),
                      ),
                      menuChildren: <Widget>[
                        EzMenuButton(
                          config,
                          label: 'Delete',
                          icon: EzIcon(config, Icons.delete),
                          onPressed: () => Navigator.of(ezRootNav.currentContext!).pop(false),
                        ),
                        EzMenuButton(
                          config,
                          label: 'Reset',
                          icon: EzIcon(config, Icons.refresh),
                          onPressed: () {
                            height = hBack;
                            editSpacerHeight.value = hBack;

                            width = wBack;
                            editSpacerWidth.value = wBack;

                            setOverlay(() {});
                          },
                        ),
                        EzMenuButton(
                          config,
                          label: 'Duplicate',
                          icon: EzIcon(config, Icons.copy),
                          onPressed: () async {
                            await appInfo.updateSpacer(
                              config,
                              height: height,
                              width: width,
                              lane: currLane,
                              index: currIndex,
                            );
                            await appInfo.addSpacer(
                              config,
                              height: height,
                              width: width,
                              lane: currLane,
                              index: currIndex,
                            );

                            marked.value = (currLane, currIndex + 1);
                            setOverlay(() => currIndex += 1);
                          },
                        ),
                        EzMenuButton(
                          config,
                          label: 'Done',
                          icon: EzIcon(config, Icons.done),
                          onPressed: () => Navigator.of(ezRootNav.currentContext!).pop(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom
            Positioned(
              bottom: safeBottom(ezRootNav.currentContext!),
              left: 0,
              right: 0,
              child: EzTextBackground(
                config,
                text: (axis == Axis.vertical)
                    ? Slider(
                        value: height,
                        max: maxHeight,
                        onChanged: (double value) {
                          editSpacerHeight.value = value;
                          setOverlay(() => height = value);
                        },
                      )
                    : Slider(
                        value: width,
                        max: maxWidth,
                        onChanged: (double value) {
                          editSpacerWidth.value = value;
                          setOverlay(() => width = value);
                        },
                      ),
                backgroundColor: config.colors.surface,
              ),
            ),
          ]),
        );
      }),
    ),
  );

  await ezNoTouch(() async {
    marked.value = (null, null);

    (keep == false)
        ? await appInfo.deleteWS(config, lane: currLane, index: currIndex)
        : await appInfo.updateSpacer(
            config,
            height: height,
            width: width,
            lane: currLane,
            index: currIndex,
          );
  });
}

// TODO: stress test TF out of spacers

Future<bool> _externalAuth(String reason) async {
  final bool authed = await LocalAuthentication().authenticate(
    localizedReason: reason,
    persistAcrossBackgrounding: true,
  );

  if (authed) await EzCM.secSet(lastAuthKey, DateTime.now().toString());
  return authed;
}

Future<bool> liminalAuth(EzCP config, String reason) async {
  final String lastAuth = await EzCM.secGet(lastAuthKey);

  // Check quick exit(s)
  if (lastAuth.isEmpty || authTimeout(config) <= Duration.zero) return _externalAuth(reason);

  // Do the math
  final DateTime? saved = DateTime.tryParse(lastAuth);

  return (saved == null || DateTime.now().difference(saved) > authTimeout(config))
      ? _externalAuth(reason)
      : Future<bool>.value(true);
}

Widget renderWidget(
  EzCP config, {
  required AppInfoProvider appInfo,
  required int lane,
  required int index,
  required AppState state,
  ValueNotifier<double>? rippleProgress,
}) =>
    switch (appInfo.homeList(config, lane)[index].split(widgetSplit)[0]) {
      esCalendar => CalendarWidget(config, appInfo, lane, index, state, rippleProgress),
      esClock => ClockWidget(config, appInfo, lane, index, state, rippleProgress),
      esSearch => SearchWidget(config, appInfo, lane, index, state, rippleProgress),
      esTimer => TimerWidget(config, appInfo, lane, index, state, rippleProgress),
      esToggleMedia => ToggleMediaWidget(config, appInfo, lane, index, state, rippleProgress),
      _ => const SizedBox.shrink(),
    };

Future<String?> resizeWidgetDialog(EzCP config, BuildContext context, WidgetSize curr) =>
    showDialog(
      context: context,
      builder: (BuildContext dCon) => EzAlertDialog(
        config,
        title: Text('Currently: ${curr.value}', textAlign: TextAlign.center),
        contents: <Widget>[
          EzTextButton(
            config,
            text: 'System (${bt2WS(config).value})',
            onPressed: () => Navigator.of(context).pop(WidgetSize.system.value),
          ),
          config.spacer,
          EzTextButton(
            config,
            text: 'Button',
            onPressed: () => Navigator.of(context).pop(WidgetSize.button.value),
          ),
          config.spacer,
          EzTextButton(
            config,
            text: 'Tile',
            onPressed: () => Navigator.of(context).pop(WidgetSize.tile.value),
          ),
        ],
      ),
    );
