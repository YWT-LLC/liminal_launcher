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

  SharedPreferences.setMockInitialValues(empathMobileConfig);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  EzConfig.init(
    preferences: prefs,
    defaults: liminalDefault,
    fallbackLang: await EFUILang.delegate.load(americanEnglish),
    assetPaths: <String>{},
  );

  // Run the tests //

  final List<AppInfo> apps = await getApps();

  group(
    'Generated tests',
    () {
      testWidgets('Test randomizer', (WidgetTester tester) async {
        // Load localization(s) //

        ezLog('Loading localizations');
        final EFUILang l10n = await EFUILang.delegate.load(americanEnglish);

        // Load the app //

        ezLog('Loading Liminal Launcher');
        await tester.pumpWidget(LiminalLauncher(apps));
        await tester.pumpAndSettle();

        // Randomize the settings //

        // Open the settings menu
        await ezTouch(tester, find.byIcon(Icons.more_vert));

        // Go to the settings page
        await ezTouchText(tester, l10n.ssPageTitle);

        // Randomize the settings
        await ezTouchText(tester, l10n.ssRandom);
        await ezTouchText(tester, l10n.gYes);

        // Return to home screen
        await ezTapBack(tester, l10n.gBack);
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
