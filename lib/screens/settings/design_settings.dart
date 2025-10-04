/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
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

  int redraw = 0;

  late double buttonOpacity;
  late double outlineOpacity;

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
    if (isDarkTheme(context)) {
      buttonOpacity = EzConfig.get(darkButtonOpacityKey);
      outlineOpacity = EzConfig.get(darkButtonOutlineOpacityKey);
    } else {
      buttonOpacity = EzConfig.get(lightButtonOpacityKey);
      outlineOpacity = EzConfig.get(lightButtonOutlineOpacityKey);
    }
  }

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    final bool isDark = isDarkTheme(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color buttonSurface =
        colorScheme.surface.withValues(alpha: buttonOpacity);
    final Color buttonOutline =
        colorScheme.primaryContainer.withValues(alpha: outlineOpacity);

    final Color switchSurface =
        colorScheme.surface.withValues(alpha: max(crucialOT, buttonOpacity));
    final WidgetStatePropertyAll<Color> switchOutline =
        WidgetStatePropertyAll<Color>(buttonOutline);

    final ButtonStyle ebStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonSurface,
      shadowColor:
          colorScheme.shadow.withValues(alpha: buttonOpacity * shadowMod),
      side: BorderSide(color: buttonOutline),
    );

    return LiminalScaffold(
      EzDesignSettings(
        globalSettingsPrepend: <Widget>[
          ezSpacer,

          // Header settings //

          // Time
          EzSwitchPair(
            key: ValueKey<String>('time_switch_$redraw'),
            text: 'Home time',
            valueKey: homeTimeKey,
            activeTrackColor: switchSurface,
            inactiveTrackColor: switchSurface,
            trackOutlineColor: switchOutline,
          ),
          ezSpacer,

          // Date
          EzSwitchPair(
            key: ValueKey<String>('date_switch_$redraw'),
            text: 'Home date',
            valueKey: homeDateKey,
            activeTrackColor: switchSurface,
            inactiveTrackColor: switchSurface,
            trackOutlineColor: switchOutline,
          ),
          ezSeparator,

          // AppTile settings //

          // List
          EzElevatedIconButton(
            style: ebStyle,
            onPressed: () => showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints(minWidth: double.infinity),
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
                              icon: EzIcon(PlatformIcons(context).settings),
                              label: listLabel(listLabelType),
                              onPressed: doNothing,
                            )
                          : EzTextButton(
                              text: listLabel(listLabelType),
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

                              setModal(() {});
                            },
                          ),
                        ],
                      ),
                      ezSpacer,

                      // Show icon
                      EzSwitchPair(
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
                      ezSeparator,
                    ],
                  ),
                );
              },
            ),
            icon: Icon(PlatformIcons(context).edit),
            label: 'List apps',
          ),
          ezSpacer,

          // Folder
          EzElevatedIconButton(
            style: ebStyle,
            onPressed: () => showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints(minWidth: double.infinity),
              builder: (_) {
                bool folderIcon = EzConfig.get(folderIconKey);
                LabelType folderLabelType =
                    LabelTypeConfig.fromValue(EzConfig.get(folderLabelTypeKey));

                return StatefulBuilder(
                  builder: (_, StateSetter setModal) => EzScrollView(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Preview
                      folderIcon
                          ? EzTextIconButton(
                              icon: EzIcon(PlatformIcons(context).settings),
                              label: folderLabel(folderLabelType),
                              onPressed: doNothing,
                            )
                          : EzTextButton(
                              text: folderLabel(folderLabelType),
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

                              setModal(() {});
                            },
                          ),
                        ],
                      ),
                      ezSpacer,

                      // Show icon
                      EzSwitchPair(
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
                      ezSeparator,
                    ],
                  ),
                );
              },
            ),
            icon: Icon(PlatformIcons(context).edit),
            label: 'Folder apps',
          ),
          ezSeparator,
        ],
        includeIconSize: false,
        includeScroll: false,
        onButtonOpacityChanged: (double value) =>
            setState(() => buttonOpacity = value),
        onButtonOutlineOpacityChanged: (double value) =>
            setState(() => outlineOpacity = value),
        includeBackgroundImage: false,
        themedSettingsPostpend: <Widget>[
          // Wallpaper //

          if (EzConfig.get(isDark ? darkUseOSKey : lightUseOSKey) ==
              false) ...<Widget>[
            ezSpacer,
            EzScrollView(
              scrollDirection: Axis.horizontal,
              startCentered: true,
              mainAxisSize: MainAxisSize.min,
              child: isDark
                  ? EzImageSetting(
                      key: UniqueKey(),
                      configKey: darkBackgroundImageKey,
                      label: 'Wallpaper',
                      updateTheme: Brightness.dark,
                      style: ebStyle,
                    )
                  : EzImageSetting(
                      key: UniqueKey(),
                      configKey: lightBackgroundImageKey,
                      label: 'Wallpaper',
                      updateTheme: Brightness.light,
                      style: ebStyle,
                    ),
            ),
          ],

          // Use OS
          ezSpacer,
          EzSwitchPair(
            key: ValueKey<String>('use_os_$redraw'),
            text: 'Use System Wallpaper',
            valueKey: isDark ? darkUseOSKey : lightUseOSKey,
            onChangedCallback: (bool? choice) {
              if (choice == null) return;
              setState(() {});
            },
            activeTrackColor: switchSurface,
            inactiveTrackColor: switchSurface,
            trackOutlineColor: switchOutline,
          ),
        ],
        darkThemeResetKeys: <String>{darkUseOSKey},
        lightThemeResetKeys: <String>{darkUseOSKey},
        onReset: drawState,
      ),
      fabs: <Widget>[ezSpacer, EzBackFAB(context)],
    );
  }
}
