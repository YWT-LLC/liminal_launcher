/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

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
          LabelType labelType = folder ? folderLabels(config) : listLabels(config);
          bool showIcon = folder ? folderIcons(config) : listIcons(config);
          bool elevated = folder ? elevatedFolders(config) : elevatedLists(config);
          bool useWide = wideTiles(config);
          bool fullscreen = pages(config);

          Widget core() => folder
              ? FolderButton(
                  config,
                  name: 'Liminal Folder',
                  icon: Icons.folder_outlined,
                  buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
                  labelType: labelType,
                  onPressed: doNothing,
                  onLongPress: doNothing,
                )
              : AppButton(
                  config,
                  name: 'Liminal App',
                  image: null,
                  icon: Icons.launch,
                  buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
                  labelType: labelType,
                  onPressed: doNothing,
                  onLongPress: doNothing,
                );

          await ezModal(
            config,
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (BuildContext mCon, StateSetter setModal) =>
                  ezModalScroll(config, children: <Widget>[
                // Preview
                useWide
                    ? InkWell(
                        onTap: doNothing,
                        child: Container(
                          width: double.infinity,
                          alignment: LAConfig.merge(h: hAlign(config), v: ListAlignment.center),
                          child: core(),
                        ),
                      )
                    : core(),

                config.separator,

                // Label type
                EzRow(
                  config,
                  children: <Widget>[
                    EzText(config, text: 'Label type'),
                    config.rowSpacer,
                    EzDropdownMenu<LabelType>(
                      config,
                      widthEntry: 'Full name',
                      dropdownMenuEntries: LabelType.values
                          .map((LabelType lt) => DropdownMenuEntry<LabelType>(
                                value: lt,
                                label: ezCamelToTitle(lt.value),
                              ))
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
                  ],
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
                        config.isDark ? lightElevatedKey : darkElevatedKey,
                        choice,
                      );
                    }
                    setModal(() => elevated = choice);
                  },
                ),
                EzTitledDivider(
                  Text('Shared', textAlign: TextAlign.center, style: config.labelStyle),
                  height: config.spacing * 3,
                  margin: config.marginVal,
                ),

                // Wide tiles
                EzSwitchPair(
                  config,
                  text: 'Max width tiles',
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
                config.spacer,

                // Fullscreen pages
                EzSwitchPair(
                  config,
                  text: 'Fullscreen pages',
                  enabled: useWide,
                  valueKey: config.isDark ? darkPagesKey : lightPagesKey,
                  afterChanged: (bool? choice) async {
                    if (choice == null) return;

                    if (EzCM.updateBoth) {
                      await EzCM.setBool(
                        config.isDark ? lightPagesKey : darkPagesKey,
                        choice,
                      );
                    }
                    setModal(() => fullscreen = choice);
                  },
                ),
                config.separator,
              ]),
            ),
          );

          if ((labelType != (folder ? folderLabels(config) : listLabels(config))) ||
              (showIcon != (folder ? folderIcons(config) : listIcons(config))) ||
              (elevated != (folder ? elevatedFolders(config) : elevatedLists(config))) ||
              (useWide != wideTiles(config)) ||
              fullscreen != pages(config)) {
            await config.rebuildUI(<EzCacheType>{EzCacheType.design});
          }
        },
        icon: EzIcon(config, Icons.settings),
        label: '${folder ? 'Folder' : 'App'} style',
      );
}
