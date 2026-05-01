/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTileSetting extends StatelessWidget {
  final bool folder;

  final String darkLabelKey;
  final String lightLabelKey;

  final String darkIconKey;
  final String lightIconKey;

  final String darkElevatedKey;
  final String lightElevatedKey;

  const AppTileSetting({super.key, required this.folder})
      : darkLabelKey = folder ? darkFolderLabelTypeKey : darkListLabelTypeKey,
        lightLabelKey = folder ? lightFolderLabelTypeKey : lightListLabelTypeKey,
        darkIconKey = folder ? darkFolderIconKey : darkListIconKey,
        lightIconKey = folder ? lightFolderIconKey : lightListIconKey,
        darkElevatedKey = folder ? darkElevatedFolderKey : darkElevatedListKey,
        lightElevatedKey = folder ? lightElevatedFolderKey : lightElevatedListKey;

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        onPressed: () async {
          final String label = folder ? 'Liminal Folder' : 'Liminal Launcher';
          final Widget icon = Icon(folder ? Icons.folder : Icons.launch, size: EzConfig.iconSize);

          LabelType labelType = folder ? folderLabels : listLabels;
          bool showIcon = folder ? folderIcons : listIcons;
          bool elevated = folder ? elevatedFolders : elevatedLists;
          bool useWide = wideTiles;

          await ezModal(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (BuildContext mCon, StateSetter setModal) => EzScrollView(
                children: <Widget>[
                  // Preview
                  Container(
                    constraints: useWide ? const BoxConstraints(minWidth: double.infinity) : null,
                    child: AppButton(
                      app: AppInfo(
                        package: nullAppPackage,
                        label: label,
                        removable: false,
                        installDate: 0,
                        packageSize: 0,
                      ),
                      icon: icon,
                      buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
                      labelType: labelType,
                      onPressed: doNothing,
                      onLongPress: doNothing,
                    ),
                  ),
                  EzConfig.separator,

                  // Label type
                  EzRow(
                    children: <Widget>[
                      const EzText('Label type'),
                      EzConfig.rowSpacer,
                      EzDropdownMenu<LabelType>(
                        widthEntry: 'Full name',
                        dropdownMenuEntries: labelEntries,
                        enableSearch: false,
                        initialSelection: labelType,
                        onSelected: (LabelType? choice) async {
                          if (choice == null) return;

                          if (EzConfig.updateBoth || EzConfig.isDark) {
                            await EzConfig.setString(darkLabelKey, choice.value);
                            if (labelType == LabelType.none) {
                              showIcon = true;
                              await EzConfig.setBool(darkIconKey, true);
                            }
                          }

                          if (EzConfig.updateBoth || !EzConfig.isDark) {
                            await EzConfig.setString(lightLabelKey, choice.value);
                            if (labelType == LabelType.none) {
                              showIcon = true;
                              await EzConfig.setBool(lightIconKey, true);
                            }
                          }

                          setModal(() => labelType = choice);
                        },
                      ),
                    ],
                  ),
                  EzConfig.spacer,

                  // Show icon
                  EzSwitchPair(
                    text: 'Show icon',
                    valueKey: EzConfig.isDark ? darkIconKey : lightIconKey,
                    afterChanged: (bool? value) async {
                      if (value == null) return;

                      if (value == false && labelType == LabelType.none) {
                        labelType = LabelType.full;

                        if (EzConfig.updateBoth || EzConfig.isDark) {
                          await EzConfig.setString(darkLabelKey, LabelType.full.value);
                        }
                        if (EzConfig.updateBoth || !EzConfig.isDark) {
                          await EzConfig.setString(lightLabelKey, LabelType.full.value);
                        }
                      }

                      if (EzConfig.updateBoth) {
                        await EzConfig.setBool(
                          EzConfig.isDark ? lightIconKey : darkIconKey,
                          elevated,
                        );
                      }
                      setModal(() => showIcon = value);
                    },
                  ),
                  EzConfig.spacer,

                  // Elevated
                  EzSwitchPair(
                    text: 'Elevated button',
                    valueKey: EzConfig.isDark ? darkElevatedKey : lightElevatedKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;

                      if (EzConfig.updateBoth) {
                        await EzConfig.setBool(
                          EzConfig.isDark ? lightElevatedKey : darkElevatedKey,
                          elevated,
                        );
                      }
                      setModal(() => elevated = choice);
                    },
                  ),
                  EzConfig.separator,

                  // Wide tiles
                  EzSwitchPair(
                    text: 'Use max width (shared)',
                    valueKey: EzConfig.isDark ? darkWideTilesKey : lightWideTilesKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;

                      if (EzConfig.updateBoth) {
                        await EzConfig.setBool(
                          EzConfig.isDark ? lightWideTilesKey : darkWideTilesKey,
                          useWide,
                        );
                      }
                      setModal(() => useWide = choice);
                    },
                  ),
                  EzConfig.separator,
                ],
              ),
            ),
          );

          if ((labelType != (folder ? folderLabels : listLabels)) ||
              (showIcon != (folder ? folderIcons : listIcons)) ||
              (elevated != (folder ? elevatedFolders : elevatedLists)) ||
              (useWide != wideTiles)) {
            await EzConfig.rebuildUI();
          }
        },
        icon: const Icon(Icons.settings),
        label: '${folder ? 'Folder' : 'App'} style',
      );
}
