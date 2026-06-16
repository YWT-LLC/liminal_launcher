/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LimSpacer extends StatelessWidget {
  final EzCP config;
  final double height;
  final double width;
  final AppState state;

  const LimSpacer(
    this.config, {
    super.key,
    required this.height,
    required this.width,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => switch (state) {
        AppState.standard => SizedBox(height: height, width: width),
        AppState.singleEdit => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              border: Border.all(
                color: config.colors.secondary,
                width: config.borderWidth,
              ),
              borderRadius: EzButtonShape.roundRect.radius,
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: GestureDetector(
                onTap: doNothing, // todo
                child: EzIcon(config, Icons.delete),
              ),
            ),
          ),
        AppState.groupEdit || AppState.verbose => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              border: Border.all(
                color: config.colors.primary,
                width: config.borderWidth,
              ),
              borderRadius: EzButtonShape.roundRect.radius,
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: GestureDetector(
                onTap: doNothing, // todo
                child: EzIcon(config, Icons.delete),
              ),
            ),
          ),
      };
}
