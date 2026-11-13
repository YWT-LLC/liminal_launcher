/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:open_ui/open_ui.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'package:material_ui/material_ui.dart';

class LiminalScaffold extends StatelessWidget {
  final EzCP config;
  final Widget body;
  final List<Widget>? fabs;
  final bool isHome;
  final bool settingsA11;

  const LiminalScaffold(
    this.config, {
    super.key,
    required this.body,
    this.fabs,
    this.isHome = false,
    this.settingsA11 = false,
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
            decoration: config.boxDeco(fill: const EzSwitchColor(color: Colors.transparent)),
            child: body,
          ),
          footer: EzFooter(
            config,
            quiet: isHome,
            a11howPath: settingsA11 ? ywt.openUIContributeA11 : ywt.liminalContributeA11,
          ),
          fabs: <Widget>[
            if (!isHome)
              EzUpdaterFAB(
                config,
                appVersion: '1.1.1',
                versionSource:
                    'https://raw.githubusercontent.com/YWT-LLC/liminal_launcher/refs/heads/main/APP_VERSION',
                gPlay: ywt.liminalGPlay,
                github: ywt.liminalReleases,
              ),
            if (fabs != null) ...fabs!,
            ...config.backFABs(isHome: isHome),
          ],
        ),
      );
}
