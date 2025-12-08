/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
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

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  late final EFUILang el10n = ezL10n(context);

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

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    final bool isDark = isDarkTheme(context);

    // Return the build //

    return LiminalScaffold(
      EzLayoutSettings(
        beforeLayout: const <Widget>[
          EzDominantHandSwitch(),
          ezSeparator,
        ],
        afterLayout: <Widget>[
          EzSpacer(space: spacing * 1.25),
          EzDivider(height: margin),
          EzLink(
            el10n.gEditingTheme(isDark
                ? el10n.gDark.toLowerCase()
                : el10n.gLight.toLowerCase()),
            onTap: () => AppSettings.openAppSettings(
              type: AppSettingsType.display,
              asAnotherTask: true,
            ),
            hint: el10n.gEditingThemeHint,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          EzSpacer(space: spacing * 1.25),

          // Home list align
          EzElevatedIconButton(
            onPressed: () => ezModal(
              context: context,
              builder: (_) => const EzScrollView(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AlignmentSelectors(
                    home: true,
                    segments: alignmentSegments,
                  ),
                  ezSeparator,
                ],
              ),
            ),
            label: 'Home alignment',
            icon: Icon(PlatformIcons(context).home),
          ),
          ezSpacer,

          // App list align
          EzElevatedIconButton(
            onPressed: () => ezModal(
              context: context,
              builder: (_) => const EzScrollView(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AlignmentSelectors(
                    home: false,
                    segments: alignmentSegments,
                  ),
                  ezSeparator,
                ],
              ),
            ),
            label: 'App list(s) alignment',
            icon: const Icon(Icons.list),
          ),
        ],
        resetSpacer: ezDivider,
        extraSaveKeys: extraKeys,
        appName: appName,
        androidPackage: androidPackage,
      ),
      fabs: settingsFABs(context),
    );
  }
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

  final double padding = EzConfig.get(paddingKey);
  final double iconSize = EzConfig.get(iconSizeKey);

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
              margin: EdgeInsets.all(EzConfig.get(marginKey) * sizeMod),
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
        ezSeparator,

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
            ezSpacer,

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
