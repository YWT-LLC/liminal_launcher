/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:math';
import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// TODO: l10n

const int _numPages = 6;
const int _lastPage = _numPages - 1;

const int _shuffleSeconds = 2;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Define the build data //

  int page = 0;
  int delta = 0;
  bool changes = false;

  bool twoHomes = EzManager.get(interlinkedKey);

  String darkPath = EzManager.get(darkBackgroundImageKey);
  String lightPath = EzManager.get(lightBackgroundImageKey);
  bool setColors = true;

  late bool usePage;
  late bool useWide;

  final Random random = Random();
  _LaunchStyle? launchStyle;
  Timer? shuffleTimer;
  int countdown = _shuffleSeconds;

  // Define custom functions //

  void stopShuffle() {
    shuffleTimer?.cancel();
    shuffleTimer = null;
  }

  void goTo(int target) {
    if (target < 0 || target > _lastPage || target == page) return;

    setState(() {
      delta = target > page ? 1 : -1;
      page = target;
    });

    (page == _lastPage)
        ? () {
            shuffleTimer?.cancel();
            countdown = _shuffleSeconds;

            shuffleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              if (!mounted) return;
              countdown -= 1;

              if (countdown <= 0) {
                setState(() {
                  launchStyle = _LaunchStyle.random(random);
                  countdown = _shuffleSeconds;
                });
              }
            });
          }
        : stopShuffle();
  }

  // Init //

  @override
  void initState() {
    super.initState();

    final EzProvider config = configWatcher(context);
    usePage = pages(config);
    useWide = wideTiles(config);
  }

  // Define the build //

  Widget header(EzProvider config) => EzText(
        config,
        text: '${page + 1}/$_numPages',
        textAlign: TextAlign.center,
        style: config.labelStyle,
      );

  Widget title(EzProvider config, String text) => EzText(
        config,
        text: text,
        textAlign: TextAlign.center,
        style: config.titleStyle,
      );

  Widget body(EzProvider config, String text) => EzText(
        config,
        text: text,
        textAlign: TextAlign.center,
        style: config.bodyStyle,
      );

  Widget label(EzProvider config, String text) => EzText(
        config,
        text: text,
        textAlign: TextAlign.center,
        style: config.labelStyle,
      );

  Widget navRow(EzProvider config) => Center(
        child: EzRow(
          config,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Back
            if (page > 0)
              EzTextIconButton(
                config,
                onPressed: () => goTo(page - 1),
                label: 'Back',
                icon: EzIcon(config, Icons.arrow_back),
              ),

            if (page != 0 && page != _lastPage) config.rowSeparator,

            // Next
            if (page < _lastPage)
              EzElevatedIconButton(
                config,
                onPressed: () async {
                  if (changes) {
                    await config.rebuildUI();
                    setState(() => changes = false);
                  }
                  goTo(page + 1);
                },
                label: 'Next',
                icon: EzIcon(config, Icons.arrow_forward),
              ),
          ],
        ),
      );

  // [0]: Welcome
  List<Widget> welcomePage(EzProvider config) => <Widget>[
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

        // Let it be gotten
        body(config, "Let's get started with some general settings."),
      ];

  // [1]: Wallpaper(s)
  Widget _wallpaperSetting(
    EzProvider config, {
    required bool setDark,
    required String label,
  }) =>
      EzCol(children: <Widget>[
        EzImageSetting(
          config,
          pathKey: setDark ? darkBackgroundImageKey : lightBackgroundImageKey,
          fitKey: setDark ? darkBackgroundFitKey : lightBackgroundFitKey,
          label: label,
          allowSolidColor: true,
          clearLabel: l10n(config).dpsUseOS,
          setColors: setColors,
        ),
        config.spacer,
        EzSwitchPair(
          config,
          key: ValueKey<String>('colors-$setDark-$setColors'),
          value: setColors,
          text: 'Match colors',
          onChanged: (bool? choice) {
            if (choice == null || choice == setColors) return;
            setState(() => setColors = choice);
          },
        ),
      ]);
  // TODO: fix: currently always overrides the current theme

  List<Widget> wallpaperPage(EzProvider config) => <Widget>[
        header(config),
        title(config, 'Wallpapers'),
        if ((darkPath == noImageValue) != (lightPath == noImageValue))
          label(config,
              "Heads up!\nUsing a custom (Liminal) wallpaper sets your system (Android) wallpaper to solid black.\nUnless you want one to be blank, it's probably best to set both."),
        config.spacer,
        EzRowCol(
          row: EzRow(
            config,
            reverseHands: false,
            children: <Widget>[
              _wallpaperSetting(config, setDark: true, label: 'Dark\nwallpaper'),
              config.rowSeparator,
              _wallpaperSetting(config, setDark: false, label: 'Light\nwallpaper'),
            ],
          ),
          col: EzCol(children: <Widget>[
            _wallpaperSetting(config, setDark: true, label: 'Dark\nwallpaper'),
            config.separator,
            _wallpaperSetting(config, setDark: false, label: 'Light\nwallpaper'),
          ]),
        ),
        config.separator,
        body(config,
            '"Match colors" will update the color scheme when an image is set.\n\nWant to keep your current wallpaper?\nJust skip this step.'),
      ];

  // [2]: Theme(s)
  List<Widget> themePage(EzProvider config) => <Widget>[
        header(config),
        title(config, 'Light and dark homes'),
        config.centerLine,
        body(config,
            "Liminal's appearance can/will always be unique based on theme mode.\n\nDo you want to also have unique home pages based on theme mode?"),
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
          selected: <bool>{twoHomes},
          showSelectedIcon: false,
          onSelectionChanged: (Set<bool>? choice) async {
            if (choice?.first == null || choice?.first == twoHomes) return;

            await EzManager.setBool(interlinkedKey, choice!.first);
            setState(() {
              twoHomes = choice.first;
              changes = true;
            });
          },
        ),
        config.spacer,
        label(config,
            'You can change this any time.\nWhen going from 2 > 1, you will have to choose which to keep.'),
      ];

  // [3]: Lanes
  List<Widget> lanePage(EzProvider config) {
    final TextStyle? focussed = config.bodyStyle;
    final TextStyle? hidden = config.labelStyle?.copyWith(color: config.outline);

    return <Widget>[
      header(config),
      title(config, 'Lane config'),
      // TODO: remove mltLaneConfig
      config.centerLine,
      body(config,
          'Your home screen is made of lanes...\nColumns filled with apps, folders, and widgets.\n\nHow do you want them to behave?'),

      // TODO: actually set both
      config.spacer,

      // Switches
      EzSwitchPair(
        config,
        valueKey: config.isDark ? darkPagesKey : lightPagesKey,
        text: l10n(config).dpsPages, // TODO: update dpsPages to "Lanes = pages"
        afterChanged: (bool? value) async {
          if (value == null) return;
          // TODO
          setState(() {
            usePage = value;
            changes = true;
          });
        },
      ),
      config.spacer,
      EzSwitchPair(
        config,
        valueKey: config.isDark ? darkWideTilesKey : lightWideTilesKey,
        text: l10n(config).gWideTiles,
        afterChanged: (bool? value) async {
          if (value == null) return;
          // TODO
          setState(() {
            useWide = value;
            changes = true;
          });
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

      if (twoHomes) ...<Widget>[
        config.centerLine,
        label(config, 'This will update both themes for now.\nYou can update either at any point.'),
      ],
    ];
  }

  // [4]: Swipe apps
  List<Widget> swipePage(EzProvider config, AppInfoProvider appInfo) => <Widget>[
        header(config),
        title(config, 'Quick launch'),
        config.centerLine,
        body(config, 'Pick apps that open when you overscroll left or right on the home screen.'),
        config.spacer,
        SwipeSelector(config, appInfo, left: true),
        config.spacer,
        SwipeSelector(config, appInfo, left: false),
        config.spacer,
        label(config, 'Long press an app to clear it.'),
      ];

  // [5]: Launch
  List<Widget> launchPage(EzProvider config) {
    final _LaunchStyle? ls = launchStyle;

    return <Widget>[
      header(config),
      title(config, "That's the basics!"),
      config.centerLine,
      body(config,
          'And, honestly: the tip of the iceberg.\n\nColors, fonts, button styles, spacing, widgets, and more are yours to personalize.\n\nAs usual, long press the home screen to start customizing.'),
      config.separator,
      EzRow(
        config,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // TODO: fix: shuffle doesn't work
          EzElevatedIconButton(
            config,
            key: ValueKey<int>(ls?.hashCode ?? 0),
            onPressed: () {
              stopShuffle();
              if (mounted) Navigator.of(context).pop(true);
            },
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
          // TODO: just use ez countdown timer
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

  // Return the build //

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) => (didPop) ? goTo(page - 1) : doNothing,
        child: Consumer2<EzProvider, AppInfoProvider>(
          builder: (_, EzProvider config, AppInfoProvider appInfo, __) {
            final List<Widget> children = switch (page) {
              0 => welcomePage(config),
              1 => wallpaperPage(config),
              2 => themePage(config),
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

    // Same 1:4 gradient odds as EzManager.randomize
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

  ButtonStyle buttonStyle(EzProvider config) {
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

  TextStyle? textStyle(EzProvider config) => googleStyles[fontFamily]?.copyWith(
        fontSize: ywt.defaultBodySize * fontScale,
        color: config.isDark ? Colors.white : Colors.black,
        decoration: underline ? TextDecoration.underline : null,
      );
}
