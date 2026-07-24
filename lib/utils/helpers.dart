/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_ui/open_ui.dart';

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

// TODO: make solid/outlined a switch, add names, make it search-able
// also maybe update the list
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
                      .map(
                        (IconData icon) => Padding(
                          padding: EzInsets.wrap(config.spacing),
                          child: EzIconButton(
                            config,
                            icon: Icon(icon),
                            onPressed: () => Navigator.of(mCon).pop(icon),
                          ),
                        ),
                      )
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
  if (lastAuth.isEmpty || authTimeout(config) <= oneMS) return _externalAuth(reason);

  // Do the math
  final DateTime? saved = DateTime.tryParse(lastAuth);

  return (saved == null || DateTime.now().difference(saved) > authTimeout(config))
      ? _externalAuth(reason)
      : Future<bool>.value(true);
}

Widget renderWidget(
  EzCP config, {
  required AppInfoProvider appInfo,
  required LimPos pos,
  required AppState state,
  ValueNotifier<double>? rippleProgress,
}) =>
    wideTiles(config)
        ? Container(
            width: double.infinity,
            alignment: pos.subAlign,
            child: switch (
                appInfo.homeItem(config, lane: pos.lane, index: pos.index).split(widgetSplit)[0]) {
              esClock => ClockWidget(config, appInfo, pos, state, rippleProgress),
              esEvent => EventWidget(config, appInfo, pos, state, rippleProgress),
              esSearch => SearchWidget(config, appInfo, pos, state, rippleProgress),
              esTimer => TimerWidget(config, appInfo, pos, state, rippleProgress),
              esToggleMedia => ToggleMediaWidget(config, appInfo, pos, state, rippleProgress),
              esThemeMode => ThemeModeWidget(config, appInfo, pos, state, rippleProgress),
              _ => const SizedBox.shrink(),
            },
          )
        : switch (
            appInfo.homeItem(config, lane: pos.lane, index: pos.index).split(widgetSplit)[0]) {
            esClock => ClockWidget(config, appInfo, pos, state, rippleProgress),
            esEvent => EventWidget(config, appInfo, pos, state, rippleProgress),
            esSearch => SearchWidget(config, appInfo, pos, state, rippleProgress),
            esTimer => TimerWidget(config, appInfo, pos, state, rippleProgress),
            esToggleMedia => ToggleMediaWidget(config, appInfo, pos, state, rippleProgress),
            esThemeMode => ThemeModeWidget(config, appInfo, pos, state, rippleProgress),
            _ => const SizedBox.shrink(),
          };

/// [EzCP.isLTR] && [horizontalAlign] != [ListAlignment.end]
bool standardFlow(EzCP config) => config.isLTR && horizontalAlign(config) != ListAlignment.end;

const String _pattern = r'^(?!.*:[01]{8}:)[^/\\\x00]{1,50}$';
String? validateName(String? name) {
  if (name == null || name.trim().isEmpty) return 'Cannot be empty';

  final RegExp regex = RegExp(_pattern);
  if (!regex.hasMatch(name)) return 'Invalid; $_pattern';

  return null;
}
