/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './screens/export.dart';
import './utils/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  // Setup the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  EzConfig.init(
    assetPaths: assetPaths,
    localeFallback: americanEnglish,
    l10nFallback: await EFUILang.delegate.load(americanEnglish),
    preferences: await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: allLimKeys.keys.toSet(),
      ),
    ),
    securePreferences: const FlutterSecureStorage(),
    defaults: liminalDefault,
    neverReset: neverResetKeys,
  );

  // Run the app //

  final (Locale storedLocale, EFUILang storedEFUILang) = await ezStoredL10n();

  runApp(LiminalLauncher(
    await getApps(),
    storedLocale,
    storedEFUILang,
    await Lang.delegate.load(storedLocale),
  ));
}

class LiminalLauncher extends StatelessWidget {
  final List<AppInfo> installedApps;
  final Locale storedLocale;
  final EFUILang storedEFUILang;
  final Lang storedLang;

  const LiminalLauncher(
    this.installedApps,
    this.storedLocale,
    this.storedEFUILang,
    this.storedLang, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppInfoProvider>(
      create: (_) => AppInfoProvider(installedApps),
      child: _TheMagic(installedApps, storedLocale, storedEFUILang, storedLang),
    );
  }
}

class _TheMagic extends StatelessWidget {
  final List<AppInfo> installedApps;
  final Locale storedLocale;
  final EFUILang storedEFUILang;
  final Lang storedLang;

  const _TheMagic(
    this.installedApps,
    this.storedLocale,
    this.storedEFUILang,
    this.storedLang,
  );

  @override
  Widget build(BuildContext context) {
    return EzConfigurableApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>{
        const LocaleNamesLocalizationsDelegate(),
        ...EFUILang.localizationsDelegates,
        ...Lang.localizationsDelegates,
      },
      supportedLocales: Lang.supportedLocales,
      locale: storedLocale,
      el10n: storedEFUILang,
      appCache: LiminalCache(storedLocale, storedLang),
      appName: appName,
      routerConfig: GoRouter(
        navigatorKey: ezRootNav,
        initialLocation: homePath,
        errorBuilder: (_, GoRouterState rs) => ErrorScreen(rs.error),
        routes: <RouteBase>[
          // Home
          GoRoute(
            path: homePath,
            name: homePath,
            pageBuilder: (BuildContext pbc, GoRouterState rs) =>
                ezPageBuilder(pbc, rs, HomeScreen()),
            routes: <RouteBase>[
              // App list
              GoRoute(
                path: appListPath,
                name: appListPath,
                pageBuilder: (BuildContext pbc, GoRouterState rs) =>
                    ezPageBuilder(
                  pbc,
                  rs,
                  AppListScreen(rs.extra as ListConfig),
                  transitionsBuilder: (BuildContext tbc, Animation<double> a,
                          Animation<double> aa, Widget w) =>
                      ezTransitionsBuilder(tbc, a, aa, w,
                          force: EzPageTransition.slideY),
                ),
              ),

              // Settings home
              GoRoute(
                path: settingsHomePath,
                name: settingsHomePath,
                pageBuilder: (BuildContext pbc, GoRouterState rs) =>
                    ezPageBuilder(pbc, rs, SettingsHomeScreen()),
                routes: <RouteBase>[
                  // Appearance settings
                  GoRoute(
                    path: appearanceSettingsPath,
                    name: appearanceSettingsPath,
                    pageBuilder: (BuildContext pbc, GoRouterState rs) =>
                        ezPageBuilder(pbc, rs, AppearanceSettingsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
