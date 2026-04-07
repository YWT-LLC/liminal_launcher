/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTileSetting extends StatelessWidget {
  /// true == folder tile setting
  /// false == list tile setting
  final bool folder;

  /// [EzConfig.rebuildUI] passthrough
  final void Function() onComplete;

  const AppTileSetting({
    super.key,
    required this.folder,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final String darkLabelKey =
        folder ? darkFolderLabelTypeKey : darkListLabelTypeKey;
    final String lightLabelKey =
        folder ? lightFolderLabelTypeKey : lightListLabelTypeKey;

    final String darkIconKey = folder ? darkFolderIconKey : darkListIconKey;
    final String lightIconKey = folder ? lightFolderIconKey : lightListIconKey;

    return EzElevatedIconButton(
      onPressed: () async {
        LabelType labelType = folder ? folderLabels : listLabels;
        bool showIcon = folder ? folderIcons : listIcons;

        await ezModal(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (_, StateSetter setModal) => EzScrollView(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Preview
                showIcon
                    ? EzTextIconButton(
                        icon: const Icon(Icons.settings),
                        label: folder
                            ? folderLabel(type: labelType)
                            : listLabel(labelType),
                        onPressed: doNothing,
                      )
                    : EzTextButton(
                        text: folder
                            ? folderLabel(type: labelType)
                            : listLabel(labelType),
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

                // Local reset
                EzElevatedIconButton(
                  onPressed: () {
                    showIcon = EzConfig.getDefault(
                        EzConfig.isDark ? darkIconKey : lightIconKey);
                    labelType = LabelTypeConfig.lookup(EzConfig.getDefault(
                        EzConfig.isDark ? darkLabelKey : lightLabelKey));
                    setModal(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: EzConfig.l10n.gReset,
                ),
                EzSpacer(space: EzConfig.spargin),
              ],
            ),
          ),
        );

        if (labelType != (folder ? folderLabels : listLabels) ||
            showIcon != (folder ? folderIcons : listIcons)) {
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
      icon: const Icon(Icons.edit),
      label: 'List apps',
    );
  }
}
