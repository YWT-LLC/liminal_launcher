/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LauncherSettingsScreen extends StatefulWidget {
  LauncherSettingsScreen() : super(key: ValueKey<int>(EzConfig.seed));

  @override
  State<LauncherSettingsScreen> createState() => _LauncherSettingsScreenState();
}

class _LauncherSettingsScreenState extends State<LauncherSettingsScreen> {
  // Define the build data //

  late final AppInfoProvider appProvider =
      Provider.of<AppInfoProvider>(context);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    const EzSpacer ezSpacer = EzSpacer();

    return LiminalScaffold(
      EzScrollView(children: <Widget>[
        EzHeader(),

        // Swipe selectors
        SwipeSelector(left: true, appProvider: appProvider),
        ezSpacer,
        SwipeSelector(left: false, appProvider: appProvider),
        EzConfig.divider,

        // Hide status bar
        const EzSwitchPair(
          text: 'Hide status bar',
          valueKey: hideStatusKey,
        ),
        ezSpacer,

        // Auto add to home
        const EzSwitchPair(
          text: 'Add new apps to home',
          valueKey: autoAddToHomeKey,
        ),
        ezSpacer,

        // Auto search
        const EzSwitchPair(
          text: 'Auto search',
          valueKey: autoSearchKey,
        ),
        ezSpacer,

        // Auth to edit
        const EzSwitchPair(
          text: 'Auth to edit',
          valueKey: authToEditKey,
        ),
        ezSpacer,

        // Auth for hidden
        const EzSwitchPair(
          text: 'Auth for hidden',
          valueKey: authForHiddenKey,
        ),
        EzConfig.separator,
      ]),
      fabs: settingsFABs(context),
    );
  }
}


// EzConfigRandomizer(
//   onConfirm: () async {
//     final bool isDark = isDarkTheme(context);

//     late final String homeTimeKey;
//     late final String homeDateKey;
//     late final String listIconKey;
//     late final String listLabelTypeKey;
//     late final String folderIconKey;
//     late final String folderLabelTypeKey;
//     late final String homeHAlignKey;
//     late final String homeVAlignKey;
//     late final String listHAlignKey;
//     late final String listVAlignKey;

//     if (isDark) {
//       homeTimeKey = darkHomeTimeKey;
//       homeDateKey = darkHomeDateKey;
//       listIconKey = darkListIconKey;
//       listLabelTypeKey = darkListLabelTypeKey;
//       folderIconKey = darkFolderIconKey;
//       folderLabelTypeKey = darkFolderLabelTypeKey;
//       homeHAlignKey = darkHomeHAlignKey;
//       homeVAlignKey = darkHomeVAlignKey;
//       listHAlignKey = darkListHAlignKey;
//       listVAlignKey = darkListVAlignKey;
//     } else {
//       homeTimeKey = lightHomeTimeKey;
//       homeDateKey = lightHomeDateKey;
//       listIconKey = lightListIconKey;
//       listLabelTypeKey = lightListLabelTypeKey;
//       folderIconKey = lightFolderIconKey;
//       folderLabelTypeKey = lightFolderLabelTypeKey;
//       homeHAlignKey = lightHomeHAlignKey;
//       homeVAlignKey = lightHomeVAlignKey;
//       listHAlignKey = lightListHAlignKey;
//       listVAlignKey = lightListVAlignKey;
//     }

//     await EzConfig.randomize(shiny: false);
//     final Random random = Random();

//     // Design
//     await EzConfig.setBool(homeTimeKey, random.nextBool());
//     await EzConfig.setBool(homeDateKey, random.nextBool());

//     await EzConfig.setBool(listIconKey, random.nextBool());
//     final int listLabelRand = random.nextInt(4);
//     late final String listLabelValue;
//     switch (listLabelRand) {
//       case 0:
//         listLabelValue = LabelType.none.configValue;
//         break;
//       case 1:
//         listLabelValue = LabelType.initials.configValue;
//         break;
//       case 3:
//         listLabelValue = LabelType.wingding.configValue;
//         break;
//       default:
//         listLabelValue = LabelType.full.configValue;
//         break;
//     }
//     await EzConfig.setString(listLabelTypeKey, listLabelValue);

//     await EzConfig.setBool(folderIconKey, random.nextBool());
//     final int folderLabelRand = random.nextInt(3);
//     late final String folderLabelValue;
//     switch (folderLabelRand) {
//       case 0:
//         folderLabelValue = LabelType.none.configValue;
//         break;
//       case 1:
//         folderLabelValue = LabelType.initials.configValue;
//         break;
//       case 3:
//         folderLabelValue = LabelType.wingding.configValue;
//       default:
//         folderLabelValue = LabelType.full.configValue;
//         break;
//     }
//     await EzConfig.setString(folderLabelTypeKey, folderLabelValue);

//     // Layout
//     final int homeHAlignRand = random.nextInt(3);
//     late final String homeHAlignValue;
//     switch (homeHAlignRand) {
//       case 0:
//         homeHAlignValue = ListAlignment.start.configValue;
//         break;
//       case 2:
//         homeHAlignValue = ListAlignment.end.configValue;
//         break;
//       default:
//         homeHAlignValue = ListAlignment.center.configValue;
//         break;
//     }
//     await EzConfig.setString(homeHAlignKey, homeHAlignValue);

//     final int homeVAlignRand = random.nextInt(3);
//     late final String homeVAlignValue;
//     switch (homeVAlignRand) {
//       case 0:
//         homeVAlignValue = ListAlignment.start.configValue;
//         break;
//       case 2:
//         homeVAlignValue = ListAlignment.end.configValue;
//         break;
//       default:
//         homeVAlignValue = ListAlignment.center.configValue;
//         break;
//     }
//     await EzConfig.setString(homeVAlignKey, homeVAlignValue);

//     final int listHAlignRand = random.nextInt(3);
//     late final String listHAlignValue;
//     switch (listHAlignRand) {
//       case 0:
//         listHAlignValue = ListAlignment.start.configValue;
//         break;
//       case 2:
//         listHAlignValue = ListAlignment.end.configValue;
//         break;
//       default:
//         listHAlignValue = ListAlignment.center.configValue;
//         break;
//     }
//     await EzConfig.setString(listHAlignKey, listHAlignValue);

//     final int listVAlignRand = random.nextInt(3);
//     late final String listVAlignValue;
//     switch (listVAlignRand) {
//       case 0:
//         listVAlignValue = ListAlignment.start.configValue;
//         break;
//       case 2:
//         listVAlignValue = ListAlignment.end.configValue;
//         break;
//       default:
//         listVAlignValue = ListAlignment.center.configValue;
//         break;
//     }
//     await EzConfig.setString(listVAlignKey, listVAlignValue);
//   },
//   appName: appName,
//   androidPackage: androidPackage,
//   ),