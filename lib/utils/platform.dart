/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

const MethodChannel platform = MethodChannel('$androidPackage/query');

/// Get all installed apps
Future<List<AppInfo>> getApps() async {
  try {
    final List<dynamic>? appData = await platform.invokeMethod('getApps');

    if (appData == null) return <AppInfo>[];
    final List<AppInfo> apps =
        appData.map((dynamic app) => AppInfo.fromMap(Map<String, dynamic>.from(app))).toList();
    apps.remove(self);
    return apps;
  } catch (e) {
    ezLog('Failed to get apps: $e');
    return <AppInfo>[];
  }
}

Future<void> launchApp(String appID) async {
  final String package = appID.split(idSplit).first;

  try {
    await platform.invokeMethod('launchApp', <String, dynamic>{
      'packageName': package,
    });
  } catch (e) {
    ezLog('Failed to launch $package: $e');
  }
}

Future<void> openSettings(String appID) async {
  final String package = appID.split(idSplit).first;

  try {
    await platform.invokeMethod('openSettings', <String, dynamic>{
      'packageName': package,
    });
  } catch (e) {
    ezLog('Failed to open the settings for $package: $e');
  }
}

/// Reminder: Android shows a built-in uninstall dialog
Future<bool> deleteApp(AppInfo app) async {
  try {
    await platform.invokeMethod('deleteApp', <String, dynamic>{
      'packageName': app.package,
    }); // TODO: return real results
    return true;
  } catch (e) {
    ezLog('Failed to delete ${app.package}: $e');
    return false;
  }
}
