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

  if (authed) await EzConfig.secSet(lastAuthKey, DateTime.now().toString());
  return authed;
}

Future<bool> liminalAuth(String reason) async {
  final int timeout =
      int.tryParse(await EzConfig.secGet(authTimeoutKey)) ?? (limSecDef[authTimeoutKey] as int);
  final String lastAuth = await EzConfig.secGet(lastAuthKey);

  // Check quick exit(s)
  if (timeout <= 0 || lastAuth.isEmpty) return _externalAuth(reason);

  // Do the math
  final DateTime? saved = DateTime.tryParse(lastAuth);

  return (saved == null || DateTime.now().difference(saved) > Duration(minutes: timeout))
      ? _externalAuth(reason)
      : Future<bool>.value(true);
}
