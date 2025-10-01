/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  // Gather the theme data //

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  // Define the build data //

  bool listIcon = EzConfig.get(listIconKey);
  LabelType listLabelType =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  bool folderIcon = EzConfig.get(folderIconKey);
  LabelType folderLabelType =
      LabelTypeConfig.fromValue(EzConfig.get(folderLabelTypeKey));

  final List<DropdownMenuEntry<LabelType>> labelEntries =
      <DropdownMenuEntry<LabelType>>[
    const DropdownMenuEntry<LabelType>(
      value: LabelType.none,
      label: 'None',
    ),
    const DropdownMenuEntry<LabelType>(
      value: LabelType.initials,
      label: 'Initials',
    ),
    const DropdownMenuEntry<LabelType>(
      value: LabelType.full,
      label: 'Full name',
    ),
    const DropdownMenuEntry<LabelType>(
      value: LabelType.wingding,
      label: 'Wingding',
    ),
  ];

  // Define custom functions //

  String listLabel() {
    const String base = 'List App';

    switch (listLabelType) {
      case LabelType.none:
        return '';

      case LabelType.initials:
        return base
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();

      case LabelType.full:
        return base;

      case LabelType.wingding:
        return base
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
    }
  }

  String folderLabel() {
    const String base = 'Folder App';

    switch (folderLabelType) {
      case LabelType.none:
        return '';

      case LabelType.initials:
        return base
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();

      case LabelType.full:
        return base;

      case LabelType.wingding:
        return base
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
    }
  }

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        if (spacing > margin) EzSpacer(space: spacing - margin),

        // Header //

        // Time
        const EzSwitchPair(text: 'Home time', valueKey: homeTimeKey),
        ezSpacer,

        // Date
        const EzSwitchPair(text: 'Home date', valueKey: homeDateKey),
        ezDivider,

        // List AppTile //
        // Preview
        listIcon
            ? EzTextIconButton(
                icon: EzIcon(PlatformIcons(context).settings),
                label: listLabel(),
                onPressed: doNothing,
              )
            : EzTextButton(
                text: listLabel(),
                onPressed: doNothing,
              ),
        ezSpacer,

        // Label type
        EzRow(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const EzText('Label type'),
            ezRowSpacer,
            EzDropdownMenu<LabelType>(
              widthEntries: <String>['Full name'],
              dropdownMenuEntries: labelEntries,
              enableSearch: false,
              initialSelection: listLabelType,
              onSelected: (LabelType? choice) async {
                if (choice == null) return;

                await EzConfig.setString(
                  listLabelTypeKey,
                  choice.configValue,
                );
                listLabelType = choice;

                if (listLabelType == LabelType.none) {
                  await EzConfig.setBool(listIconKey, true);
                  listIcon = true;
                }

                setState(() {});
              },
            ),
          ],
        ),
        ezRowSpacer,

        // Show icon
        EzSwitchPair(
          text: 'Show icon',
          valueKey: listIconKey,
          onChangedCallback: (bool? value) async {
            if (value == null) return;

            listIcon = value;
            if (value == false && listLabelType == LabelType.none) {
              await EzConfig.setString(
                listLabelTypeKey,
                LabelType.full.configValue,
              );
              listLabelType = LabelType.full;
            }

            setState(() {});
          },
        ),
        ezDivider,

        // Folder AppTile //
        // Preview
        folderIcon
            ? EzTextIconButton(
                icon: EzIcon(PlatformIcons(context).settings),
                label: folderLabel(),
                onPressed: doNothing,
              )
            : EzTextButton(
                text: folderLabel(),
                onPressed: doNothing,
              ),
        ezSpacer,

        // Label type
        EzRow(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const EzText('Label type'),
            ezRowSpacer,
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

                setState(() {});
              },
            ),
          ],
        ),
        ezRowSpacer,

        // Show icon
        EzSwitchPair(
          text: 'Show icon',
          valueKey: folderIconKey,
          onChangedCallback: (bool? value) async {
            if (value == null) return;

            folderIcon = value;
            if (value == false && folderLabelType == LabelType.none) {
              await EzConfig.setString(
                folderLabelTypeKey,
                LabelType.full.configValue,
              );
              folderLabelType = LabelType.full;
            }

            setState(() {});
          },
        ),
        ezSeparator,
      ]),
      fabs: <Widget>[ezSpacer, EzBackFAB(context)],
    );
  }
}
