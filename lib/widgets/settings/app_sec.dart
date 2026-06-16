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
          final Size fieldSize = ezTextSize(
            '55',
            context: context,
            style: config.bodyStyle,
          );
          final double sep = config.spacing * 2;
          double bottomSpace = sep;

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
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                max(fieldSize.height + config.padding, kMinInteractiveDimension),
                            maxWidth:
                                max(fieldSize.width + config.padding, kMinInteractiveDimension),
                          ),
                          child: TextFormField(
                            controller: _timeoutText,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onTap: () async {
                              // Wait a bit for the keyboard to open
                              await Future<void>.delayed(const Duration(milliseconds: 300));

                              setModal(() =>
                                  bottomSpace = (sep + MediaQuery.of(context).viewInsets.bottom));
                            },
                            onTapAlwaysCalled: true,
                            onTapOutside: (_) => setModal(() => bottomSpace = sep),
                            validator: (String? value) {
                              if (value == null) return null;
                              final int? intVal = int.tryParse(value);
                              if (intVal == null || intVal < 0) return 'Positive integers only';

                              return null;
                            },
                            onFieldSubmitted: (String stringVal) async {
                              final int? intVal = int.tryParse(stringVal);
                              if (intVal == null || intVal < 0) return;

                              setModal(() => bottomSpace = sep);
                              await EzCM.secSet(authTimeoutKey, intVal.toString());
                            },
                          ),
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
