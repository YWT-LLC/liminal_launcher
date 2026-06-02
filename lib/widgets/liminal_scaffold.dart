/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalScaffold extends StatelessWidget {
  /// [Scaffold.body] passthrough
  final Widget body;

  /// [FloatingActionButton]s to add on top of the [EzUpdaterFAB]
  /// BYO spacing widgets
  final List<Widget>? fabs;

  /// For [EzConfig.backFABs]
  final bool home;

  /// Standardized [Scaffold] for all screens
  const LiminalScaffold(
    this.body, {
    super.key,
    this.fabs,
    this.home = false,
  });

  @override
  Widget build(BuildContext context) => EzAdaptiveParent(
        small: EzScaffold(
          body: EzScreen(body, safeArea: true),
          backgroundColor: Colors.transparent,
          fabs: <Widget>[
            updater,
            if (fabs != null) ...fabs!,
            ...EzConfig.backFABs(home),
          ],
        ),
      );
}
