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
      ButtonType.text || ButtonType.eText => WidgetSize.tile,
      ButtonType.textIcon || ButtonType.eTextIcon => WidgetSize.unbound,
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

Widget renderWidget(EzCP config, String entry, AppState state) {
  final List<String> data = entry.split(widgetSplit);
  final String type = data[0];
  final String size = data[1];

  return switch (type) {
    esCalendar => CalendarWidget(config, WSConfig.lookup(size), state),
    esClock => ClockWidget(config, WSConfig.lookup(size), state),
    esSearch => SearchWidget(config, WSConfig.lookup(size), state),
    esStopwatch => StopwatchWidget(config, WSConfig.lookup(size), state),
    esTimer => TimerWidget(config, WSConfig.lookup(size), state),
    esToggleMedia => ToggleMediaWidget(config, WSConfig.lookup(size), state),
    _ => const SizedBox.shrink(),
  };
}
