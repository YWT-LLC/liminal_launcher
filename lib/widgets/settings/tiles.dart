/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTileSetting extends StatelessWidget {
  const AppTileSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return EzElevatedIconButton(
      onPressed: () => ezModal(
        context: context,
        builder: (_) {
          bool showIcon = listIcons;
          LabelType labelType = listLabels;

          return StatefulBuilder(
            builder: (_, StateSetter setModal) => EzScrollView(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Preview
                showIcon
                    ? EzTextIconButton(
                        icon: const Icon(Icons.settings),
                        label: listLabel(labelType),
                        onPressed: doNothing,
                      )
                    : EzTextButton(
                        text: listLabel(labelType),
                        onPressed: doNothing,
                      ),
                EzConfig.spacer,

                // Label type
                EzRow(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const EzText('Label type'),
                    EzConfig.rowSpacer,
                    EzDropdownMenu<LabelType>(
                      widthEntries: <String>['Full name'],
                      dropdownMenuEntries: labelEntries,
                      enableSearch: false,
                      initialSelection: labelType,
                      onSelected: (LabelType? choice) async {
                        if (choice == null) return;

                        await EzConfig.setString(
                          labelTypeKey,
                          choice.configValue,
                        );
                        labelType = choice;

                        if (labelType == LabelType.none) {
                          await EzConfig.setBool(listIconKey, true);
                          showIcon = true;
                        }

                        setModal(() {});
                      },
                    ),
                  ],
                ),
                EzConfig.spacer,

                // Show icon
                EzSwitchPair(
                  key: UniqueKey(),
                  text: 'Show icon',
                  valueKey: listIconKey,
                  onChangedCallback: (bool? value) async {
                    if (value == null) return;

                    showIcon = value;
                    if (value == false && labelType == LabelType.none) {
                      await EzConfig.setString(
                        labelTypeKey,
                        LabelType.full.configValue,
                      );
                      labelType = LabelType.full;
                    }

                    setModal(() {});
                  },
                ),
                EzConfig.separator,
              ],
            ),
          );
        },
      ),
      icon: const Icon(Icons.edit),
      label: 'List apps',
    );
  }
}
