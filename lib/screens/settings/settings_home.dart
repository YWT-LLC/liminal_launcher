/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  // Gather the fixed theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  final bool isLefty = EzConfig.get(isLeftyKey);

  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late final AppInfoProvider listener = Provider.of<AppInfoProvider>(context);
  late final AppInfoProvider editor =
      Provider.of<AppInfoProvider>(context, listen: false);

  bool resetAll = false;

  // Define custom functions //

  Future<dynamic> showTips() => showPlatformDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Tips', textAlign: TextAlign.center),
          content: Text('&& tricks', textAlign: TextAlign.center),
        ),
      );

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        Stack(
          // Core //
          children: <Widget>[
            // Restart reminder
            GestureDetector(
              onLongPress: showTips,
              child: const EzWarning(
                  'Appearance settings take full effect on restart.\n\nHave fun!'),
            ),

            // Tips
            Positioned(
              top: 0,
              right: isLefty ? null : 0,
              left: isLefty ? 0 : null,
              child: IconButton(
                icon: EzIcon(Icons.help_outline),
                onPressed: showTips,
              ),
            ),

            // Updater
            Positioned(
              top: 0,
              left: isLefty ? null : 0,
              right: isLefty ? 0 : null,
              child: updater,
            ),
          ],
        ),
        separator,

        // Left swipe
        _SwipeSelector(
          isLeft: true,
          listener: listener,
          textTheme: textTheme,
        ),
        spacer,

        // Right swipe
        _SwipeSelector(
          isLeft: false,
          listener: listener,
          textTheme: textTheme,
        ),
        separator,

        // Auto search
        const EzSwitchPair(
          text: 'Auto search',
          valueKey: autoSearchKey,
        ),
        spacer,

        // Auto search
        const EzSwitchPair(
          text: 'Auth to edit',
          valueKey: authToEditKey,
        ),
        spacer,

        // Auto add to home
        const EzSwitchPair(
          text: 'Add new apps to home',
          valueKey: autoAddToHomeKey,
        ),
        divider,

        // Navigation //

        // GoTo color settings
        EzElevatedIconButton(
          onPressed: () => context.goNamed(colorSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.csPageTitle,
        ),
        spacer,

        // GoTo design settings
        EzElevatedIconButton(
          onPressed: () => context.goNamed(designSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: 'Design settings',
        ),
        spacer,

        // GoTo layout settings
        EzElevatedIconButton(
          onPressed: () => context.goNamed(layoutSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.lsPageTitle,
        ),
        spacer,

        // GoTo text settings
        EzElevatedIconButton(
          onPressed: () => context.goNamed(textSettingsPath),
          icon: EzIcon(Icons.navigate_next),
          label: el10n.tsPageTitle,
        ),
        spacer,

        // Batch //

        // Randomize
        EzConfigRandomizer(
          dialogContent: 'Only affects appearance settings\n${el10n.gUndoWarn}',
          onConfirm: () async {
            await EzConfig.randomize(isDarkTheme(context), shiny: false);

            final Random random = Random();

            // Layout
            final int homeHAlignRand = random.nextInt(3);
            late final String homeHAlignValue;
            switch (homeHAlignRand) {
              case 0:
                homeHAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                homeHAlignValue = ListAlignment.end.configValue;
                break;
              default:
                homeHAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(homeHAlignKey, homeHAlignValue);

            final int homeVAlignRand = random.nextInt(3);
            late final String homeVAlignValue;
            switch (homeVAlignRand) {
              case 0:
                homeVAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                homeVAlignValue = ListAlignment.end.configValue;
                break;
              default:
                homeVAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(homeVAlignKey, homeVAlignValue);

            final int listHAlignRand = random.nextInt(3);
            late final String listHAlignValue;
            switch (listHAlignRand) {
              case 0:
                listHAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                listHAlignValue = ListAlignment.end.configValue;
                break;
              default:
                listHAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(listHAlignKey, listHAlignValue);

            final int listVAlignRand = random.nextInt(3);
            late final String listVAlignValue;
            switch (listVAlignRand) {
              case 0:
                listVAlignValue = ListAlignment.start.configValue;
                break;
              case 2:
                listVAlignValue = ListAlignment.end.configValue;
                break;
              default:
                listVAlignValue = ListAlignment.center.configValue;
                break;
            }
            await EzConfig.setString(listVAlignKey, listVAlignValue);

            // Design
            await EzConfig.setBool(homeTimeKey, random.nextBool());
            await EzConfig.setBool(homeDateKey, random.nextBool());

            await EzConfig.setBool(listIconKey, random.nextBool());
            final int listLabelRand = random.nextInt(4);
            late final String listLabelValue;
            switch (listLabelRand) {
              case 0:
                listLabelValue = LabelType.none.configValue;
                break;
              case 1:
                listLabelValue = LabelType.initials.configValue;
                break;
              case 3:
                listLabelValue = LabelType.wingding.configValue;
                break;
              default:
                listLabelValue = LabelType.full.configValue;
                break;
            }
            await EzConfig.setString(listLabelTypeKey, listLabelValue);

            await EzConfig.setBool(folderIconKey, random.nextBool());
            final int folderLabelRand = random.nextInt(3);
            late final String folderLabelValue;
            switch (folderLabelRand) {
              case 0:
                folderLabelValue = LabelType.none.configValue;
                break;
              case 1:
                folderLabelValue = LabelType.initials.configValue;
                break;
              case 3:
                folderLabelValue = LabelType.wingding.configValue;
              default:
                folderLabelValue = LabelType.full.configValue;
                break;
            }
            await EzConfig.setString(folderLabelTypeKey, folderLabelValue);
          },
        ),
        spacer,

        // Reset
        EzElevatedIconButton(
          onPressed: () => showPlatformDialog(
            context: context,
            builder: (_) => StatefulBuilder(builder: (
              BuildContext dialogContext,
              StateSetter dialogState,
            ) {
              late final Set<String> skip = <String>{
                homeIDsKey,
                hiddenIDsKey,
                leftSwipeIDKey,
                rightSwipeIDKey,
                authToEditKey,
              };

              late final List<Widget> materialActions;
              late final List<Widget> cupertinoActions;

              (materialActions, cupertinoActions) = ezActionPairs(
                context: context,
                onConfirm: () async {
                  await EzConfig.reset(skip: resetAll ? <String>{} : skip);
                  if (resetAll) await editor.reset();

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                confirmIsDestructive: true,
                onDeny: () => Navigator.of(dialogContext).pop(),
              );

              return EzAlertDialog(
                key: ValueKey<bool>(resetAll),
                title: const Text(
                  'Reset all appearance settings?',
                  textAlign: TextAlign.center,
                ),
                contents: <Widget>[
                  EzSwitchPair(
                    text: 'Or, ALL settings',
                    value: resetAll,
                    onChanged: (bool? choice) {
                      resetAll = (choice == null) ? false : choice;
                      setState(() {});
                      dialogState(() {});
                    },
                  ),
                  spacer,
                  Text(
                    el10n.gUndoWarn,
                    textAlign: TextAlign.center,
                  ),
                ],
                materialActions: materialActions,
                cupertinoActions: cupertinoActions,
                needsClose: false,
              );
            }),
          ),
          icon: EzIcon(PlatformIcons(context).refresh),
          label: el10n.gResetAll,
        ),
        separator,
      ]),
      fabs: <Widget>[const EzSpacer(), EzBackFAB(context)],
    );
  }
}

class _SwipeSelector extends StatefulWidget {
  final bool isLeft;

  final AppInfoProvider listener;
  final TextTheme textTheme;

  const _SwipeSelector({
    required this.isLeft,
    required this.listener,
    required this.textTheme,
  });

  @override
  State<_SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<_SwipeSelector> {
  // Gather the fixed theme data //

  final EzSpacer rowMargin = EzMargin(vertical: false);

  // Define the build data //

  final bool showIcon = EzConfig.get(listIconKey);
  final LabelType labelType =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));

  late final String leftLabel = 'Left package';
  late final String rightLabel = 'Right package';

  late final String? leftID = EzConfig.get(leftSwipeIDKey);
  late final String? rightID = EzConfig.get(rightSwipeIDKey);

  late AppInfo leftApp = (leftID == null || leftID!.isEmpty)
      ? nullApp
      : widget.listener.appMap[leftID!] ?? nullApp;
  late AppInfo rightApp = (rightID == null || rightID!.isEmpty)
      ? nullApp
      : widget.listener.appMap[rightID!] ?? nullApp;

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: widget.isLeft
          ? <Widget>[
              EzText(leftLabel, style: widget.textTheme.bodyLarge),
              rowMargin,
              TileButton(
                app: leftApp,
                type: labelType,
                showIcon: showIcon,
                onPressed: () => context.goNamed(
                  appListPath,
                  extra: listData(
                    listCheck: (String id) => true,
                    onSelected: (String id) async {
                      final AppInfo? app = widget.listener.appMap[id];
                      if (app == null || app == leftApp) return;

                      await EzConfig.setString(leftSwipeIDKey, id);
                      setState(() => leftApp = app);
                    },
                    refresh: () => setState(() {}),
                    icon: Text(
                      'Selecting left swipe',
                      style: textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            ]
          : <Widget>[
              EzText(rightLabel, style: widget.textTheme.bodyLarge),
              rowMargin,
              TileButton(
                app: rightApp,
                type: labelType,
                showIcon: showIcon,
                onPressed: () => context.goNamed(
                  appListPath,
                  extra: listData(
                    listCheck: (String id) => true,
                    onSelected: (String id) async {
                      final AppInfo? app = widget.listener.appMap[id];
                      if (app == null || app == rightApp) return;

                      await EzConfig.setString(rightSwipeIDKey, id);
                      setState(() => rightApp = app);
                    },
                    refresh: () => setState(() {}),
                    icon: Text(
                      'Selecting right swipe',
                      style: textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
