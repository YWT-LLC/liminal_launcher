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

  /// [EzConfig.rebuildUI] passthrough
  final void Function() onComplete;

  const AppTileSetting({
    super.key,
    required this.folder,
    required this.onComplete,
  })  : darkLabelKey = folder ? darkFolderLabelTypeKey : darkListLabelTypeKey,
        lightLabelKey =
            folder ? lightFolderLabelTypeKey : lightListLabelTypeKey,
        darkIconKey = folder ? darkFolderIconKey : darkListIconKey,
        lightIconKey = folder ? lightFolderIconKey : lightListIconKey;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EzInsets.wrap(EzConfig.marginVal);

    return EzElevatedIconButton(
      onPressed: () async {
        LabelType labelType = folder ? folderLabels : listLabels;
        bool showIcon = folder ? folderIcons : listIcons;
        bool useWide = wideTiles;

        await ezModal(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (BuildContext mCon, StateSetter setModal) => EzScrollView(
              children: <Widget>[
                // Preview
                Container(
                  constraints: useWide
                      ? const BoxConstraints(minWidth: double.infinity)
                      : null,
                  child: showIcon
                      ? folder
                          ? EzTextIconButton(
                              icon: Icon(Icons.folder, size: appIconSize),
                              label: buildLabel('Liminal Folder', labelType),
                              style: TextButton.styleFrom(padding: padding),
                              onPressed: doNothing,
                            )
                          : EzTextIconButton(
                              icon: Icon(Icons.launch, size: appIconSize),
                              label: buildLabel('Liminal Launcher', labelType),
                              style: TextButton.styleFrom(padding: padding),
                              onPressed: doNothing,
                            )
                      : folder
                          ? EzTextButton(
                              text: buildLabel('Liminal Folder', labelType),
                              style: TextButton.styleFrom(padding: padding),
                              onPressed: doNothing,
                            )
                          : EzTextButton(
                              text: buildLabel('Liminal Launcher', labelType),
                              style: TextButton.styleFrom(padding: padding),
                              onPressed: doNothing,
                            ),
                ),
                EzConfig.spacer,

                // Label type
                EzRow(
                  children: <Widget>[
                    const EzText('Label type'),
                    EzConfig.rowSpacer,
                    EzDropdownMenu<LabelType>(
                      widthEntries: <String>['Full name'],
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
                  key: UniqueKey(),
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
                EzConfig.separator,

                // Wide tiles
                EzSwitchPair(
                  text: 'Use max width (shared)',
                  valueKey:
                      EzConfig.isDark ? darkWideTilesKey : lightWideTilesKey,
                  afterChanged: (bool? choice) async {
                    if (choice == null) return;
                    if (EzConfig.updateBoth) {
                      await EzConfig.setBool(
                        EzConfig.isDark ? lightWideTilesKey : darkWideTilesKey,
                        choice,
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

        if (labelType != (folder ? folderLabels : listLabels) ||
            showIcon != (folder ? folderIcons : listIcons) ||
            useWide != wideTiles) {
          if (EzConfig.updateBoth || EzConfig.isDark) {
            await EzConfig.setString(darkLabelKey, labelType.value);
            await EzConfig.setBool(darkIconKey, showIcon);
          }

          if (EzConfig.updateBoth || !EzConfig.isDark) {
            await EzConfig.setString(lightLabelKey, labelType.value);
            await EzConfig.setBool(lightIconKey, showIcon);
          }

          await EzConfig.rebuildUI(onComplete);
        }
      },
      icon: const Icon(Icons.settings),
      label: '${folder ? 'Folder' : 'List'} tiles',
    );
  }
}
