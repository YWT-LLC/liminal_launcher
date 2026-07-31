/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTileSetting extends StatelessWidget {
  final EzCP config;
  final bool folder;

  final String darkLabelKey;
  final String lightLabelKey;

  final String darkIconKey;
  final String lightIconKey;

  final String darkElevatedKey;
  final String lightElevatedKey;

  const AppTileSetting(this.config, {super.key, required this.folder})
      : darkLabelKey = folder ? darkFolderLabelKey : darkListLabelKey,
        lightLabelKey = folder ? lightFolderLabelKey : lightListLabelKey,
        darkIconKey = folder ? darkFolderIconKey : darkListIconKey,
        lightIconKey = folder ? lightFolderIconKey : lightListIconKey,
        darkElevatedKey = folder ? darkElevatedFolderKey : darkElevatedListKey,
        lightElevatedKey = folder ? lightElevatedFolderKey : lightElevatedListKey;

  @override
  Widget build(BuildContext context) => EzElevatedIconButton(
        config,
        onPressed: () async {
          final Uint8List limIcon = (await rootBundle.load(appIconPath)).buffer.asUint8List();

          LabelType labelType = folder ? folderLabels(config) : listLabels(config);
          bool showIcon = folder ? folderIcons(config) : listIcons(config);
          bool elevated = folder ? elevatedFolders(config) : elevatedLists(config);

          bool useWide = wideTiles(config);

          Widget core() => folder
              ? FolderButton(
                  config,
                  name: 'Liminal Folder',
                  icon: Icons.folder_outlined,
                  iconSize: config.iconSize,
                  buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
                  labelType: labelType,
                  onPressed: doNothing,
                  onLongPress: doNothing,
                )
              : AppButton(
                  config,
                  name: 'Liminal App',
                  image: limIcon,
                  icon: null,
                  iconSize: null,
                  buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
                  labelType: labelType,
                  onPressed: doNothing,
                  onLongPress: doNothing,
                );
          if (!context.mounted) return;

          await ezModal(
            config,
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
                config,
                children: <Widget>[
                  // Preview
                  useWide
                      ? InkWell(
                          onTap: doNothing,
                          child: Container(
                            width: double.infinity,
                            alignment: LAConfig.merge(
                              h: horizontalAlign(config),
                              v: ListAlignment.center,
                            ),
                            child: core(),
                          ),
                        )
                      : core(),

                  config.separator,

                  // Label type
                  EzDropdownMenu<LabelType>(
                    config,
                    label: 'Label type',
                    widthEntry: 'Full name',
                    dropdownMenuEntries: LabelType.values
                        .map(
                          (LabelType lt) => DropdownMenuEntry<LabelType>(
                            value: lt,
                            label: ezCamelToTitle(lt.value),
                          ),
                        )
                        .toList(),
                    enableSearch: false,
                    initialSelection: labelType,
                    onSelected: (LabelType? choice) async {
                      if (choice == null) return;

                      if (EzCM.updateBoth || config.isDark) {
                        await EzCM.setString(darkLabelKey, choice.value);
                        if (choice == LabelType.none) {
                          showIcon = true;
                          await EzCM.setBool(darkIconKey, true);
                        }
                      }

                      if (EzCM.updateBoth || !config.isDark) {
                        await EzCM.setString(lightLabelKey, choice.value);
                        if (choice == LabelType.none) {
                          showIcon = true;
                          await EzCM.setBool(lightIconKey, true);
                        }
                      }

                      setModal(() => labelType = choice);
                    },
                  ),
                  config.spacer,

                  // Show icon
                  EzSwitchPair(
                    config,
                    text: 'Show icon',
                    valueKey: config.isDark ? darkIconKey : lightIconKey,
                    afterChanged: (bool? value) async {
                      if (value == null) return;

                      if (value == false && labelType == LabelType.none) {
                        labelType = LabelType.full;

                        if (EzCM.updateBoth || config.isDark) {
                          await EzCM.setString(darkLabelKey, LabelType.full.value);
                        }
                        if (EzCM.updateBoth || !config.isDark) {
                          await EzCM.setString(lightLabelKey, LabelType.full.value);
                        }
                      }

                      if (EzCM.updateBoth) {
                        await EzCM.setBool(config.isDark ? lightIconKey : darkIconKey, value);
                      }
                      setModal(() => showIcon = value);
                    },
                  ),
                  config.spacer,

                  // Elevated
                  EzSwitchPair(
                    config,
                    text: 'Elevated button',
                    valueKey: config.isDark ? darkElevatedKey : lightElevatedKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;

                      if (EzCM.updateBoth) {
                        await EzCM.setBool(
                            config.isDark ? lightElevatedKey : darkElevatedKey, choice);
                      }
                      setModal(() => elevated = choice);
                    },
                  ),
                  EzTitledDivider(
                    config,
                    title: Text('Shared', textAlign: TextAlign.center, style: config.labelStyle),
                    height: config.spacing * 3,
                  ),

                  // Wide tiles
                  EzSwitchPair(
                    config,
                    text: 'Wide tiles',
                    valueKey: config.isDark ? darkWideTilesKey : lightWideTilesKey,
                    afterChanged: (bool? choice) async {
                      if (choice == null) return;

                      if (EzCM.updateBoth) {
                        await EzCM.setBool(
                          config.isDark ? lightWideTilesKey : darkWideTilesKey,
                          choice,
                        );
                      }
                      setModal(() => useWide = choice);
                    },
                  ),
                  config.separator,
                ],
              ),
            ),
          );

          if ((labelType != (folder ? folderLabels(config) : listLabels(config))) ||
              (showIcon != (folder ? folderIcons(config) : listIcons(config))) ||
              (elevated != (folder ? elevatedFolders(config) : elevatedLists(config))) ||
              (useWide != wideTiles(config))) {
            await config.rebuildUI();
          }
        },
        icon: EzIcon(config, Icons.settings),
        label: '${folder ? 'Folder' : 'App'} tile',
      );
}
