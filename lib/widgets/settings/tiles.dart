/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

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
                    child: showIcon
                        ? elevated
                            ? EzElevatedIconButton(
                                icon: icon,
                                label: buildLabel(label, labelType),
                                style: TextButton.styleFrom(
                                    padding: EzInsets.wrap(EzConfig.marginVal)),
                                onPressed: doNothing,
                              )
                            : EzTextIconButton(
                                icon: icon,
                                label: buildLabel(label, labelType),
                                style: TextButton.styleFrom(
                                    padding: EzInsets.wrap(EzConfig.marginVal)),
                                onPressed: doNothing,
                              )
                        : elevated
                            ? EzElevatedButton(
                                text: buildLabel(label, labelType),
                                style: TextButton.styleFrom(
                                    padding: EzInsets.wrap(EzConfig.marginVal)),
                                onPressed: doNothing,
                              )
                            : EzTextButton(
                                text: buildLabel(label, labelType),
                                style: TextButton.styleFrom(
                                    padding: EzInsets.wrap(EzConfig.marginVal)),
                                onPressed: doNothing,
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
                        onSelected: (LabelType? choice) {
                          if (choice == null) return;

                          if (labelType == LabelType.none) {
                            showIcon = true;
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
                    afterChanged: (bool? value) {
                      if (value == null) return;

                      if (value == false && labelType == LabelType.none) {
                        labelType = LabelType.full;
                      }
                      setModal(() => showIcon = value);
                    },
                  ),
                  EzConfig.spacer,

                  // Elevated
                  EzSwitchPair(
                    text: 'Elevated button',
                    valueKey: EzConfig.isDark ? darkElevatedKey : lightElevatedKey,
                    afterChanged: (bool? value) {
                      if (value == null) return;
                      setModal(() => elevated = value);
                    },
                  ),
                  EzConfig.separator,

                  // Wide tiles
                  EzSwitchPair(
                    text: 'Use max width (shared)',
                    valueKey: EzConfig.isDark ? darkWideTilesKey : lightWideTilesKey,
                    afterChanged: (bool? choice) {
                      if (choice == null) return;
                      setModal(() => useWide = choice);
                    },
                  ),
                  EzConfig.separator,
                ],
              ),
            ),
          );
          bool needsRebuild = false;

          if (labelType != (folder ? folderLabels : listLabels)) {
            if (EzConfig.updateBoth || EzConfig.isDark) {
              await EzConfig.setString(darkLabelKey, labelType.value);
            }
            if (EzConfig.updateBoth || !EzConfig.isDark) {
              await EzConfig.setString(lightLabelKey, labelType.value);
            }
            needsRebuild = true;
          }

          if (showIcon != (folder ? folderIcons : listIcons)) {
            if (EzConfig.updateBoth || EzConfig.isDark) {
              await EzConfig.setBool(darkIconKey, showIcon);
            }
            if (EzConfig.updateBoth || !EzConfig.isDark) {
              await EzConfig.setBool(lightIconKey, showIcon);
            }
            needsRebuild = true;
          }

          if (elevated != (folder ? elevatedFolders : elevatedLists)) {
            if (EzConfig.updateBoth || EzConfig.isDark) {
              await EzConfig.setBool(darkElevatedKey, elevated);
            }
            if (EzConfig.updateBoth || !EzConfig.isDark) {
              await EzConfig.setBool(lightElevatedKey, elevated);
            }
            needsRebuild = true;
          }

          if (useWide != wideTiles) {
            if (EzConfig.updateBoth || EzConfig.isDark) {
              await EzConfig.setBool(darkWideTilesKey, useWide);
            }
            if (EzConfig.updateBoth || !EzConfig.isDark) {
              await EzConfig.setBool(lightWideTilesKey, useWide);
            }
            needsRebuild = true;
          }

          if (needsRebuild) await EzConfig.rebuildUI();
        },
        icon: const Icon(Icons.settings),
        label: '${folder ? 'Folder' : 'List'} tiles',
      );
}
