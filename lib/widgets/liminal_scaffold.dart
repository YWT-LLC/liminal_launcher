/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../utils/consts.dart';
import 'package:efui_bios/efui_bios.dart';

import 'package:shake/shake.dart';
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
  ShakeDetector? detector;

  @override
  void initState() {
    super.initState();
    if (EzConfig.get(shakeForFeedbackKey)) startDetector();
  }

  void startDetector() {
    detector?.stopListening();
    detector = ShakeDetector.autoStart(
      onPhoneShake: (_) => ezFeedback(
        parentContext: context,
        l10n: ezL10n(context),
        supportEmail: empathSupport,
        appName: appName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (EzConfig.get(shakeForFeedbackKey)) {
      ShakeDetector.autoStart(
        onPhoneShake: (_) => ezFeedback(
          parentContext: context,
          l10n: ezL10n(context),
          supportEmail: empathSupport,
          appName: appName,
        ),
      );
    }

    return EzAdaptiveScaffold(
      small: Scaffold(
        body: widget.body,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[updater, if (widget.fabs != null) ...widget.fabs!],
        ),
        floatingActionButtonLocation: EzConfig.get(isLeftyKey)
            ? FloatingActionButtonLocation.startFloat
            : FloatingActionButtonLocation.endFloat,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }
}
