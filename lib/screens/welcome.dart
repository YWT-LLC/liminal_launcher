/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:async';
import 'dart:math';
import 'package:open_ui/open_ui.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// TODO: l10n

const int _numPages = 6;
const int _lastPage = _numPages - 1;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Define the build data //

  int page = 0;
  int delta = 0;

  // Theme(s)
  bool separate = !EzCM.updateBoth;

  // Wallpaper(s)
  String darkPath = _path(darkBackgroundImageKey);
  String lightPath = _path(lightBackgroundImageKey);
  bool darkColors = false;
  bool lightColors = false;
  bool syncing = false;

  // Lanes
  late bool usePage = pages(_config);
  late bool useWide = wideTiles(_config);

  // Launch
  static const int shuffleSeconds = 3;
  final Random random = Random();
  Timer? shuffleTimer;
  int countdown = shuffleSeconds;
  _LaunchStyle? launchStyle;

  // Define custom functions //

  String _path(String key) => EzCM.get(key) ?? noImageValue;

  static bool _isImage(String path) =>
      path != noImageValue && int.tryParse(path) == null && path.split(colorSplit).length < 4;

  void goTo(int target) {
    if (target < 0 || target > _lastPage || target == page) return;

    setState(() {
      delta = target > page ? 1 : -1;
      page = target;
    });

    (page == _lastPage) ? startShuffle() : stopShuffle();
  }

  Future<void> setSeparate(bool choice) async {
    await EzCM.setBool(updateBothKey, !choice);
    setState(() => separate = choice);
  }

  /// Mirrors (when shared) and colors (when requested) newly chosen wallpapers
  /// [EzImageSetting] calls [EzCP.rebuildUI] after a change, so we listen for that
  Future<void> onConfigChange() async {
    if (syncing) return;

    final String newDark = _path(darkBackgroundImageKey);
    final String newLight = _path(lightBackgroundImageKey);

    final bool darkChanged = newDark != darkPath;
    final bool lightChanged = newLight != lightPath;
    if (!darkChanged && !lightChanged) return;

    syncing = true;
    bool wrote = false;

    try {
      if (!separate) {
        // One setup for both: copy the edited wallpaper to the other theme
        final String source = darkChanged ? newDark : newLight;
        final String? fit = EzCM.get(darkChanged ? darkBackgroundFitKey : lightBackgroundFitKey);

        await EzCM.setString(
            darkChanged ? lightBackgroundImageKey : darkBackgroundImageKey, source);
        if (fit != null) {
          await EzCM.setString(darkChanged ? lightBackgroundFitKey : darkBackgroundFitKey, fit);
        }
        wrote = true;

        darkPath = source;
        lightPath = source;

        if ((_config.isDark ? darkColors : lightColors) && _isImage(source)) {
          await imageScheme(source, Brightness.dark);
          await imageScheme(source, Brightness.light);
        }
      } else {
        darkPath = newDark;
        lightPath = newLight;

        if (darkChanged && darkColors && _isImage(newDark)) {
          wrote = await imageScheme(newDark, Brightness.dark) || wrote;
        }
        if (lightChanged && lightColors && _isImage(newLight)) {
          wrote = await imageScheme(newLight, Brightness.light) || wrote;
        }
      }

      if (wrote) await _config.rebuildUI();
    } finally {
      syncing = false;
    }

    if (mounted) setState(() {});
  }

  /// Mirrors [EzImageSetting]'s color scheme logic, but for an explicit [Brightness]
  Future<bool> imageScheme(String path, Brightness brightness) async {
    final bool isDark = brightness == Brightness.dark;
    final String opacityKey = isDark ? darkTextBackgroundOpacityKey : lightTextBackgroundOpacityKey;

    // Better to have to turn it down than up
    final double? opacity = EzCM.get(opacityKey);
    if (opacity == null || opacity <= 0.05) await EzCM.setDouble(opacityKey, 0.50);

    final String result = await loadImageColorScheme(path, brightness);

    if (result == success) {
      await EzCM.setString(isDark ? darkColorSchemeImageKey : lightColorSchemeImageKey, path);
    } else {
      final String errorMsg =
          '$result${ezUrlCheck(path) ? '\n\n${_config.ezL10n.dsImgPermission}' : ''}';
      mounted
          ? ezLogAlert(
              _config,
              context: context,
              title: _config.ezL10n.dsImgGetFailed,
              message: errorMsg,
            )
          : ezLog(errorMsg);
    }
    return true;
  }

  /// Update the color toggle, applying it right away if a wallpaper is already set
  Future<void> setColors(bool choice, {required bool? dark}) async {
    setState(() {
      if (dark != false) darkColors = choice;
      if (dark != true) lightColors = choice;
    });
    if (!choice) return;

    syncing = true;
    bool wrote = false;
    try {
      if (dark != false && _isImage(darkPath)) {
        wrote = await imageScheme(darkPath, Brightness.dark) || wrote;
      }
      if (dark != true && _isImage(lightPath)) {
        wrote = await imageScheme(lightPath, Brightness.light) || wrote;
      }
      if (wrote) await _config.rebuildUI();
    } finally {
      syncing = false;
    }
  }

  Future<void> setLaneBool(
    EzCP config, {
    required String darkKey,
    required String lightKey,
    required bool value,
  }) async {
    if (interlinked || EzCM.updateBoth) {
      await EzCM.setBool(config.isDark ? lightKey : darkKey, value);
    }
  }

  void startShuffle() {
    shuffleTimer?.cancel();
    countdown = shuffleSeconds;

    shuffleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        countdown -= 1;
        if (countdown <= 0) {
          launchStyle = _LaunchStyle.random(random);
          countdown = shuffleSeconds;
        }
      });
    });
  }

  void stopShuffle() {
    shuffleTimer?.cancel();
    shuffleTimer = null;
  }

  Future<void> finish(EzCP config) async {
    stopShuffle();

    if (EzCM.get(config.isDark ? darkPagesKey : lightPagesKey) != pages(config) ||
        EzCM.get(config.isDark ? darkWideTilesKey : lightWideTilesKey) != wideTiles(config)) {
      await config.rebuildUI();
    }

    if (mounted) Navigator.of(context).pop();
  }

  // Build custom Widgets //

  Widget header(EzCP config) => EzText(
        config,
        text: '${page + 1}/$_numPages',
        textAlign: TextAlign.center,
        style: config.labelStyle,
      );

  Widget title(EzCP config, String text) => EzText(
        config,
        text: text,
        textAlign: TextAlign.center,
        style: config.titleStyle,
      );

  Widget body(EzCP config, String text, {TextStyle? style}) => EzText(
        config,
        text: text,
        textAlign: TextAlign.center,
        style: style ?? config.bodyStyle,
      );

  // 1. Welcome
  List<Widget> welcomePage(EzCP config) => <Widget>[
        // Welcome
        title(config, l10n(config).hsWelcome),
        config.centerLine,

        // Minimal-ish
        body(config, l10n(config).hsDescription),
        config.centerLine,

        // Yin/Yang
        EzRichText(
          config,
          children: <InlineSpan>[
            EzPlainText(
              text: l10n(config).hsUserSettings,
              style: config.bodyStyle,
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: EzIcon(config, Icons.dark_mode),
            ),
            EzPlainText(
              text: l10n(config).hsLight,
              style: config.bodyStyle,
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: EzIcon(config, Icons.light_mode),
            ),
            EzPlainText(
              text: l10n(config).hsBoth,
              style: config.bodyStyle,
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: FaIcon(FontAwesomeIcons.yinYang, size: config.iconSize),
            ),
            EzPlainText(
              text: l10n(config).hsThemes,
              style: config.bodyStyle,
            ),
          ],
          textAlign: TextAlign.center,
          style: config.bodyStyle,
        ),
        config.centerLine,

        // Let's go!
        body(config, "Let's get you set up.\nIt'll only take a minute!"),
      ];

  // 2. Theme(s)
  List<Widget> themePage(EzCP config) => <Widget>[
        header(config),
        title(config, 'Light & dark mode'),
        config.centerLine,
        body(config,
            'Would you like Liminal to look different in light and dark mode?\n\nOr keep things simple, with one look for both?'),
        config.spacer,
        EzSegmentedButton<bool>(
          config,
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              icon: FaIcon(FontAwesomeIcons.yinYang, size: config.iconSize),
              label: const Text('One for both', textAlign: TextAlign.center),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: EzIcon(config, Icons.contrast),
              label: const Text('Separate', textAlign: TextAlign.center),
            ),
          ],
          selected: <bool>{separate},
          showSelectedIcon: false,
          onSelectionChanged: (Set<bool>? choice) {
            if (choice?.first == null) return;
            setSeparate(choice!.first);
          },
        ),
        config.spacer,
        body(
          config,
          separate
              ? 'Light and dark mode will each have their own setup.\nChanges only apply to the mode you are editing.'
              : 'Changes will apply to both light and dark mode.',
          style: config.labelStyle,
        ),
        config.spacer,
        body(
          config,
          'You can change this any time in settings.',
          style: config.labelStyle,
        ),
      ];

  // 3. Wallpaper(s)
  Widget wallpaperSetting(
    EzCP config, {
    required bool? dark,
    required String label,
  }) {
    final bool useDark = dark ?? config.isDark;
    final bool colors = (dark ?? config.isDark) ? darkColors : lightColors;

    return EzCol(children: <Widget>[
      EzImageSetting(
        config,
        pathKey: useDark ? darkBackgroundImageKey : lightBackgroundImageKey,
        fitKey: useDark ? darkBackgroundFitKey : lightBackgroundFitKey,
        label: label,
        allowSolidColor: true,
        clearLabel: l10n(config).dpsUseOS,
      ),
      config.spacer,
      EzSwitchPair(
        config,
        key: ValueKey<String>('colors-$dark-$colors'),
        value: colors,
        text: 'Match colors',
        onChanged: (bool? choice) {
          if (choice == null) return;
          setColors(choice, dark: dark);
        },
      ),
    ]);
  }

  List<Widget> wallpaperPage(EzCP config) {
    final bool anySet = darkPath != noImageValue || lightPath != noImageValue;

    return <Widget>[
      header(config),
      if (separate && anySet) ...<Widget>[
        body(
          config,
          'Heads up! Custom wallpapers set your system wallpaper to black.\nIf you only set one, the other mode will be black, so it\'s probably best to set both.',
          style: config.labelStyle?.copyWith(color: config.tertiaryFill.asColor),
        ),
        config.spacer,
      ],
      title(
        config,
        separate ? 'Wallpapers' : l10n(config).dpsWallpaper,
      ),
      config.centerLine,
      body(
        config,
        'Pick an image (or color) for your home screen. "Match colors" will update the color scheme to fit.\n\nWant to keep your current wallpaper? Just skip this step.',
      ),
      config.spacer,
      separate
          ? EzWrap(
              children: <Widget>[
                ezWrap(
                  config,
                  child: wallpaperSetting(config, dark: true, label: 'Dark\nwallpaper'),
                ),
                ezWrap(
                  config,
                  child: wallpaperSetting(config, dark: false, label: 'Light\nwallpaper'),
                ),
              ],
            )
          : wallpaperSetting(config, dark: null, label: l10n(config).dpsWallpaper),
    ];
  }

  // 4. Lanes
  List<Widget> lanePage(EzCP config) {
    final TextStyle? focussed = config.bodyStyle;
    final TextStyle? hidden = config.labelStyle?.copyWith(color: config.outline);

    return <Widget>[
      header(config),
      title(config, l10n(config).mltLaneConfig),
      config.centerLine,
      body(
        config,
        'Your home screen is made of lanes: columns of apps, folders, and widgets.\nYou can add more any time, here\'s how they\'ll behave.',
      ),
      config.spacer,

      // Switches
      EzSwitchPair(
        config,
        valueKey: config.isDark ? darkPagesKey : lightPagesKey,
        text: l10n(config).dpsPages,
        afterChanged: (bool? value) async {
          if (value == null) return;
          await setLaneBool(
            config,
            darkKey: darkPagesKey,
            lightKey: lightPagesKey,
            value: value,
          );
          setState(() => usePage = value);
        },
      ),
      config.spacer,
      EzSwitchPair(
        config,
        valueKey: config.isDark ? darkWideTilesKey : lightWideTilesKey,
        text: l10n(config).gWideTiles,
        afterChanged: (bool? value) async {
          if (value == null) return;
          await setLaneBool(
            config,
            darkKey: darkWideTilesKey,
            lightKey: lightWideTilesKey,
            value: value,
          );
          setState(() => useWide = value);
        },
      ),
      config.spacer,

      // Description
      EzRichText(config, children: <InlineSpan>[
        EzPlainText(
          text: l10n(config).mltPagesEnabled,
          style: usePage ? focussed : hidden,
        ),
        EzPlainText(
          text: l10n(config).mltPagesDisabled,
          style: usePage ? hidden : focussed,
        ),
        config.richLine,
        EzPlainText(
          text: l10n(config).mltWideEnabled,
          style: useWide ? focussed : hidden,
        ),
        EzPlainText(
          text: l10n(config).mltWideWidth,
          style: usePage ? hidden : (useWide ? focussed : hidden),
        ),
        EzPlainText(
          text: l10n(config).mltAnywhere,
          style: useWide ? focussed : hidden,
        ),
        config.richLine,
        EzPlainText(
          text: l10n(config).mltWideDisabled,
          style: useWide ? hidden : focussed,
        ),
        EzPlainText(
          text: l10n(config).mltAutoWidth,
          style: usePage ? hidden : (useWide ? hidden : focussed),
        ),
        EzPlainText(
          text: l10n(config).mltOnlyButton,
          style: useWide ? hidden : focussed,
        ),
      ]),
    ];
  }

  // 5. Swipe apps
  List<Widget> swipePage(EzCP config, AppInfoProvider appInfo) => <Widget>[
        header(config),
        title(config, 'Quick launch'),
        config.centerLine,
        body(
          config,
          'Pick an app to open when you swipe left or right on your home screen.\n\nIf you have more than one page, just keep swiping once you reach the edge.',
        ),
        config.spacer,
        SwipeSelector(config, appInfo, left: true),
        config.spacer,
        SwipeSelector(config, appInfo, left: false),
        config.spacer,
        body(config, 'Long press an app to clear it.', style: config.labelStyle),
      ];

  // 6. Launch
  List<Widget> launchPage(EzCP config) {
    final _LaunchStyle? ls = launchStyle;

    return <Widget>[
      header(config),
      title(config, "You're all set!"),
      config.centerLine,
      body(
        config,
        "That's just the tip of the iceberg. Colors, fonts, folders, widgets, and way more are all yours to tweak.\n\nWhenever inspiration strikes, long press the home screen to get started.",
      ),
      config.separator,
      EzRow(
        config,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          EzElevatedIconButton(
            config,
            key: ValueKey<int>(ls?.hashCode ?? 0),
            onPressed: finish,
            style: ls?.buttonStyle(config),
            textStyle: ls?.textStyle(config),
            icon: EzIcon(
              config,
              Icons.rocket_launch,
              fill: (ls == null) ? null : EzSwitchColor(color: ls.primary),
            ),
            label: 'Launch',
          ),
          config.rowMargin,
          Semantics(
            label: 'Shuffling the button style in $countdown',
            child: ExcludeSemantics(
              child: Container(
                width: config.iconSize + config.padding,
                height: config.iconSize + config.padding,
                alignment: Alignment.center,
                decoration: config.boxDeco(
                  border: config.boxBorder(fill: config.primaryFill),
                  shape: BoxShape.circle,
                ),
                child: Text('$countdown', style: config.labelStyle),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget navRow(EzCP config) => EzRow(
        config,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Back
          (page > 0)
              ? EzTextIconButton(
                  config,
                  onPressed: () => goTo(page - 1),
                  label: 'Back',
                  icon: EzIcon(config, Icons.arrow_back),
                )
              : const SizedBox.shrink(),

          // Next
          (page < _lastPage)
              ? EzElevatedIconButton(
                  config,
                  onPressed: () => goTo(page + 1),
                  label: (page == 0) ? "Let's go" : 'Next',
                  icon: EzIcon(config, Icons.arrow_forward),
                )
              : const SizedBox.shrink(),
        ],
      );

  // Init //

  @override
  void initState() {
    super.initState();
    _config.addListener(onConfigChange);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) => (didPop) ? goTo(page - 1) : doNothing,
        child: Consumer2<EzCP, AppInfoProvider>(
          builder: (_, EzCP config, AppInfoProvider appInfo, __) {
            final List<Widget> children = switch (page) {
              0 => welcomePage(config),
              1 => themePage(config),
              2 => wallpaperPage(config),
              3 => lanePage(config),
              4 => swipePage(config, appInfo),
              _ => launchPage(config),
            };

            return LiminalScaffold(
              config,
              body: EzCol(children: <Widget>[
                Expanded(
                  child: EzFauxCarousel(
                    config,
                    position: page,
                    delta: delta,
                    child: EzScrollView(
                      config,
                      key: ValueKey<int>(page),
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        config.spacer,
                        ...children,
                        config.separator,
                      ],
                    ),
                  ),
                ),
                navRow(config),
                config.spacer,
              ]),
              isHome: true,
            );
          },
        ),
      );

  @override
  void dispose() {
    stopShuffle();
    super.dispose();
  }
}

/// Randomized [EzElevatedIconButton] styling
class _LaunchStyle {
  final Color primary;
  final EzSwitchColor border;
  final EzButtonShape shape;
  final double borderWidth;
  final double paddingScale;
  final String fontFamily;
  final double fontScale;
  final bool underline;

  const _LaunchStyle({
    required this.primary,
    required this.border,
    required this.shape,
    required this.borderWidth,
    required this.paddingScale,
    required this.fontFamily,
    required this.fontScale,
    required this.underline,
  });

  factory _LaunchStyle.random(Random random) {
    double getScalar() => (random.nextDouble() * 1.5) + 0.5;

    // Random seed
    final Color primary = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );

    // Same 1:4 gradient odds as EzCM.randomize
    final HSVColor hsv = HSVColor.fromColor(primary);
    final EzSwitchColor border = (random.nextInt(4) == 0)
        ? EzSwitchColor(
            gradient: LinearGradient(colors: <Color>[
              primary,
              hsv.withHue((hsv.hue + 36) % 360).toColor(),
              hsv.withHue((hsv.hue + 72) % 360).toColor(),
            ]),
          )
        : EzSwitchColor(color: primary.withValues(alpha: ywt.defaultBorderOpacity));

    final List<String> fonts = googleStyles.keys.toList();

    return _LaunchStyle(
      primary: primary,
      border: border,
      shape: EzButtonShape.values[random.nextInt(EzButtonShape.values.length)],
      borderWidth: random.nextDouble() * 3,
      paddingScale: getScalar(),
      fontFamily: fonts[random.nextInt(fonts.length)],
      fontScale: getScalar(),
      underline: random.nextBool(),
    );
  }

  ButtonStyle buttonStyle(EzCP config) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: config.isDark ? Brightness.dark : Brightness.light,
    );
    final Color onSurface = config.isDark ? Colors.white : Colors.black;

    return ElevatedButton.styleFrom(
      backgroundBuilder: (_, __, Widget? child) => child!,
      backgroundColor: scheme.surface,
      foregroundColor: onSurface,
      iconColor: primary,
      overlayColor: primary,
      padding: EdgeInsets.all(ywt.defaultMobilePadding * paddingScale),
      shape: ezOutlinedBorder(border, width: borderWidth, base: shape.shape),
      side: ezBorderSide(border, width: borderWidth),
    );
  }

  TextStyle? textStyle(EzCP config) => googleStyles[fontFamily]?.copyWith(
        fontSize: ywt.defaultBodySize * fontScale,
        color: config.isDark ? Colors.white : Colors.black,
        decoration: underline ? TextDecoration.underline : null,
      );
}
