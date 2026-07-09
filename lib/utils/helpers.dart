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
            physics: const ClampingScrollPhysics(),
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

                  if (details.primaryVelocity! < -ezSwipeV) {
                    // RTL -> nav right
                    if (outlined) return;
                    setModal(() => outlined = true);
                  }

                  if (details.primaryVelocity! > ezSwipeV) {
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
  required ListAlignment hAlign,
  required ListAlignment vAlign,
  required AppState state,
  ValueNotifier<double>? rippleProgress,
}) =>
    wideTiles(config)
        ? Container(
            width: double.infinity,
            alignment: LAConfig.merge(h: hAlign, v: ListAlignment.center),
            child: switch (
                appInfo.homeItem(config, lane: lane, index: index).split(widgetSplit)[0]) {
              esCalendar => CalendarWidget(config, appInfo, lane, index, state, rippleProgress),
              esClock =>
                ClockWidget(config, appInfo, lane, index, hAlign, vAlign, state, rippleProgress),
              esSearch => SearchWidget(config, appInfo, lane, index, state, rippleProgress),
              esTimer => TimerWidget(config, appInfo, lane, index, state, rippleProgress),
              esToggleMedia =>
                ToggleMediaWidget(config, appInfo, lane, index, state, rippleProgress),
              esThemeMode => ThemeModeWidget(config, appInfo, lane, index, state, rippleProgress),
              _ => const SizedBox.shrink(),
            },
          )
        : switch (appInfo.homeItem(config, lane: lane, index: index).split(widgetSplit)[0]) {
            esCalendar => CalendarWidget(config, appInfo, lane, index, state, rippleProgress),
            esClock =>
              ClockWidget(config, appInfo, lane, index, hAlign, vAlign, state, rippleProgress),
            esSearch => SearchWidget(config, appInfo, lane, index, state, rippleProgress),
            esTimer => TimerWidget(config, appInfo, lane, index, state, rippleProgress),
            esToggleMedia => ToggleMediaWidget(config, appInfo, lane, index, state, rippleProgress),
            esThemeMode => ThemeModeWidget(config, appInfo, lane, index, state, rippleProgress),
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
