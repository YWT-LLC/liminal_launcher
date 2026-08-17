/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

Future<void> canEdit(EzCP config, Future<void> Function() onSuccess) async {
  if (!authToEdit(config)) {
    await onSuccess.call();
    return;
  }

  bool authed = false;
  try {
    authed = await liminalAuth(config, l10n(config).hsEditAuth);
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
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(l10n(config).gSolid, textAlign: TextAlign.center),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(l10n(config).gOutlined, textAlign: TextAlign.center),
                  ),
                ],
                selected: <bool>{outlined},
                showSelectedIcon: false,
                onSelectionChanged: (Set<bool> selected) =>
                    setModal(() => outlined = selected.first),
              ),
              config.spacer,

              // Icons
              EzSwipeDetector(
                rtl: () => setModal(() => outlined = true),
                ltr: () => setModal(() => outlined = false),
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
  if (lastAuth.isEmpty || authTimeout(config) <= oneMS) return _externalAuth(reason);

  // Do the math
  final DateTime? saved = DateTime.tryParse(lastAuth);

  return (saved == null || DateTime.now().difference(saved) > authTimeout(config))
      ? _externalAuth(reason)
      : Future<bool>.value(true);
}

/// [EzCP.isLTR] && [horizontalAlign] != [ListAlignment.end]
bool standardFlow(EzCP config) => config.isLTR && horizontalAlign(config) != ListAlignment.end;

EdgeInsets tilePadding(EzCP config, String datum, bool editing) {
  // Check for quick values
  if (editing || datum == nullTPS) return EzInsets.wrap(config.spacing);
  if (datum == zeroTPS) return EdgeInsets.zero;

  // Build custom
  final List<String> data = datum.split(colon);
  final double halfSpace = config.spacing / 2;

  return EdgeInsets.only(
    top: data[0] == esSystem ? halfSpace : (double.tryParse(data[0]) ?? halfSpace),
    bottom: data[1] == esSystem ? halfSpace : (double.tryParse(data[1]) ?? halfSpace),
    left: data[2] == esSystem ? halfSpace : (double.tryParse(data[2]) ?? halfSpace),
    right: data[3] == esSystem ? halfSpace : (double.tryParse(data[3]) ?? halfSpace),
  );
}

String tpMap(List<double?> tp) =>
    tp.map((double? entry) => entry == null ? esSystem : entry.toString()).join(colon);

const String _pattern = r'^(?!.*:[01]{8}:)[^/\\\x00]{1,50}$';
String? validateName(EzCP config, String? name) {
  if (name == null || name.trim().isEmpty) return l10n(config).gNoEmpty;

  final RegExp regex = RegExp(_pattern);
  if (!regex.hasMatch(name)) return '${l10n(config).gInvalid}; $_pattern';

  return null;
}
