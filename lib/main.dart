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
import 'package:open_ui/open_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  // Setup the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);

  EzCM.init(
    appName: appName,
    androidPackage: androidPackage,
    assetPaths: assetPaths,
    orientations: <DeviceOrientation>[DeviceOrientation.portraitUp],
    localeFallback: americanEnglish,
    l10nFallback: await OUILang.delegate.load(americanEnglish),
    preferences: await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: allLimKeys.keys.toSet()),
    ),
    securePreferences: const FlutterSecureStorage(),
    defaults: liminalDefault,
    neverReset: neverResetKeys,
  );

  // Run the app //

  final (Locale storedLocale, OUILang storedOUILang) = await ezStoredL10n();

  runApp(
    LiminalLauncher(
      await getApps(),
      storedLocale,
      storedOUILang,
      await Lang.delegate.load(storedLocale),
    ),
  );
}

class LiminalLauncher extends StatelessWidget {
  final List<AppInfo> installedApps;
  final Locale storedLocale;
  final OUILang storedOUILang;
  final Lang storedLang;

  const LiminalLauncher(
    this.installedApps,
    this.storedLocale,
    this.storedOUILang,
    this.storedLang, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppInfoProvider>(
        create: (_) => AppInfoProvider(installedApps),
        child: _TheMagic(installedApps, storedLocale, storedOUILang, storedLang),
      );
}

class _TheMagic extends StatelessWidget {
  final List<AppInfo> installedApps;
  final Locale storedLocale;
  final OUILang storedOUILang;
  final Lang storedLang;

  const _TheMagic(this.installedApps, this.storedLocale, this.storedOUILang, this.storedLang);

  @override
  Widget build(BuildContext context) => EzConfigurableApp(
        localizationsDelegates: ezLocalizationsDelegates(Lang.localizationsDelegates),
        supportedLocales: Lang.supportedLocales,
        locale: storedLocale,
        el10n: storedOUILang,
        appCache: LiminalCache(storedLocale, storedLang),
        routerConfig: GoRouter(
          navigatorKey: ezRootNav,
          initialLocation: homePath,
          errorBuilder: (_, __) => const ErrorScreen(),
          routes: <RouteBase>[
            // Home
            GoRoute(
              path: homePath,
              name: homePath,
              pageBuilder: (BuildContext pbc, GoRouterState pbs) =>
                  ezPageBuilder(configWatcher(pbc), pbc, pbs, const HomeScreen()),
              routes: <RouteBase>[
                // App list
                GoRoute(
                  path: appListPath,
                  name: appListPath,
                  pageBuilder: (BuildContext pbc, GoRouterState pbs) => ezPageBuilder(
                    configWatcher(pbc),
                    pbc,
                    pbs,
                    AppListScreen(pbs.extra as ListConfig),
                    transitionsBuilder: (BuildContext context, Animation<double> a,
                            Animation<double> aa, Widget w) =>
                        ezTransitionsBuilder(
                      configWatcher(pbc),
                      context,
                      a,
                      aa,
                      w,
                      forceType: EzTransitionType.slideY,
                      forceFade: true,
                    ),
                  ),
                ),

                // Settings home
                GoRoute(
                  path: settingsPath,
                  name: settingsPath,
                  pageBuilder: (BuildContext pbc, GoRouterState pbs) =>
                      ezPageBuilder(configWatcher(pbc), pbc, pbs, const SettingsScreen()),
                ),
              ],
            ),
          ],
        ),
      );
}
