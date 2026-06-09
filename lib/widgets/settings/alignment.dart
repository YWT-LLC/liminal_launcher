import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AlignmentSelectors extends StatefulWidget {
  final EzCP config;

  const AlignmentSelectors(this.config, {super.key});

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

  late ListAlignment h = hAlign(widget.config);
  late ListAlignment v = vAlign(widget.config);

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
          color: widget.config.colors.onSurface,
          height: heightOf(context) * _sizeMod,
          width: widthOf(context) * _sizeMod,
          child: Stack(children: <Widget>[
            // Background
            Container(
              decoration: BoxDecoration(
                color: widget.config.colors.surface,
                image: (widget.config.backgroundImagePath == noImageValue)
                    ? null
                    : widget.config.backgroundImage,
              ),
              margin: EdgeInsets.all(widget.config.marginVal * _sizeMod),
            ),

            // Aligned circular icon
            Align(
              alignment: merge(),
              child: ClipOval(
                child: Image.asset(
                  appIconPath,
                  semanticLabel: 'Liminal Launcher icon used for alignment preview',
                  width: appIconSize(widget.config),
                  height: appIconSize(widget.config),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
        ),
        widget.config.separator,

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

              if (EzCM.updateBoth || widget.config.isDark) {
                await EzCM.setString(darkHorizontalAlignKey, selected.value);
              }
              if (EzCM.updateBoth || !widget.config.isDark) {
                await EzCM.setString(lightHorizontalAlignKey, selected.value);
              }

              setState(() => h = selected);
            },
          ),
          widget.config.spacer,

          // Vertical
          SegmentedButton<ListAlignment>(
            segments: alignmentSegments,
            direction: Axis.vertical,
            selected: <ListAlignment>{v},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ListAlignment>? choice) async {
              if (choice?.first == null) return;
              final ListAlignment selected = choice!.first;

              if (EzCM.updateBoth || widget.config.isDark) {
                await EzCM.setString(darkVerticalAlignKey, selected.value);
              }
              if (EzCM.updateBoth || !widget.config.isDark) {
                await EzCM.setString(lightVerticalAlignKey, selected.value);
              }

              setState(() => v = selected);
            },
          ),
        ]),
      ]);
}
