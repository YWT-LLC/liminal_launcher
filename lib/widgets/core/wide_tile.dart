/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../utils/export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

class WideTile extends StatelessWidget {
  final EzCP config;
  final LimPos pos;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Widget child;

  const WideTile(
    this.config, {
    super.key,
    required this.pos,
    this.onTap,
    this.onLongPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => wideTiles(config)
      ? InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            width: double.infinity,
            alignment: pos.subAlign,
            child: child,
          ),
        )
      : child;
}
