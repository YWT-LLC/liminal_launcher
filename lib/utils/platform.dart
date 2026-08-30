/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/services.dart';

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
    await platform.invokeMethod('launchApp', <String, dynamic>{'packageName': app.package});
  } catch (e) {
    ezLog('Failed to launch ${app.package}: $e');
  }
}

Future<void> openAppSettings(AppInfo app) async {
  try {
    await platform.invokeMethod('openAppSettings', <String, dynamic>{'packageName': app.package});
  } catch (e) {
    ezLog('Failed to open ${app.package} settings: $e');
  }
}

Future<void> openSystemSettings() async {
  try {
    await platform.invokeMethod('openSystemSettings');
  } catch (e) {
    ezLog('Failed to open system settings: $e');
  }
}

Future<void> openDelete(AppInfo app) async {
  try {
    await platform.invokeMethod('deleteApp', <String, dynamic>{'packageName': app.package});
  } catch (e) {
    ezLog('Failed to delete ${app.package}: $e');
  }
}

// Widgets //

Future<bool> createCalendarEvent(String? title) async {
  try {
    await platform.invokeMethod('createCalendarEvent', <String, dynamic>{'title': title});
    return true;
  } catch (e) {
    ezLog('Failed to create calendar event: $e');
    return false;
  }
}

Future<bool> createTask(String? title, AppInfo? shareDest) async {
  try {
    await platform.invokeMethod('createTask', <String, dynamic>{
      'title': title,
      'packageName': shareDest?.package,
    });
    return true;
  } catch (e) {
    ezLog('Failed to create task: $e');
    return false;
  }
}

Future<void> fastForward() async {
  try {
    await platform.invokeMethod('fastForward');
  } catch (e) {
    ezLog('Failed to fast forward: $e');
  }
}

Future<void> rewind() async {
  try {
    await platform.invokeMethod('rewind');
  } catch (e) {
    ezLog('Failed to rewind: $e');
  }
}

Future<bool> setTimer(List<int> values) async {
  try {
    await platform.invokeMethod('setTimer', <String, dynamic>{
      'ours': values[0],
      'mins': values[1],
      'secs': values[2],
    });
    return true;
  } catch (e) {
    ezLog('Failed to set timer: $e');
    return false;
  }
}

Future<void> skipNext() async {
  try {
    await platform.invokeMethod('skipNext');
  } catch (e) {
    ezLog('Failed to skip to next media: $e');
  }
}

Future<void> skipPrev() async {
  try {
    await platform.invokeMethod('skipPrev');
  } catch (e) {
    ezLog('Failed to skip to previous media: $e');
  }
}

Future<void> toggleMedia() async {
  try {
    await platform.invokeMethod('toggleMedia');
  } catch (e) {
    ezLog('Failed to toggle media: $e');
  }
}
