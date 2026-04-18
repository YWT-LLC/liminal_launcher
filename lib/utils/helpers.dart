/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import './export.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> _externalAuth(String reason) async {
  final bool authed = await LocalAuthentication().authenticate(
    localizedReason: reason,
    persistAcrossBackgrounding: true,
    biometricOnly: false,
  );

  if (authed) await EzConfig.setString(lastAuthKey, DateTime.now().toString());
  return authed;
}

Future<bool> liminalAuth(String reason) {
  final int timeout = EzConfig.get(authTimeoutKey);
  final String lastAuthString = EzConfig.get(lastAuthKey);

  // Check quick exit(s)
  if (timeout <= 0 || lastAuthString.isEmpty) return _externalAuth(reason);

  // Do the math
  final DateTime? saved = DateTime.tryParse(lastAuthString);

  if (saved == null ||
      DateTime.now().difference(saved) < Duration(minutes: timeout)) {
    return _externalAuth(reason);
  } else {
    return Future<bool>.value(true);
  }
}
