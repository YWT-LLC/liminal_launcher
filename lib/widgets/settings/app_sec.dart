/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:math';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

class AppSecSettings extends StatelessWidget {
  final EzCP config;
  final TextEditingController _timeoutText;

  AppSecSettings(this.config, {super.key}) : _timeoutText = TextEditingController();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: l10n(config).gsSecurity,
        icon: EzIcon(config, Icons.security),
        onPressed: () async {
          bool editAuth = authToEdit(config);
          bool editReset = resetAfterEdit(config);

          bool hideAuth = authForHidden(config);
          bool openReset = resetAfterOpened(config);

          _timeoutText.text = authTimeout(config).inMinutes.toString();
          final Size ttSize = ezTextSize(
            config,
            text: '55',
            style: config.bodyStyle,
            textScaler: MediaQuery.textScalerOf(context),
          );
          final double fieldWidth = max(ttSize.width + config.padding, kMinInteractiveDimension);

          if (context.mounted) {
            await ezModal(
              config,
              context: context,
              builder: (_) => StatefulBuilder(
                builder: (_, StateSetter setModal) => ezModalScroll(
                  config,
                  children: <Widget>[
                    // Auth to edit
                    EzSwitchPair(
                      config,
                      key: ValueKey<String>('fes-$editAuth'),
                      value: editAuth,
                      text: l10n(config).gsAuthToEdit,
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.secSet(authToEditKey, value.toString());
                        setModal(() => editAuth = value);
                      },
                    ),
                    config.spacer,

                    // Reset after edit
                    EzSwitchPair(
                      config,
                      key: ValueKey<String>('fes-$editReset'),
                      value: editReset,
                      text: 'Reset home after edits',
                      tipper:
                          'Reset the home screen/turn off editing mode after you leave for the settings page.',
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.setBool(resetAfterEditKey, value);
                        setModal(() => editReset = value);
                      },
                    ),
                    config.separator,

                    // Auth for hidden
                    EzSwitchPair(
                      config,
                      key: ValueKey<String>('fas-$hideAuth'),
                      value: hideAuth,
                      text: l10n(config).gsAuthForHidden,
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.secSet(authForHiddenKey, value.toString());
                        setModal(() => hideAuth = value);
                      },
                    ),
                    config.spacer,

                    // Reset after opened
                    EzSwitchPair(
                      config,
                      key: ValueKey<String>('fas-$openReset'),
                      value: openReset,
                      text: 'Reset after open',
                      tipper:
                          'Reset the home screen/turn off editing mode after you open a hidden app.',
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.setBool(resetAfterOpenedKey, value);
                        setModal(() => openReset = value);
                      },
                    ),

                    // Re-auth timer
                    EzRow(
                      config,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Label
                        Flexible(
                          child: Text(
                            l10n(config).gsAuthTimeout,
                            textAlign: TextAlign.start,
                            style: config.bodyStyle,
                          ),
                        ),
                        config.rowSpacer,

                        // Field
                        EzTextField(
                          controller: _timeoutText,
                          constraints: BoxConstraints(
                            maxHeight: appIconSize(config),
                            maxWidth: fieldWidth,
                          ),
                          errorConstraints: BoxConstraints(maxWidth: fieldWidth * 2),
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          onTap: () => setModal(() {}),
                          onTapOutside: (_) => setModal(() {}),
                          onFieldSubmitted: (String stringVal) async {
                            final int? intVal = int.tryParse(stringVal);
                            if (intVal == null || intVal < 0) return;

                            setModal(() {});
                            await EzCM.secSet(authTimeoutKey, intVal.toString());
                          },
                          validator: (String? value) {
                            if (value == null) return null;
                            final int? intVal = int.tryParse(value);
                            if (intVal == null || intVal < 0) return l10n(config).gsPositiveOnly;

                            return null;
                          },
                        ),
                      ],
                    ),
                    EzKeyboardSpacer(config.spacing * 2),
                  ],
                ),
              ),
            );

            if (_timeoutText.text != authTimeout(config).inMinutes.toString() ||
                editAuth != authToEdit(config) ||
                editReset != resetAfterEdit(config) ||
                hideAuth != authForHidden(config) ||
                openReset != resetAfterOpened(config)) {
              await config.rebuildUI();
            }
          }
        },
      );
}
