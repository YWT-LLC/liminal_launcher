/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// App Info //

class AppInfo {
  final String _package;
  final String _label;
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

  String get label => _label;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is AppInfo && id == other.id;

  @override
  String toString() => '''<AppInfo> {
  package: $_package
  label: $_label,
  id: $id,
  icon: ${icon == null ? 'null' : 'present'},
  removable: $removable,
  installDate: $installDate,
  packageSize: $packageSize
}''';
}

/// Helpful for creating [AppInfo] lists
/// [nullAppLabel], [nullAppPackage], false, 0, 0
final AppInfo nullApp = AppInfo(
  label: nullAppLabel,
  package: nullAppPackage,
  removable: false,
  installDate: 0,
  packageSize: 0,
);

// List Config //

class ListConfig {
  final Widget? title;
  final ValueNotifier<List<String>>? localContent;
  final Set<ListContent> listContent;
  final bool include;
  final Future<void> Function(AppInfo app) onSelected;

  const ListConfig({
    required this.title,
    this.localContent,
    required this.listContent,
    required this.include,
    required this.onSelected,
  });
}
