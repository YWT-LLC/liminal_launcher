/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class EditContainer extends StatefulWidget {
  final EzCP config;
  final Widget child;
  final MenuController menuControl;
  final List<Widget> menuChildren;
  final bool dragHandles;

  const EditContainer(
    this.config, {
    super.key,
    required this.child,
    required this.menuControl,
    required this.menuChildren,
    this.dragHandles = false,
  });

  @override
  State<EditContainer> createState() => _EditContainerState();
}

class _EditContainerState extends State<EditContainer> with SingleTickerProviderStateMixin {
  late final AnimationController _animControl;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animControl = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animControl, curve: Curves.linear));

    _animControl.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final Widget core = MenuAnchor(
      controller: widget.menuControl,
      builder: (_, __, ___) => AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            borderRadius: widget.config.buttonShape.radius,
            border: Border.all(
              color: widget.config.colors.secondaryContainer.withValues(alpha: _animation.value),
              width: widget.config.borderWidth,
            ),
          ),
          child: widget.child,
        ),
      ),
      menuChildren: widget.menuChildren,
    );

    return widget.dragHandles
        ? EzRow(widget.config, children: <Widget>[
            EzIcon(
              widget.config,
              Icons.drag_handle,
              color: widget.config.colors.outline,
            ),
            widget.config.rowMargin,
            core,
            widget.config.rowMargin,
            EzIcon(
              widget.config,
              Icons.drag_handle,
              color: widget.config.colors.outline,
            ),
          ])
        : core;
  }

  @override
  void dispose() {
    _animControl.dispose();
    super.dispose();
  }
}
