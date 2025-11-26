/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
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
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  // Setup the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  EzConfig.init(
    preferences: await SharedPreferences.getInstance(),
    defaults: liminalDefault,
    fallbackLang: await EFUILang.delegate.load(americanEnglish),
    assetPaths: assetPaths,
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

  @override
  Widget build(BuildContext context) {
    // Prep the router //

    GoTransition.defaultCurve = Curves.linear;
    GoTransition.defaultDuration = animDuration;

    // Return the app //

    return ChangeNotifierProvider<AppInfoProvider>(
      create: (_) => AppInfoProvider(installedApps),
      child: EzAppProvider(
        app: PlatformApp.router(
          debugShowCheckedModeBanner: false,

          // Language handlers
          localizationsDelegates: <LocalizationsDelegate<dynamic>>{
            const LocaleNamesLocalizationsDelegate(),
            ...EFUILang.localizationsDelegates,
            ...Lang.localizationsDelegates,
          },
          supportedLocales: Lang.supportedLocales,
          locale: EzConfig.getLocale(),

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
                    pageBuilder: GoTransitions.fade.call,
                    routes: <RouteBase>[
                      GoRoute(
                        path: colorSettingsPath,
                        name: colorSettingsPath,
                        builder: (_, __) => const ColorSettingsScreen(),
                        pageBuilder: GoTransitions.fade.call,
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzCSType.quick.path,
                            name: EzCSType.quick.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.quick),
                            pageBuilder: GoTransitions.fade.call,
                          ),
                          GoRoute(
                            path: EzCSType.advanced.path,
                            name: EzCSType.advanced.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.advanced),
                            pageBuilder: GoTransitions.fade.call,
                          ),
                        ],
                      ),
                      GoRoute(
                        path: designSettingsPath,
                        name: designSettingsPath,
                        builder: (_, __) => const DesignSettingsScreen(),
                        pageBuilder: GoTransitions.fade.call,
                      ),
                      GoRoute(
                        path: layoutSettingsPath,
                        name: layoutSettingsPath,
                        builder: (_, __) => const LayoutSettingsScreen(),
                        pageBuilder: GoTransitions.fade.call,
                      ),
                      GoRoute(
                        path: textSettingsPath,
                        name: textSettingsPath,
                        builder: (_, __) => const TextSettingsScreen(),
                        pageBuilder: GoTransitions.fade.call,
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzTSType.quick.path,
                            name: EzTSType.quick.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.quick),
                            pageBuilder: GoTransitions.fade.call,
                          ),
                          GoRoute(
                            path: EzTSType.advanced.path,
                            name: EzTSType.advanced.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.advanced),
                            pageBuilder: GoTransitions.fade.call,
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
