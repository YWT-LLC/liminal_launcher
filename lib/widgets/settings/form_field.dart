/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';

// TODO: get error text to behave

class LimField extends TextFormField {
  final String hintText;

  LimField({
    super.key,
    super.autofillHints,
    super.controller,
    super.focusNode,
    required this.hintText,
    super.keyboardType,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onTap,
    super.onTapAlwaysCalled = true,
    super.onTapOutside,
    super.readOnly,
    super.textInputAction,
    required super.validator,
  }) : super(
          autovalidateMode: AutovalidateMode.onUnfocus,
          decoration: InputDecoration(hintText: hintText),
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
        );
}

const String _pattern = r'^(?!.*:[01]{8}:)[^/\\\x00]{1,100}$';
String? validateName(String? name) {
  if (name == null || name.trim().isEmpty) return 'Cannot be empty';

  final RegExp regex = RegExp(_pattern);
  if (regex.hasMatch(name)) return 'Invalid. Regex pattern: $_pattern';

  return null;
}
