/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:liminal_launcher/main.dart';
import 'package:liminal_launcher/utils/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

void main() async {
  // Setup the test environment //

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  EzConfig.init(
    assetPaths: <String>{},
    defaults: liminalDefault,
    localeFallback: americanEnglish,
    l10nFallback: await EFUILang.delegate.load(americanEnglish),
    preferences: await SharedPreferencesWithCache.create(
      cacheOptions:
          SharedPreferencesWithCacheOptions(allowList: allLimKeys.keys.toSet()),
    ),
  );

  // Run the tests //

  final List<AppInfo> apps = await getApps();

  group(
    'Generated tests',
    () {
      testWidgets('Test randomizer', (WidgetTester tester) async {
        // Load the app //

        ezLog('Loading Liminal Launcher');
        await tester.pumpWidget(LiminalLauncher(apps));
        await tester.pumpAndSettle();

        // Randomize the settings //

        // Open the settings menu
        await ezTouch(tester, find.byIcon(Icons.more_vert));

        // Go to the settings page
        await ezTouchText(tester, EzConfig.l10n.ssPageTitle);

        // Randomize the settings
        await ezTouchText(tester, EzConfig.l10n.ssRandom);
        await ezTouchText(tester, EzConfig.l10n.gYes);

        // Return to home screen
        await ezTapBack(tester, EzConfig.l10n.gBack);
      });

      testWidgets('Test CountFAB', (WidgetTester tester) async {
        // Re-load the app //

        ezLog('Loading Liminal Launcher');
        await tester.pumpWidget(LiminalLauncher(apps));
        await tester.pumpAndSettle();
      });
    },
  );
}
