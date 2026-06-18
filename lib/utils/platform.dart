/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

const MethodChannel platform = MethodChannel('$androidPackage/query');

// Core //

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

Future<void> launchApp(AppInfo app) async {
  try {
    await platform.invokeMethod('launchApp', <String, dynamic>{
      'packageName': app.package,
    });
  } catch (e) {
    ezLog('Failed to launch ${app.package}: $e');
  }
}

Future<void> openSettings(AppInfo app) async {
  try {
    await platform.invokeMethod('openSettings', <String, dynamic>{
      'packageName': app.package,
    });
  } catch (e) {
    ezLog('Failed to open ${app.package} settings: $e');
  }
}

Future<void> openDelete(AppInfo app) async {
  try {
    await platform.invokeMethod('deleteApp', <String, dynamic>{
      'packageName': app.package,
    });
  } catch (e) {
    ezLog('Failed to delete ${app.package}: $e');
  }
}

// Widgets //

Future<void> createCalendarEvent() async {
  try {
    await platform.invokeMethod('createCalendarEvent');
  } catch (e) {
    ezLog('Failed to create calendar event: $e');
  }
}

Future<void> openStopwatch() async {
  try {
    await platform.invokeMethod('openStopwatch');
  } catch (e) {
    ezLog('Failed to open stopwatch: $e');
  }
}

Future<void> setTimer({int? seconds, bool auto = true}) async {
  try {
    await platform.invokeMethod('setTimer', <String, dynamic>{
      if (seconds != null) 'length': seconds,
      'skipUi': auto,
    });
  } catch (e) {
    ezLog('Failed to set timer: $e');
  }
}

Future<void> toggleMedia() async {
  try {
    await platform.invokeMethod('toggleMedia');
  } catch (e) {
    ezLog('Failed to toggle media: $e');
  }
}
