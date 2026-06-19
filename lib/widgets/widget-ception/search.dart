/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: short and long press for everything
// TODO: have a tool tipper on the add screen that describes what it does ahead of time
// TODO: at least two, preferably three sizes for everything

class SearchWidget extends StatelessWidget {
  final EzCP config;
  late final WidgetSize _size;
  final AppState state;

  SearchWidget(this.config, WidgetSize size, this.state, {super.key}) {
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
  }

  @override
  Widget build(BuildContext context) => switch (_size) {
        WidgetSize.system => const SizedBox.shrink(), // override above
        WidgetSize.button || _ => EzIconButton(
            config,
            icon: EzIcon(config, Icons.search),
            onPressed: () => launchUrl(Uri.parse('https://duckduckgo.com/')),
          ),
      };
}
