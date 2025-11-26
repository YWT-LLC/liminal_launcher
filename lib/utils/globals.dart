/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

final Duration animDuration = ezAnimDuration();

/// Tracks the position of the last ripple LongPress
/// Defaults to [Offset.zero]
Offset lastRipple = Offset.zero;
