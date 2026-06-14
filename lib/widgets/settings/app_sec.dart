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
  final ScrollController _timeoutScroll;

  AppSecSettings(this.config, {super.key})
      : _timeoutText = TextEditingController(),
        _timeoutScroll = ScrollController();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        label: 'Security',
        icon: EzIcon(config, Icons.security),
        onPressed: () async {
          final Size fieldSize = ezTextSize(
            '55',
            context: context,
            style: config.bodyStyle,
          );

          _timeoutText.text = authTimeout(config).inMinutes.toString();
          bool forEdit = authToEdit(config);
          bool forAuth = authForHidden(config);

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
                      key: ValueKey<String>('fas-$forAuth'),
                      value: forAuth,
                      text: 'Auth to see hidden apps',
                      onChanged: (bool? value) async {
                        if (value == null) return;

                        await EzCM.secSet(authForHiddenKey, value.toString());
                        setModal(() => forAuth = value);
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
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onTap: () async {
                              // Wait a half sec for the Spacer to resize first
                              await Future<void>.delayed(const Duration(milliseconds: 500));

                              // Scroll to the bottom
                              await _timeoutScroll.animateTo(
                                _timeoutScroll.position.maxScrollExtent,
                                duration: ezDuration(config.animDur),
                                curve: Curves.easeInOut,
                              );
                            },
                            validator: (String? value) {
                              if (value == null) return null;
                              final int? intVal = int.tryParse(value);
                              if (intVal == null || intVal < 0) return 'Positive integers only';

                              return null;
                            },
                            onFieldSubmitted: (String stringVal) async {
                              final int? intVal = int.tryParse(stringVal);
                              if (intVal == null || intVal < 0) return;

                              await EzCM.secSet(authTimeoutKey, intVal.toString());
                            },
                          ),
                        ),
                      ],
                    ),
                    EzSpacer(MediaQuery.of(context).viewInsets.bottom),
                    config.separator,
                  ],
                  controller: _timeoutScroll,
                ),
              ),
            );

            if (_timeoutText.text != authTimeout(config).inMinutes.toString() ||
                forEdit != authToEdit(config) ||
                forAuth != authForHidden(config)) {
              await config.rebuildUI(noECT);
            }
          }
        },
      );
}
