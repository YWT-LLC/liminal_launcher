import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AlignmentSelectors extends StatefulWidget {
  final bool home;
  final List<ButtonSegment<ListAlignment>> segments;

  const AlignmentSelectors({
    super.key,
    required this.home,
    required this.segments,
  });

  @override
  State<AlignmentSelectors> createState() => _AlignmentSelectorsState();
}

class _AlignmentSelectorsState extends State<AlignmentSelectors> {
  // Define custom functions //

  Alignment merge({
    required ListAlignment horizAlign,
    required ListAlignment vertAlign,
  }) {
    switch (horizAlign) {
      case ListAlignment.start:
        switch (vertAlign) {
          case ListAlignment.start:
            return Alignment.topLeft;
          case ListAlignment.center:
            return Alignment.centerLeft;
          case ListAlignment.end:
            return Alignment.bottomLeft;
        }
      case ListAlignment.center:
        switch (vertAlign) {
          case ListAlignment.start:
            return Alignment.topCenter;
          case ListAlignment.center:
            return Alignment.center;
          case ListAlignment.end:
            return Alignment.bottomCenter;
        }
      case ListAlignment.end:
        switch (vertAlign) {
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
    // Define the build data //

    ListAlignment horizAlign = ListAlignmentConfig.lookup(EzConfig.get(
        EzConfig.isDark ? darkHorizontalAlignKey : lightHorizontalAlignKey));
    ListAlignment vertAlign = ListAlignmentConfig.lookup(EzConfig.get(
        EzConfig.isDark ? darkVerticalAlignKey : lightVerticalAlignKey));

    final String? backgroundImagePath = EzConfig.get(
        EzConfig.isDark ? darkBackgroundImageKey : lightBackgroundImageKey);

    final BoxFit? backgroundImageFit = boxFitLookup[EzConfig.isDark
        ? EzConfig.get('$darkBackgroundImageKey$boxFitSuffix')
        : EzConfig.get('$lightBackgroundImageKey$boxFitSuffix')];

    // Return the build //

    const double sizeMod = 0.333;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Preview
        Container(
          color: EzConfig.colors.onSurface,
          height: heightOf(context) * sizeMod,
          width: widthOf(context) * sizeMod,
          child: Stack(children: <Widget>[
            // Background
            Container(
              decoration: BoxDecoration(
                color: EzConfig.colors.surface,
                image: (backgroundImagePath == null ||
                        backgroundImagePath == noImageValue)
                    ? null
                    : DecorationImage(
                        image: ezImageProvider(backgroundImagePath),
                        fit: backgroundImageFit,
                      ),
              ),
              margin: EdgeInsets.all(EzConfig.marginVal * sizeMod),
            ),

            // Aligned circular icon
            Align(
              alignment: merge(
                horizAlign: horizAlign,
                vertAlign: vertAlign,
              ),
              child: ClipOval(
                child: Image.asset(
                  appIconPath,
                  semanticLabel:
                      'Liminal Launcher icon used for alignment preview',
                  width: EzConfig.iconSize + EzConfig.padding,
                  height: EzConfig.iconSize + EzConfig.padding,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
        ),
        EzConfig.separator,

        // Controls
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            // Horizontal
            SegmentedButton<ListAlignment>(
              segments: widget.segments,
              selected: <ListAlignment>{horizAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(hConfigKey, selected.configValue);
                setState(() => horizAlign = selected);
              },
            ),
            EzConfig.spacer,

            // Vertical
            SegmentedButton<ListAlignment>(
              segments: widget.segments,
              direction: Axis.vertical,
              selected: <ListAlignment>{vertAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(vConfigKey, selected.configValue);
                setState(() => vertAlign = selected);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// TODO: add rebuild and shiz
