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
import 'package:go_transitions/go_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  // Setup the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

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

  runApp(LiminalLauncher(await getApps()));
}

class LiminalLauncher extends StatelessWidget {
  final List<AppInfo> installedApps;

  const LiminalLauncher(this.installedApps, {super.key});

  // Return the app //

  @override
  Widget build(BuildContext context) {
    GoTransition.defaultCurve = Curves.linear;

    return ChangeNotifierProvider<AppInfoProvider>(
      create: (_) => AppInfoProvider(installedApps),
      child: EzAppProvider(
        app: MaterialApp.router(
          debugShowCheckedModeBanner: false,

          // Language handlers
          localizationsDelegates: <LocalizationsDelegate<dynamic>>{
            const LocaleNamesLocalizationsDelegate(),
            ...EFUILang.localizationsDelegates,
            ...Lang.localizationsDelegates,
          },
          supportedLocales: Lang.supportedLocales,
          locale: getStoredLocale(),

          // App title
          title: appName,

          // Router (page) config
          routerConfig: GoRouter(
            initialLocation: homePath,
            errorBuilder: (_, GoRouterState state) => ErrorScreen(state.error),
            routes: <RouteBase>[
              GoRoute(
                path: homePath,
                name: homePath,
                builder: (_, __) => const HomeScreen(),
                pageBuilder: GoTransitions.none.call,
                routes: <RouteBase>[
                  GoRoute(
                    path: appListPath,
                    name: appListPath,
                    builder: (_, GoRouterState state) {
                      final Map<String, dynamic> listData =
                          state.extra as Map<String, dynamic>;

                      return AppListScreen(
                        listCheck: listData[ListData.listCheck.key],
                        onSelected: listData[ListData.onSelected.key],
                        refresh: listData[ListData.refresh.key],
                        autoRefresh: listData[ListData.autoRefresh.key],
                        editable: listData[ListData.editable.key],
                        icon: listData[ListData.icon.key],
                      );
                    },
                    pageBuilder: GoTransitions.openUpwards.withFade.call,
                  ),
                  GoRoute(
                    path: settingsHomePath,
                    name: settingsHomePath,
                    builder: (_, __) => const SettingsHomeScreen(),
                    pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                    routes: <RouteBase>[
                      GoRoute(
                        path: launcherSettingsPath,
                        name: launcherSettingsPath,
                        builder: (_, __) => const LauncherSettingsScreen(),
                        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                      ),
                      GoRoute(
                        path: colorSettingsPath,
                        name: colorSettingsPath,
                        builder: (_, __) => const ColorSettingsScreen(),
                        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzCSType.quick.path,
                            name: EzCSType.quick.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.quick),
                            pageBuilder:
                                GoTransitions.slide.toLeft.withFade.call,
                          ),
                          GoRoute(
                            path: EzCSType.advanced.path,
                            name: EzCSType.advanced.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.advanced),
                            pageBuilder:
                                GoTransitions.slide.toLeft.withFade.call,
                          ),
                        ],
                      ),
                      GoRoute(
                        path: designSettingsPath,
                        name: designSettingsPath,
                        builder: (_, __) => const DesignSettingsScreen(),
                        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                      ),
                      GoRoute(
                        path: layoutSettingsPath,
                        name: layoutSettingsPath,
                        builder: (_, __) => const LayoutSettingsScreen(),
                        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                      ),
                      GoRoute(
                        path: textSettingsPath,
                        name: textSettingsPath,
                        builder: (_, __) => const TextSettingsScreen(),
                        pageBuilder: GoTransitions.slide.toLeft.withFade.call,
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzTSType.quick.path,
                            name: EzTSType.quick.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.quick),
                            pageBuilder:
                                GoTransitions.slide.toLeft.withFade.call,
                          ),
                          GoRoute(
                            path: EzTSType.advanced.path,
                            name: EzTSType.advanced.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.advanced),
                            pageBuilder:
                                GoTransitions.slide.toLeft.withFade.call,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
