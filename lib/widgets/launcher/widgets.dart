/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class NowPlayingWidget extends StatelessWidget {
  final EzCP config;

  const NowPlayingWidget(this.config, {super.key});

  @override
  Widget build(BuildContext context) => EzIconButton(
        config,
        icon: EzIcon(config, Icons.headphones),
        onPressed: toggleMedia,
      );
}
