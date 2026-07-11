/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class EditContainer extends StatefulWidget {
  final EzCP config;
  final AlignmentGeometry subAlign;
  final MenuController menuControl;
  final List<Widget> menuChildren;
  final Widget child;

  const EditContainer(
    this.config, {
    super.key,
    required this.subAlign,
    required this.menuControl,
    required this.menuChildren,
    required this.child,
  });

  @override
  State<EditContainer> createState() => _EditContainerState();
}

class _EditContainerState extends State<EditContainer> with SingleTickerProviderStateMixin {
  // Init //

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

// Return the build //

  Widget core() => EzRow(widget.config, children: <Widget>[
        EzIcon(
          widget.config,
          Icons.drag_handle,
          color: widget.config.colors.outline,
        ),
        widget.config.rowMargin,
        MenuAnchor(
          controller: widget.menuControl,
          builder: (_, __, ___) => AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.config.colors.secondary.withValues(alpha: _animation.value),
                  width: widget.config.borderWidth,
                ),
                borderRadius: widget.config.buttonShape.radius,
              ),
              child: widget.child,
            ),
          ),
          menuChildren: widget.menuChildren,
        ),
        widget.config.rowMargin,
        EzIcon(
          widget.config,
          Icons.drag_handle,
          color: widget.config.colors.outline,
        ),
      ]);

  @override
  Widget build(_) => wideTiles(widget.config)
      ? InkWell(
          child: Container(
            width: double.infinity,
            alignment: widget.subAlign,
            child: core(),
          ),
        )
      : InkWell(child: core());

  @override
  void dispose() {
    _animControl.dispose();
    super.dispose();
  }
}

class EditSpacer extends StatelessWidget {
  final EzCP config;

  const EditSpacer(this.config, {super.key});

  @override
  Widget build(_) => ValueListenableBuilder<double>(
        valueListenable: editSpacerHeight,
        builder: (_, double height, __) => ValueListenableBuilder<double>(
          valueListenable: editSpacerWidth,
          builder: (_, double width, __) => Container(
            decoration: BoxDecoration(
              color: config.colors.secondary.withValues(alpha: focusOpacity),
              borderRadius: EzButtonShape.roundRect.radius,
              border: Border.all(
                color: config.colors.secondary,
                width: config.borderWidth,
              ),
            ),
            height: height,
            width: width,
          ),
        ),
      );
}
