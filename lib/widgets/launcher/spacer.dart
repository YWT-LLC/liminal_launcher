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

  LimSpacer(
    this.config, {
    required this.height,
    required this.width,
    required this.state,
  }) : super(key: ValueKey<AppState>(state));

  @override
  Widget build(BuildContext context) => switch (state) {
        AppState.standard => SizedBox(height: height, width: width),
        AppState.singleEdit => SizedBox(height: height, width: width), // TODO: con delete
        AppState.groupEdit ||
        AppState.verbose =>
          SizedBox(height: height, width: width), // TODO con delete, and resize corner icons
      };
}
