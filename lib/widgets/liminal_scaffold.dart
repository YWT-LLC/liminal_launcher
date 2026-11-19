/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/liminal_cache.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'package:open_ui/open_ui.dart';
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
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: wallpaper(config),
            height: double.infinity,
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.only(
                left: config.marginVal,
                right: config.marginVal,
                top: safeTop(context),
                bottom: config.marginVal,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Material(type: MaterialType.transparency, child: body),
            ),
          ),
          footer: settingsA11 ? EzFooter(config, a11howPath: ywt.openUIContributeA11) : null,
          fabs: <Widget>[
            if (!isHome)
              EzUpdaterFAB(
                config,
                appVersion: '1.1.3',
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
