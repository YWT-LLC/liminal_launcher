/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';

// TODO: use for every field
// TODO: don't always validate (widget entries)
// TODO: get error text to behave
// TODO: the other TODOs
// TODO: start the maticulous testing

class LimField extends TextFormField {
  final String hintText;

  LimField({
    super.key,
    super.autofillHints,
    super.controller,
    required this.hintText,
    super.keyboardType,
    super.onChanged,
    super.onFieldSubmitted,
    super.onTap,
    super.readOnly,
  }) : super(
          autovalidateMode: AutovalidateMode.onUnfocus,
          decoration: InputDecoration(hintText: hintText),
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
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
