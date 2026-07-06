/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

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

const String _pattern = r'^(?!.*:[01]{8}:)[^/\\\x00]{1,100}$';
String? validateName(String? name) {
  if (name == null || name.trim().isEmpty) return 'Cannot be empty';

  final RegExp regex = RegExp(_pattern);
  if (regex.hasMatch(name)) return 'Invalid. Regex pattern: $_pattern';

  return null;
}
