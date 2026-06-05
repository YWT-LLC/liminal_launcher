import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AlignmentSelectors extends StatefulWidget {
  const AlignmentSelectors({super.key});

  @override
  State<AlignmentSelectors> createState() => _AlignmentSelectorsState();
}

const double _sizeMod = 0.333;

const List<ButtonSegment<ListAlignment>> alignmentSegments = <ButtonSegment<ListAlignment>>[
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

class _AlignmentSelectorsState extends State<AlignmentSelectors> {
  // Define the build data //

  ListAlignment h = hAlign;
  ListAlignment v = vAlign;

  // Define custom functions //

  Alignment merge() => switch (h) {
        ListAlignment.start => switch (v) {
            ListAlignment.start => Alignment.topLeft,
            ListAlignment.center => Alignment.centerLeft,
            ListAlignment.end => Alignment.bottomLeft,
          },
        ListAlignment.center => switch (v) {
            ListAlignment.start => Alignment.topCenter,
            ListAlignment.center => Alignment.center,
            ListAlignment.end => Alignment.bottomCenter,
          },
        ListAlignment.end => switch (v) {
            ListAlignment.start => Alignment.topRight,
            ListAlignment.center => Alignment.centerRight,
            ListAlignment.end => Alignment.bottomRight,
          },
      };

  // Return the build //

  @override
  Widget build(BuildContext context) => EzCol(children: <Widget>[
        // Preview
        Container(
          color: EzConfig.colors.onSurface,
          height: heightOf(context) * _sizeMod,
          width: widthOf(context) * _sizeMod,
          child: Stack(children: <Widget>[
            // Background
            Container(
              decoration: BoxDecoration(
                color: EzConfig.colors.surface,
                image: (EzConfig.backgroundImagePath == noImageValue)
                    ? null
                    : EzConfig.backgroundImage,
              ),
              margin: EdgeInsets.all(EzConfig.marginVal * _sizeMod),
            ),

            // Aligned circular icon
            Align(
              alignment: merge(),
              child: ClipOval(
                child: Image.asset(
                  appIconPath,
                  semanticLabel: 'Liminal Launcher icon used for alignment preview',
                  width: appIconSize,
                  height: appIconSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
        ),
        EzConfig.separator,

        // Controls
        EzWrap(children: <Widget>[
          // Horizontal
          SegmentedButton<ListAlignment>(
            segments: alignmentSegments,
            selected: <ListAlignment>{h},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ListAlignment>? choice) async {
              if (choice?.first == null) return;
              final ListAlignment selected = choice!.first;

              if (EzConfig.updateBoth || EzConfig.isDark) {
                await EzConfig.setString(darkHorizontalAlignKey, selected.value);
              }
              if (EzConfig.updateBoth || !EzConfig.isDark) {
                await EzConfig.setString(lightHorizontalAlignKey, selected.value);
              }

              setState(() => h = selected);
            },
          ),
          EzConfig.spacer,

          // Vertical
          SegmentedButton<ListAlignment>(
            segments: alignmentSegments,
            direction: Axis.vertical,
            selected: <ListAlignment>{v},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ListAlignment>? choice) async {
              if (choice?.first == null) return;
              final ListAlignment selected = choice!.first;

              if (EzConfig.updateBoth || EzConfig.isDark) {
                await EzConfig.setString(darkVerticalAlignKey, selected.value);
              }
              if (EzConfig.updateBoth || !EzConfig.isDark) {
                await EzConfig.setString(lightVerticalAlignKey, selected.value);
              }

              setState(() => v = selected);
            },
          ),
        ]),
      ]);
}
