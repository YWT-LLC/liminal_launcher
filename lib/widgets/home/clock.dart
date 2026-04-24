/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime now = DateTime.now();
  late Timer ticker;

  @override
  void initState() {
    super.initState();

    ticker = homeTime
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          });
  }

  @override
  Widget build(BuildContext context) => EzTextBackground(EzCol(
        crossAxisAlignment: hAlign.crossAxis,
        children: <Widget>[
          if (homeTime)
            Text(
              TimeOfDay.fromDateTime(now).format(context),
              style: EzConfig.styles.headlineLarge,
            ),
          if (homeDate != DateType.none)
            Text(
              DateTypeConfig.buildDate(context, now, homeDate),
              style: EzConfig.styles.labelLarge,
            ),
        ],
      ));

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
