import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

const List<ButtonSegment<ListAlignment>> alignmentSegments =
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

class AlignmentSelectors extends StatefulWidget {
  const AlignmentSelectors({super.key});

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

    ListAlignment horizAlign = hAlign;
    ListAlignment vertAlign = vAlign;

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
                image: (EzConfig.backgroundImagePath == noImageValue)
                    ? null
                    : EzConfig.backgroundImage,
              ),
              margin: EdgeInsets.all(EzConfig.marginVal * sizeMod),
            ),

            // Aligned circular icon
            Align(
              alignment: merge(horizAlign: horizAlign, vertAlign: vertAlign),
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
              segments: alignmentSegments,
              selected: <ListAlignment>{horizAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                if (EzConfig.updateBoth || EzConfig.isDark) {
                  await EzConfig.setString(
                    darkHorizontalAlignKey,
                    selected.value,
                  );
                }
                if (EzConfig.updateBoth || !EzConfig.isDark) {
                  await EzConfig.setString(
                    lightHorizontalAlignKey,
                    selected.value,
                  );
                }

                setState(() => horizAlign = selected);
              },
            ),
            EzConfig.spacer,

            // Vertical
            SegmentedButton<ListAlignment>(
              segments: alignmentSegments,
              direction: Axis.vertical,
              selected: <ListAlignment>{vertAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                if (EzConfig.updateBoth || EzConfig.isDark) {
                  await EzConfig.setString(
                    darkVerticalAlignKey,
                    selected.value,
                  );
                }
                if (EzConfig.updateBoth || !EzConfig.isDark) {
                  await EzConfig.setString(
                    lightVerticalAlignKey,
                    selected.value,
                  );
                }

                setState(() => vertAlign = selected);
              },
            ),
          ],
        ),
      ],
    );
  }
}
