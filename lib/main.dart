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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  EzConfig.init(
    preferences: await SharedPreferences.getInstance(),
    defaults: defaultConfig,
    fallbackLang: await EFUILang.delegate.load(americanEnglish),
    assetPaths: <String>{},
  );

  runApp(LiminalLauncher(await getApps()));
}

class LiminalLauncher extends StatelessWidget {
  final List<AppInfo> installedApps;

  const LiminalLauncher(this.installedApps, {super.key});

  @override
  Widget build(BuildContext context) {
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

          // Supported languages
          supportedLocales: Lang.supportedLocales,

          // Current language
          locale: EzConfig.getLocale(),

          title: appTitle,
          routerConfig: GoRouter(
            initialLocation: homePath,
            errorBuilder: (_, GoRouterState state) => ErrorScreen(state.error),
            routes: <RouteBase>[
              GoRoute(
                path: homePath,
                name: homePath,
                builder: (_, __) => const HomeScreen(),
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
                  ),
                  GoRoute(
                    path: settingsHomePath,
                    name: settingsHomePath,
                    builder: (_, __) => const SettingsHomeScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: textSettingsPath,
                        name: textSettingsPath,
                        builder: (_, __) => const TextSettingsScreen(),
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzTSType.quick.path,
                            name: EzTSType.quick.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.quick),
                          ),
                          GoRoute(
                            path: EzTSType.advanced.path,
                            name: EzTSType.advanced.name,
                            builder: (_, __) => const TextSettingsScreen(
                                target: EzTSType.advanced),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: layoutSettingsPath,
                        name: layoutSettingsPath,
                        builder: (_, __) => const LayoutSettingsScreen(),
                      ),
                      GoRoute(
                        path: colorSettingsPath,
                        name: colorSettingsPath,
                        builder: (_, __) => const ColorSettingsScreen(),
                        routes: <RouteBase>[
                          GoRoute(
                            path: EzCSType.quick.path,
                            name: EzCSType.quick.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.quick),
                          ),
                          GoRoute(
                            path: EzCSType.advanced.path,
                            name: EzCSType.advanced.name,
                            builder: (_, __) => const ColorSettingsScreen(
                                target: EzCSType.advanced),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: imageSettingsPath,
                        name: imageSettingsPath,
                        builder: (_, __) => const ImageSettingsScreen(),
                      ),
                      GoRoute(
                        path: designSettingsPath,
                        name: designSettingsPath,
                        builder: (_, __) => const DesignSettingsScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        darkTheme: ezThemeData(Brightness.dark)
            .copyWith(scaffoldBackgroundColor: Colors.transparent),
        lightTheme: ezThemeData(Brightness.light)
            .copyWith(scaffoldBackgroundColor: Colors.transparent),
      ),
    );
  }
}
