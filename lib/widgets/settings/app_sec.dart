/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppSecSettings extends StatelessWidget {
  final EzCP config;
  final TextEditingController _timeoutText;

  AppSecSettings(this.config, {super.key}) : _timeoutText = TextEditingController();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: 'Security',
        icon: EzIcon(config, Icons.security),
        onPressed: () async {
          bool forEdit = authToEdit(config);
          bool forHide = authForHidden(config);

          _timeoutText.text = authTimeout(config).inMinutes.toString();
          final Size ttSize = ezTextSize(
            '55',
            context: context,
            style: config.bodyStyle,
          );
          final double fieldHeight = max(ttSize.height + config.padding, kMinInteractiveDimension);
          final double fieldWidth = max(ttSize.width + config.padding, kMinInteractiveDimension);

          double bottomSpace = config.spacing * 2;

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
                      key: ValueKey<String>('fes-$forEdit'),
                      value: forEdit,
                      text: 'Auth to edit lists/settings',
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.secSet(authToEditKey, value.toString());
                        setModal(() => forEdit = value);
                      },
                    ),
                    config.spacer,

                    // Auth for hidden
                    EzSwitchPair(
                      config,
                      key: ValueKey<String>('fas-$forHide'),
                      value: forHide,
                      text: 'Auth to see hidden apps',
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.secSet(authForHiddenKey, value.toString());
                        setModal(() => forHide = value);
                      },
                    ),
                    config.spacer,

                    // Re-auth timer
                    EzRow(
                      config,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Label
                        Flexible(
                          child: Text(
                            'Auth timeout (mins)',
                            textAlign: TextAlign.start,
                            style: config.bodyStyle,
                          ),
                        ),
                        config.rowSpacer,

                        // Field
                        EzTextField(
                          controller: _timeoutText,
                          constraints: BoxConstraints(maxHeight: fieldHeight, maxWidth: fieldWidth),
                          errorConstraints:
                              BoxConstraints(maxHeight: fieldHeight, maxWidth: fieldWidth * 2),
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          onTap: () async {
                            // Wait a bit for the keyboard to open
                            await Future<void>.delayed(const Duration(milliseconds: 300));

                            setModal(() => bottomSpace =
                                ((config.spacing * 2) + MediaQuery.of(context).viewInsets.bottom));
                          },
                          onTapOutside: (_) => setModal(() => bottomSpace = (config.spacing * 2)),
                          onFieldSubmitted: (String stringVal) async {
                            final int? intVal = int.tryParse(stringVal);
                            if (intVal == null || intVal < 0) return;

                            setModal(() => bottomSpace = (config.spacing * 2));
                            await EzCM.secSet(authTimeoutKey, intVal.toString());
                          },
                          validator: (String? value) {
                            if (value == null) return null;
                            final int? intVal = int.tryParse(value);
                            if (intVal == null || intVal < 0) return 'Positive integers only';

                            return null;
                          },
                        ),
                      ],
                    ),
                    EzSpacer(bottomSpace),
                  ],
                ),
              ),
            );

            if (_timeoutText.text != authTimeout(config).inMinutes.toString() ||
                forEdit != authToEdit(config) ||
                forHide != authForHidden(config)) {
              await config.rebuildUI(noECT);
            }
          }
        },
      );
}
