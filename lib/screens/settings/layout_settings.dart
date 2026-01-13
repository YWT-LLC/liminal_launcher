/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LayoutSettingsScreen extends StatefulWidget {
  const LayoutSettingsScreen({super.key});

  @override
  State<LayoutSettingsScreen> createState() => _LayoutSettingsScreenState();
}

class _LayoutSettingsScreenState extends State<LayoutSettingsScreen> {
  // Gather the fixed theme data //

  // Define custom Widgets //

  static const List<ButtonSegment<ListAlignment>> alignmentSegments =
      <ButtonSegment<ListAlignment>>[
    ButtonSegment<ListAlignment>(
      value: ListAlignment.start,
      label: Text('Start', textAlign: TextAlign.center),
    ),
    ButtonSegment<ListAlignment>(
      value: ListAlignment.center,
      label: Text('Center', textAlign: TextAlign.center),
    ),
    ButtonSegment<ListAlignment>(
      value: ListAlignment.end,
      label: Text('End', textAlign: TextAlign.center),
    ),
  ];
  // Return the build //

  @override
  Widget build(BuildContext context) => LiminalScaffold(
        EzLayoutSettings(
          beforeLayout: <Widget>[
            const EzDominantHandSwitch(),
            EzConfig.layout.separator,
          ],
          afterLayout: <Widget>[
            EzSpacer(space: EzConfig.spacing * 1.25),
            EzDivider(height: EzConfig.margin),
            EzLink(
              EzConfig.l10n.gEditingTheme(isDarkTheme(context)
                  ? EzConfig.l10n.gDark.toLowerCase()
                  : EzConfig.l10n.gLight.toLowerCase()),
              onTap: () => AppSettings.openAppSettings(
                type: AppSettingsType.display,
                asAnotherTask: true,
              ),
              hint: EzConfig.l10n.gEditingThemeHint,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            EzSpacer(space: EzConfig.spacing * 1.25),

            // Home list align
            EzElevatedIconButton(
              onPressed: () => ezModal(
                context: context,
                builder: (_) => EzScrollView(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _AlignmentSelectors(
                      home: true,
                      segments: alignmentSegments,
                    ),
                    EzConfig.layout.separator,
                  ],
                ),
              ),
              label: 'Home alignment',
              icon: Icon(PlatformIcons(context).home),
            ),
            EzConfig.layout.spacer,

            // App list align
            EzElevatedIconButton(
              onPressed: () => ezModal(
                context: context,
                builder: (_) => EzScrollView(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _AlignmentSelectors(
                      home: false,
                      segments: alignmentSegments,
                    ),
                    EzConfig.layout.separator,
                  ],
                ),
              ),
              label: 'App list(s) alignment',
              icon: const Icon(Icons.list),
            ),
          ],
          resetSpacer: EzConfig.layout.divider,
          extraSaveKeys: extraSaveKeys,
          appName: appName,
          androidPackage: androidPackage,
        ),
        fabs: settingsFABs(context),
      );
}

class _AlignmentSelectors extends StatefulWidget {
  final bool home;
  final List<ButtonSegment<ListAlignment>> segments;

  const _AlignmentSelectors({
    required this.home,
    required this.segments,
  });

  @override
  State<_AlignmentSelectors> createState() => _AlignmentSelectorsState();
}

class _AlignmentSelectorsState extends State<_AlignmentSelectors> {
  // Gather the fixed theme data //

  final double sizeMod = 0.333;

  // Define custom functions //

  Alignment merge({
    required ListAlignment hAlign,
    required ListAlignment vAlign,
  }) {
    switch (hAlign) {
      case ListAlignment.start:
        switch (vAlign) {
          case ListAlignment.start:
            return Alignment.topLeft;
          case ListAlignment.center:
            return Alignment.centerLeft;
          case ListAlignment.end:
            return Alignment.bottomLeft;
        }
      case ListAlignment.center:
        switch (vAlign) {
          case ListAlignment.start:
            return Alignment.topCenter;
          case ListAlignment.center:
            return Alignment.center;
          case ListAlignment.end:
            return Alignment.bottomCenter;
        }
      case ListAlignment.end:
        switch (vAlign) {
          case ListAlignment.start:
            return Alignment.topRight;
          case ListAlignment.center:
            return Alignment.centerRight;
          case ListAlignment.end:
            return Alignment.bottomRight;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    final double padding = EzConfig.padding;
    final double iconSize = EzConfig.iconSize;

    final bool isDark = isDarkTheme(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define the build data //

    final String hConfigKey = widget.home
        ? isDark
            ? darkHomeHAlignKey
            : lightHomeHAlignKey
        : isDark
            ? darkListHAlignKey
            : lightListHAlignKey;
    final String vConfigKey = widget.home
        ? isDark
            ? darkHomeVAlignKey
            : lightHomeVAlignKey
        : isDark
            ? darkListVAlignKey
            : lightListVAlignKey;

    ListAlignment hAlign =
        ListAlignmentConfig.fromValue(EzConfig.get(hConfigKey));

    ListAlignment vAlign =
        ListAlignmentConfig.fromValue(EzConfig.get(vConfigKey));

    final String? backgroundImagePath =
        EzConfig.get(isDark ? darkBackgroundImageKey : lightBackgroundImageKey);

    final BoxFit? backgroundImageFit = ezFitFromName(isDark
        ? EzConfig.get('$darkBackgroundImageKey$boxFitSuffix')
        : EzConfig.get('$lightBackgroundImageKey$boxFitSuffix'));

    // Return the build //

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Preview
        Container(
          color: colorScheme.onSurface,
          height: heightOf(context) * sizeMod,
          width: widthOf(context) * sizeMod,
          child: Stack(children: <Widget>[
            // Background
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                image: (backgroundImagePath == null ||
                        backgroundImagePath == noImageValue)
                    ? null
                    : DecorationImage(
                        image: ezImageProvider(backgroundImagePath),
                        fit: backgroundImageFit,
                      ),
              ),
              margin: EdgeInsets.all(EzConfig.margin * sizeMod),
            ),

            // Aligned circular icon
            Align(
              alignment: merge(hAlign: hAlign, vAlign: vAlign),
              child: ClipOval(
                child: Image.asset(
                  appIconPath,
                  semanticLabel:
                      'Liminal Launcher icon used for alignment preview',
                  width: iconSize + padding,
                  height: iconSize + padding,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
        ),
        EzConfig.layout.separator,

        // Controls
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            // Horizontal
            SegmentedButton<ListAlignment>(
              segments: widget.segments,
              selected: <ListAlignment>{hAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(hConfigKey, selected.configValue);
                setState(() => hAlign = selected);
              },
            ),
            EzConfig.layout.spacer,

            // Vertical
            SegmentedButton<ListAlignment>(
              segments: widget.segments,
              direction: Axis.vertical,
              selected: <ListAlignment>{vAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(vConfigKey, selected.configValue);
                setState(() => vAlign = selected);
              },
            ),
          ],
        ),
      ],
    );
  }
}
