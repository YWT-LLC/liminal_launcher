/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';

class LimButt extends StatelessWidget {
  final bool folder;
  final Widget? icon;

  const LimButt({
    super.key,
    required this.folder,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
