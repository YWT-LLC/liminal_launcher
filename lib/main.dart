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
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  // Config the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]);

  EzConfig.init(
    assetPaths: assetPaths,
    defaults: liminalDefault,
    localeFallback: americanEnglish,
    l10nFallback: await EFUILang.delegate.load(americanEnglish),
    preferences: await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: allLimKeys.keys.toSet(),
      ),
    ),
  );

  // Run the app //

  if (EzConfig.get(hideStatusKey) == true) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[SystemUiOverlay.bottom],
    );
  }

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
      child: EzConfigurableApp(
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
          errorBuilder: (_, GoRouterState state) => ErrorScreen(state.error),
          routes: <RouteBase>[
            // Home
            GoRoute(
              path: homePath,
              name: homePath,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  ezPageBuilder(context, state, HomeScreen()),
              routes: <RouteBase>[
                // App list
                GoRoute(
                  path: appListPath,
                  name: appListPath,
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    final Map<String, dynamic> listData =
                        state.extra as Map<String, dynamic>;

                    return ezPageBuilder(
                      context,
                      state,
                      AppListScreen(
                        listCheck: listData[ListData.listCheck.key],
                        onSelected: listData[ListData.onSelected.key],
                        refresh: listData[ListData.refresh.key],
                        autoRefresh: listData[ListData.autoRefresh.key],
                        editable: listData[ListData.editable.key],
                        icon: listData[ListData.icon.key],
                      ),
                      transitionsBuilder: (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child,
                      ) =>
                          ezTransitionsBuilder(
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                        force: EzPageTransition.slideY,
                      ),
                    );
                  },
                ),

                // Settings home
                GoRoute(
                  path: settingsHomePath,
                  name: settingsHomePath,
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      ezPageBuilder(context, state, SettingsHomeScreen()),
                  routes: <RouteBase>[
                    // Appearance settings
                    GoRoute(
                      path: appearanceSettingsPath,
                      name: appearanceSettingsPath,
                      pageBuilder:
                          (BuildContext context, GoRouterState state) =>
                              ezPageBuilder(
                                  context, state, AppearanceSettingsScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
