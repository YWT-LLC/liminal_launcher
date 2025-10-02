/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

/// '---'
const String nullAppLabel = '---';

/// ''
const String nullAppPackage = '';

/// ';'
const String idSplit = ':';

/// Helpful for creating [AppInfo] lists
/// [nullAppLabel], [nullAppPackage], false, 0, 0
final AppInfo nullApp = AppInfo(
  label: nullAppLabel,
  package: nullAppPackage,
  removable: false,
  installDate: 0,
  packageSize: 0,
);

class AppInfo {
  final String _package;
  final String _label;
  String name;
  String id;
  final Uint8List? icon;
  final bool removable;
  final int installDate;
  final int packageSize;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  AppInfo({
    required String package,
    required String label,
    this.icon,
    required this.removable,
    required this.installDate,
    required this.packageSize,
  })  : _label = label,
        name = label,
        _package = package,
        id = package + idSplit + label;

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        package: map['package'] ?? nullAppPackage,
        label: map['label'] ?? nullAppLabel,
        icon: map['icon'],
        removable: map['removable'] ?? false,
        installDate: map['installDate'] ?? 0,
        packageSize: map['packageSize'] ?? 0,
      );

  String get package => _package;

  set rename(String newName) => name = newName;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is AppInfo && id == other.id;

  @override
  String toString() => '''<AppInfo> {
  package: $_package
  label: $_label,
  name: $name,
  id: $id,
  icon: ${icon == null ? 'null' : 'present'},
  removable: $removable,
  installDate: $installDate,
  packageSize: $packageSize
}''';
}

const String _pattern = r"^[\w\s\-\.\&\(\)']+$";

String? validateRename(String? newName) {
  if (newName == null || newName.trim().isEmpty) return 'Cannot be empty';

  final RegExp validNameRegExp = RegExp(_pattern);
  if (!validNameRegExp.hasMatch(newName)) return 'Invalid; $_pattern';

  return null;
}
