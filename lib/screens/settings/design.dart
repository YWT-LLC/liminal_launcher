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



  //* Return the build *//

  @override
  Widget build(BuildContext context) {

    return LiminalScaffold(
      EzDesignSettings(
        afterDesign: <Widget>[
          // Wallpaper //

          

          

          // Header settings //

          
          EzConfig.spacer,

          // AppTile settings //

          // List
          ,
          EzConfig.spacer,

          // Folder
          EzElevatedIconButton(
            onPressed: () => ezModal(
              context: context,
              builder: (_) {
                bool folderIcon = EzConfig.get(folderIconKey);
                LabelType folderLabelType = LabelTypeConfig.fromValue(
                  EzConfig.get(folderLabelTypeKey),
                );

                return StatefulBuilder(
                  builder: (_, StateSetter setModal) => EzScrollView(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Preview
                      folderIcon
                          ? EzTextIconButton(
                              icon: const Icon(Icons.settings),
                              label: folderLabel(folderLabelType),
                              onPressed: doNothing,
                            )
                          : EzTextButton(
                              text: folderLabel(folderLabelType),
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
                            initialSelection: folderLabelType,
                            onSelected: (LabelType? choice) async {
                              if (choice == null) return;

                              await EzConfig.setString(
                                folderLabelTypeKey,
                                choice.configValue,
                              );
                              folderLabelType = choice;

                              if (folderLabelType == LabelType.none) {
                                await EzConfig.setBool(folderIconKey, true);
                                folderIcon = true;
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
                        valueKey: folderIconKey,
                        onChangedCallback: (bool? value) async {
                          if (value == null) return;

                          folderIcon = value;
                          if (value == false &&
                              folderLabelType == LabelType.none) {
                            await EzConfig.setString(
                              folderLabelTypeKey,
                              LabelType.full.configValue,
                            );
                            folderLabelType = LabelType.full;
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
            label: 'Folder apps',
          ),
          EzConfig.spacer,
        ],
        resetExtraDark: <String>{darkUseOSKey},
        resetExtraLight: <String>{darkUseOSKey},
        onReset: drawState,
        appName: appName,
        androidPackage: androidPackage,
      ),
      fabs: settingsFABs(context),
    );
  }

  

