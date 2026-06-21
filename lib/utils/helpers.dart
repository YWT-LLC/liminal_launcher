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
  required int lane, // TODO: -1 for top, -2 for bottom
  required int index,
  required AppState state,
  ValueNotifier<double>? rippleProgress, // TODO: something
}) =>
    switch (appInfo.homeList(config, lane)[index].split(widgetSplit)[0]) {
      esCalendar => CalendarWidget(config, appInfo, lane, index, state),
      esClock => ClockWidget(config, appInfo, lane, index, state),
      esSearch => SearchWidget(config, appInfo, lane, index, state),
      esStopwatch => StopwatchWidget(config, appInfo, lane, index, state),
      esTimer => TimerWidget(config, appInfo, lane, index, state),
      esToggleMedia => ToggleMediaWidget(config, appInfo, lane, index, state),
      _ => const SizedBox.shrink(),
    };

OverlayEntry textFormOverlay(EzCP config, String text) => OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: config.marginVal,
        right: config.marginVal,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.all(config.marginVal),
              decoration: BoxDecoration(
                color: config.colors.surfaceContainer,
                border: Border.all(
                  color: config.colors.secondaryContainer,
                  width: config.borderWidth,
                ),
                borderRadius: config.textRadius,
              ),
              child: Text(
                text,
                style: config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
