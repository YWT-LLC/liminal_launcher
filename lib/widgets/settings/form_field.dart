/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';

class LimField extends TextFormField {
  LimField({
    super.key,
    super.controller,
    super.autofillHints,
    super.decoration,
    super.keyboardType,
    super.readOnly,
    super.onTap,
    super.onChanged,
    super.onFieldSubmitted,
  }) : super(
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          autovalidateMode: AutovalidateMode.onUnfocus,
          validator: validateName,
        );
}
