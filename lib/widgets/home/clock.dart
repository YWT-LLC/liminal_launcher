/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class Clock extends StatefulWidget {
  final bool showTime;
  final String dateType;
  final ListAlignment hAlign;

  const Clock({
    super.key,
    required this.showTime,
    required this.dateType,
    required this.hAlign,
  });

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime now = DateTime.now();
  late Timer ticker;

  @override
  void initState() {
    super.initState();

    ticker = widget.showTime
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          });
  }

  @override
  Widget build(BuildContext context) {
    return EzTextBackground(Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.hAlign.crossAxis,
      children: <Widget>[
        if (widget.showTime)
          Text(
            TimeOfDay.fromDateTime(now).format(context),
            style: EzConfig.styles.headlineLarge,
          ),
        if (widget.dateType != DateType.none.value)
          Text(
            DateTypeConfig.buildDate(
                DateTypeConfig.lookup(widget.dateType), context, now),
            style: EzConfig.styles.labelLarge,
          ),
      ],
    ));
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
