/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'export.dart';

import 'package:flutter/material.dart';
import 'package:open_ui/open_ui.dart';

class LiminalScaffold extends StatelessWidget {
  final EzCP config;
  final Widget body;
  final List<Widget>? fabs;
  final bool isHome;

  const LiminalScaffold(
    this.config, {
    super.key,
    required this.body,
    this.fabs,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) => EzAdaptiveParent(
        small: EzScaffold(
          config,
          body: EzScreen(
            config,
            margin: EdgeInsets.only(
              left: config.marginVal,
              right: config.marginVal,
              top: safeTop(context) + config.marginVal,
              bottom: config.marginVal,
            ),
            child: body,
          ),
          backgroundColor: Colors.transparent,
          fabs: <Widget>[updater(config), if (fabs != null) ...fabs!, ...config.backFABs(isHome)],
        ),
      );
}
