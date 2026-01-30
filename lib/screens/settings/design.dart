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

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen>
    with WidgetsBindingObserver {
  // Define the build data //

  int redraw = 0;

  late String homeTimeKey;
  late String homeDateKey;
  late DateType currDateType;
  late String listIconKey;
  late String listLabelTypeKey;
  late String folderIconKey;
  late String folderLabelTypeKey;

  // TODO: add to cache or provider
  // void setContextualData(bool isDark) {
  //   if (isDark) {
  //     homeTimeKey = darkHomeTimeKey;
  //     homeDateKey = darkHomeDateKey;
  //     currDateType = DateTypeConfig.fromValue(EzConfig.get(darkHomeDateKey));
  //     listIconKey = darkListIconKey;
  //     listLabelTypeKey = darkListLabelTypeKey;
  //     folderIconKey = darkFolderIconKey;
  //     folderLabelTypeKey = darkFolderLabelTypeKey;
  //   } else {
  //     homeTimeKey = lightHomeTimeKey;
  //     homeDateKey = lightHomeDateKey;
  //     currDateType = DateTypeConfig.fromValue(EzConfig.get(lightHomeDateKey));
  //     listIconKey = lightListIconKey;
  //     listLabelTypeKey = lightListLabelTypeKey;
  //     folderIconKey = lightFolderIconKey;
  //     folderLabelTypeKey = lightFolderLabelTypeKey;
  //   }
  // }

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

  void drawState() => setState(() => redraw = Random().nextInt(rMax));

  String listLabel(LabelType type) {
    const String base = 'List App';

    switch (type) {
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

  String folderLabel(LabelType type) {
    const String base = 'Folder App';

    switch (type) {
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

  // Init //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return LiminalScaffold(
      EzDesignSettings(
        themeLink: () => AppSettings.openAppSettings(
          type: AppSettingsType.display,
          asAnotherTask: true,
        ),
        includeScroll: false,
        includeBackgroundImage: false,
        afterDesign: <Widget>[
          // Wallpaper //

          if (EzConfig.get(EzConfig.isDark ? darkUseOSKey : lightUseOSKey) ==
              false) ...<Widget>[
            EzConfig.spacer,
            EzScrollView(
              scrollDirection: Axis.horizontal,
              startCentered: true,
              mainAxisSize: MainAxisSize.min,
              child: EzConfig.isDark
                  ? EzImageSetting(
                      key: UniqueKey(),
                      configKey: darkBackgroundImageKey,
                      updateTheme: Brightness.dark,
                      allowSolidColor: true,
                      label: 'Wallpaper',
                    )
                  : EzImageSetting(
                      key: UniqueKey(),
                      configKey: lightBackgroundImageKey,
                      updateTheme: Brightness.light,
                      allowSolidColor: true,
                      label: 'Wallpaper',
                    ),
            ),
          ],

          // Use OS
          EzConfig.spacer,
          EzSwitchPair(
            key: ValueKey<String>('use_os_$redraw'),
            text: 'Use System Wallpaper',
            valueKey: EzConfig.isDark ? darkUseOSKey : lightUseOSKey,
            onChangedCallback: (bool? choice) {
              if (choice == null) return;
              setState(() {});
            },
          ),
          EzConfig.separator,

          // Header settings //

          // Time
          EzSwitchPair(
            key: ValueKey<String>('time_switch_$redraw'),
            text: 'Show time',
            valueKey: homeTimeKey,
          ),
          EzConfig.spacer,

          // Date
          EzScrollView(
            scrollDirection: Axis.horizontal,
            reverseHands: true,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Label
              EzText(
                'Date type',
                style: EzConfig.styles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              EzConfig.margin,

              // Button
              EzDropdownMenu<DateType>(
                enableSearch: false,
                initialSelection: currDateType,
                dropdownMenuEntries: DateType.values
                    .map((DateType type) => DropdownMenuEntry<DateType>(
                          value: type,
                          label: DateTypeConfig.buildDate(type, context, now),
                        ))
                    .toList(),
                widthEntries: <String>['Wednesday, Sept'],
                onSelected: (DateType? choice) async {
                  if (choice == null) return;
                  await EzConfig.setString(homeDateKey, choice.configValue);
                  setState(() => currDateType = choice);
                },
              ),
            ],
          ),
          EzConfig.spacer,

          // AppTile settings //

          // List
          EzElevatedIconButton(
            onPressed: () => ezModal(
              context: context,
              builder: (_) {
                bool listIcon = EzConfig.get(listIconKey);
                LabelType listLabelType =
                    LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

                return StatefulBuilder(
                  builder: (_, StateSetter setModal) => EzScrollView(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Preview
                      listIcon
                          ? EzTextIconButton(
                              icon: const Icon(Icons.settings),
                              label: listLabel(listLabelType),
                              onPressed: doNothing,
                            )
                          : EzTextButton(
                              text: listLabel(listLabelType),
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

                          listIcon = value;
                          if (value == false &&
                              listLabelType == LabelType.none) {
                            await EzConfig.setString(
                              listLabelTypeKey,
                              LabelType.full.configValue,
                            );
                            listLabelType = LabelType.full;
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
          ),
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
