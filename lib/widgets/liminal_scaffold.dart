/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

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
              top: safeTop(context),
              bottom: config.marginVal,
            ),
            child: body,
          ),
          backgroundColor: Colors.transparent,
          fabs: <Widget>[
            EzUpdaterFAB(
              config,
              appVersion: '1.0.0',
              versionSource:
                  'https://raw.githubusercontent.com/YWT-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
              gPlay: 'https://play.google.com/store/apps/details?id=llc.ywt.liminal_launcher',
              github: 'https://github.com/YWT-LLC/liminal_launcher/releases',
            ),
            if (fabs != null) ...fabs!,
            ...config.backFABs(isHome),
          ],
        ),
      );
}
