/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppSecSettings extends StatelessWidget {
  final TextEditingController _timeoutText;
  final ScrollController _timeoutScroll;

  AppSecSettings({super.key})
      : _timeoutText = TextEditingController(),
        _timeoutScroll = ScrollController();

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        label: 'Security',
        icon: const Icon(Icons.security),
        onPressed: () async {
          final Size fieldSize = ezTextSize(
            '55',
            context: context,
            style: EzConfig.bodyStyle,
          );

          final int timeoutBackup = int.tryParse(await EzConfig.secGet(authTimeoutKey)) ??
              (limSecDef[authTimeoutKey] as int);
          _timeoutText.text = timeoutBackup.toString();

          if (context.mounted) {
            await ezModal(
              context: context,
              builder: (_) => ezModalScroll(
                <Widget>[
                  // Auth to edit
                  const EzSwitchPair(
                    text: 'Auth to edit lists/settings',
                    valueKey: authToEditKey,
                    secureKey: true,
                  ),
                  EzConfig.spacer,

                  // Auth for hidden
                  const EzSwitchPair(
                    text: 'Auth to see hidden apps',
                    valueKey: authForHiddenKey,
                    secureKey: true,
                  ),
                  EzConfig.spacer,

                  // Re-auth timer
                  EzRow(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Label
                      Flexible(
                        child: Text(
                          'Auth timeout (mins)',
                          textAlign: TextAlign.start,
                          style: EzConfig.bodyStyle,
                        ),
                      ),
                      EzConfig.rowSpacer,

                      // Field
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              max(fieldSize.height + EzConfig.padding, kMinInteractiveDimension),
                          maxWidth:
                              max(fieldSize.width + EzConfig.padding, kMinInteractiveDimension),
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
                              duration: ezAnimDuration(),
                              curve: Curves.easeInOut,
                            );
                          },
                          validator: (String? value) {
                            if (value == null) return null;
                            final int? intVal = int.tryParse(value);

                            if (intVal == null || intVal < 0) {
                              return 'Positive integers only';
                            }
                            return null;
                          },
                          onFieldSubmitted: (String stringVal) async {
                            final int? intVal = int.tryParse(stringVal);

                            if (intVal == null || intVal < 0) {
                              return;
                            }
                            await EzConfig.secSet(authTimeoutKey, intVal.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  EzSpacer(space: MediaQuery.of(context).viewInsets.bottom),
                  EzConfig.separator,
                ],
                controller: _timeoutScroll,
              ),
            );
          }
        },
      );
}
