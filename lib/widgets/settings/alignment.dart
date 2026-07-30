/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

class AlignmentSelectors extends StatefulWidget {
  final EzCP config;

  const AlignmentSelectors(this.config, {super.key});

  @override
  State<AlignmentSelectors> createState() => _AlignmentSelectorsState();
}

// Define the build data //

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
  late ListAlignment h = horizontalAlign(widget.config);
  late ListAlignment v = verticalAlign(widget.config);

  // Return the build //

  @override
  Widget build(BuildContext context) => EzCol(
        children: <Widget>[
          // Preview
          Container(
            color: widget.config.colors.onSurface,
            height: heightOf(context) * _sizeMod,
            width: widthOf(context) * _sizeMod,
            child: Stack(
              children: <Widget>[
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
                  alignment: LAConfig.merge(h: h, v: v),
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
              ],
            ),
          ),
          widget.config.spacer,

          // Controls
          EzWrap(children: <Widget>[
            Padding(
              padding: EzInsets.wrap(widget.config.spacing),
              child: SegmentedButton<ListAlignment>(
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
            ),
            Padding(
              padding: EzInsets.wrap(widget.config.spacing),
              child: SegmentedButton<ListAlignment>(
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
            ),
          ]),
        ],
      );
}
