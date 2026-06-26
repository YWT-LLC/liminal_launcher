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
}) =>
    ezRootNav.currentState!.push(
      PageRouteBuilder<Widget>(
        opaque: false,
        transitionsBuilder: (_, __, ___, Widget child) => child,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) {
          final List<String> data = appInfo.homeList(config, lane)[index].split(spacerSplit);
          double height = double.tryParse(data[0]) ?? config.spacing;
          double width = double.tryParse(data[1]) ?? appIconSize(config);

          double opacity = 0.5;

          _EditType type = _EditType.height;

          return StatefulBuilder(
            builder: (_, StateSetter setOverlay) => EzScreen(
              config,
              safeArea: true,
              child: Stack(children: <Widget>[
                // Top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: EzRow(
                    config,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // Slider select
                      MenuAnchor(
                        builder: (_, MenuController c, __) => EzIconButton(
                          config,
                          icon: const Icon(Icons.done),
                          onPressed: () => toggleMenu(c),
                        ),
                        menuChildren: _EditType.values
                            .map((_EditType t) => EzMenuButton(
                                  config,
                                  label: t.name,
                                  icon: EzIcon(config, t.icon),
                                  onPressed: () => setOverlay(() => type = t),
                                ))
                            .toList(),
                      ),
                      config.rowSpacer,

                      // Done
                      EzIconButton(
                        config,
                        icon: const Icon(Icons.done),
                        onPressed: () => Navigator.of(ezRootNav.currentContext!).pop(),
                      )
                    ],
                  ),
                ),

                // Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Slider(
                    value: switch (type) {
                      _EditType.height => height,
                      _EditType.width => width,
                      _EditType.opacity => opacity,
                    },
                    max: switch (type) { _EditType.opacity => 1.0, _ => maxSpacing },
                    onChanged: (double value) {
                      setOverlay(() => switch (type) {
                            _EditType.height => height = value,
                            _EditType.width => width = value,
                            _EditType.opacity => opacity = value,
                          });
                      // TODO: passthrough
                    },
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );

enum _EditType { height, width, opacity }

extension _ETConfig on _EditType {
  IconData get icon => switch (this) {
        _EditType.height => Icons.height,
        _EditType.width => Icons.horizontal_rule,
        _EditType.opacity => Icons.opacity,
      };

  String get name => switch (this) {
        _EditType.height => 'Height',
        _EditType.width => 'Width',
        _EditType.opacity => 'Opacity',
      };
}

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
