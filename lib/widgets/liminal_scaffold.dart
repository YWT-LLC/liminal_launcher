/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalScaffold extends StatefulWidget {
  /// [Scaffold.body] passthrough
  final Widget body;

  /// [FloatingActionButton]s, BYO spacers (leading too)
  /// [updater] is always included
  final List<Widget>? fabs;

  /// Standardized [Scaffold] for all of the EFUI example app's screens
  const LiminalScaffold(this.body, {super.key, this.fabs});

  @override
  State<LiminalScaffold> createState() => _LiminalScaffoldState();
}

class _LiminalScaffoldState extends State<LiminalScaffold> {
  @override
  Widget build(BuildContext context) => EzAdaptiveParent(
        small: Scaffold(
          backgroundColor: Colors.transparent,
          body: EzScreen(SafeArea(child: widget.body)),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              updater,
              if (widget.fabs != null) ...widget.fabs!,
            ],
          ),
          floatingActionButtonLocation: EzConfig.get(isLeftyKey)
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
          resizeToAvoidBottomInset: false,
        ),
      );
}
