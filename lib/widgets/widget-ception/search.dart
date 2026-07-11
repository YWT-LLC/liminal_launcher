/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final Engine _engine;
  late final List<Engine> _choices;

  SearchWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data =
        appInfo.homeItem(config, lane: lane, index: index).split(widgetSplit)[1].split(configSplit);

    final WidgetSize storedWS = WSConfig.safeLookup(data[0]);
    _size = (storedWS == WidgetSize.system) ? bt2WS(config) : storedWS;

    final String storedCurr = data[1];
    if (storedCurr.contains(engineSplit)) {
      final List<String> details = storedCurr.split(engineSplit);

      _engine = Engine(
        name: details[0],
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          int.tryParse(details[1]) ?? Icons.search.codePoint,
          fontFamily: 'MaterialIcons',
        ),
        id: details[2],
        base: details[3],
        path: details[4],
        query: details[5],
      );
    } else {
      _engine = Engine.library[storedCurr] ?? ecosia;
    }

    final List<String> storedChoices = data.sublist(2);
    _choices = storedChoices
        .map((String entry) {
          if (entry.contains(engineSplit)) {
            final List<String> details = entry.split(engineSplit);

            return Engine(
              name: details[0],
              icon: IconData(
                // ignore: non_const_argument_for_const_parameter
                int.tryParse(details[1]) ?? Icons.search.codePoint,
                fontFamily: 'MaterialIcons',
              ),
              id: details[2],
              base: details[3],
              path: details[4],
              query: details[5],
            );
          } else {
            return Engine.library[entry];
          }
        })
        .whereType<Engine>()
        .toList();
  }

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  final TextEditingController queryCon = TextEditingController();
  OverlayEntry? overlayEntry;

  // Define custom functions //

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }

    final Offset wya = ezWya(context);
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dy <= (widget.rippleProgress!.value * heightOf(context))) {
      setState(() => state = switch (state) {
            AppState.standard => AppState.groupEdit,
            _ => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  void onChanged(String text) => (text.isEmpty)
      ? removeOverlay()
      : ((overlayEntry == null) ? showOverlay() : overlayEntry!.markNeedsBuild());

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: widget.config.marginVal,
        right: widget.config.marginVal,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.all(widget.config.marginVal),
              decoration: BoxDecoration(
                color: widget.config.colors.surfaceContainer,
                border: Border.all(
                  color: widget.config.colors.secondaryContainer,
                  width: widget.config.borderWidth,
                ),
                borderRadius: widget.config.textRadius,
              ),
              child: Text(
                queryCon.text,
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    ezRootNav.currentState?.overlay?.insert(overlayEntry!);
  }

  Future<void> search(String text) async {
    await launchUrl(Uri.https(
      widget._engine.base,
      widget._engine.path,
      text.trim().isEmpty ? null : <String, dynamic>{widget._engine.query: text.trim()},
    ));

    queryCon.clear();
    removeOverlay();
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  List<Widget> get engineChoices => widget._choices
      .map((Engine e) => EzMenuButton(
            widget.config,
            label: e.name,
            onPressed: () => widget.appInfo.updateWidget(
              widget.config,
              WidWidGetGet.search,
              TCC.searchEntry(widget._size, e, widget._choices.map((Engine e) => e.value)),
              lane: widget.lane,
              index: widget.index,
            ),
          ))
      .toList();

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    late final double fieldHeight = appIconSize(widget.config);
    late final double textWidth =
        ezTextSize('Search bar', context: context, style: widget.config.bodyStyle).width;

    late final _SearchConfig init = _SearchConfig(
      fieldHeight: fieldHeight,
      size: widget._size,
      engine: widget._engine,
      choices: widget._choices,
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        AppState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: Icon(widget._engine.icon),
                    onPressed: () => launchUrl(Uri.https(widget._engine.base, '/')),
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(widget.config, children: <Widget>[
                    EzScrollBlocker(EzTextField(
                      controller: queryCon,
                      constraints: BoxConstraints(
                        maxHeight: fieldHeight,
                        maxWidth: textWidth + widget.config.padding,
                      ),
                      errorConstraints: BoxConstraints(
                        maxHeight: fieldHeight,
                        maxWidth: (textWidth * 2) + widget.config.padding,
                      ),
                      hintText: widget._engine.name,
                      keyboardType: TextInputType.webSearch,
                      onChanged: onChanged,
                      onFieldSubmitted: search,
                      validator: null,
                    )),
                    widget.config.rowMargin,
                    EzIconButton(
                      widget.config,
                      icon: Icon(widget._engine.icon),
                      onPressed: () => search(queryCon.text),
                      onLongPress: () => canToggleMenu(widget.config, controller),
                    ),
                  ]),
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditSearch(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initConfig: init,
                lane: widget.lane,
                index: widget.index,
              ),
              local: engineChoices,
              numLanes: numLanes,
              lane: widget.lane,
              index: widget.index,
            ),
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: widgetMC(
              widget.config,
              widget.appInfo,
              _EditSearch(
                widget.config,
                widget.appInfo,
                parentCon: context,
                initConfig: init,
                lane: widget.lane,
                index: widget.index,
              ),
              numLanes: numLanes,
              lane: widget.lane,
              index: widget.index,
            ),
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.search),
              onPressed: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    removeOverlay();
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}

class AddSearch extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final WidgetSize save;
  final WidgetSize preview;

  const AddSearch(
    this.config,
    this.appInfo,
    this.lane, {
    super.key,
    required this.save,
    required this.preview,
  });

  void onTap() => appInfo.addSearch(config, lane);

  @override
  Widget build(BuildContext context) => (preview == WidgetSize.button)
      ? EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.search))
      : GestureDetector(
          onTap: onTap,
          child: EzRow(config, children: <Widget>[
            EzTextField(
              constraints: BoxConstraints(
                maxWidth:
                    ezTextSize('Search bar', context: context, style: config.bodyStyle).width +
                        config.padding,
                maxHeight: appIconSize(config),
              ),
              hintText: 'Search',
              onTap: onTap,
              readOnly: true,
              validator: null,
            ),
            config.rowMargin,
            EzIconButton(
              config,
              icon: const Icon(Icons.search),
              onPressed: onTap,
            ),
          ]),
        );
}

class _EditSearch extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext parentCon;
  final _SearchConfig initConfig;
  final int lane;
  final int index;

  const _EditSearch(
    this.config,
    this.appInfo, {
    required this.parentCon,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        icon: EzIcon(config, Icons.edit),
        onPressed: () async {
          WidgetSize size = initConfig.size;
          Engine curr = initConfig.engine;

          final List<Engine> shown = List<Engine>.from(initConfig.choices);
          final List<Engine> hidden = List<Engine>.from(Engine.defaultOrder);
          hidden.removeWhere((Engine e) => initConfig.choices.contains(e));

          await ezModal(
            config,
            context: parentCon,
            builder: (_) => StatefulBuilder(
              builder: (BuildContext mCon, StateSetter setModal) =>
                  ezModalScroll(config, children: <Widget>[
                // Size
                EzRow(
                  config,
                  children: <Widget>[
                    Flexible(
                      child: Text('Size:', textAlign: TextAlign.center, style: config.labelStyle),
                    ),
                    config.rowMargin,
                    EzDropdownMenu<WidgetSize>(
                      config,
                      enableSearch: false,
                      initialSelection: size,
                      widthEntry: WidgetSize.system.value,
                      dropdownMenuEntries: WidgetSize.values
                          .map((WidgetSize ws) => DropdownMenuEntry<WidgetSize>(
                                value: ws,
                                label: ezCamelToTitle(ws.value),
                              ))
                          .toList(),
                      onSelected: (WidgetSize? choice) {
                        if (choice == null) return;
                        setModal(() => size = choice);
                      },
                    )
                  ],
                ),
                config.spacer,

                // Shown
                Text('Shown', textAlign: TextAlign.center, style: config.labelStyle),
                EzWrap(children: <Widget>[
                  ...shown.map((Engine e) => Padding(
                        padding: EzInsets.wrap(config.spacing),
                        child: EzElevatedIconButton(
                          config,
                          key: ValueKey<Engine>(e),
                          enabled: shown.length > 1,
                          icon: EzIcon(config, e.icon),
                          label: e.name,
                          onPressed: () {
                            shown.remove(e);
                            hidden.add(e);
                            hidden.sort();
                            setModal(() {});
                          },
                          onLongPress: Engine.defaultSet.contains(e)
                              ? null
                              : () {
                                  shown.remove(e);
                                  if (initConfig.engine == e) curr = shown.first;
                                  setModal(() {});
                                },
                        ),
                      )),
                  Padding(
                    padding: EzInsets.wrap(config.spacing),
                    child: EzElevatedIconButton(
                      key: const ValueKey<String>('addNew'),
                      config,
                      icon: EzIcon(config, Icons.add),
                      label: 'Custom',
                      onPressed: () async {
                        final TextEditingController nameCon = TextEditingController();
                        IconData icon = Icons.search;
                        final TextEditingController baseCon = TextEditingController();
                        final TextEditingController pathCon = TextEditingController();
                        final TextEditingController queryCon = TextEditingController();
                        final double fieldWidth = widthOf(mCon) / 2;

                        double bottomSpace = config.spacing * 2;

                        final Engine? custom = await ezModal(
                          config,
                          context: parentCon,
                          builder: (_) => StatefulBuilder(
                            builder: (BuildContext customCon, StateSetter setCustom) {
                              void shrink(_) => setCustom(() => bottomSpace = (config.spacing * 2));

                              Future<void> grow() async {
                                // Wait a bit for the keyboard to open
                                await Future<void>.delayed(const Duration(milliseconds: 300));

                                setCustom(() => bottomSpace = ((config.spacing * 2) +
                                    MediaQuery.of(parentCon).viewInsets.bottom));
                              }

                              return ezModalScroll(config, children: <Widget>[
                                // Name && icon
                                EzRow(config, children: <Widget>[
                                  EzTextField(
                                    controller: nameCon,
                                    constraints: BoxConstraints.tightFor(
                                      height: initConfig.fieldHeight,
                                      width: fieldWidth,
                                    ),
                                    hintText: 'Name (Ecosia)',
                                    onFieldSubmitted: shrink,
                                    onTap: grow,
                                    validator: validateName,
                                  ),
                                  config.rowMargin,
                                  EzIconButton(
                                    config,
                                    icon: Icon(icon),
                                    onPressed: () async {
                                      final IconData? choice = await chooseIcon(config, parentCon);
                                      if (choice != null) setCustom(() => icon = choice);
                                    },
                                  ),
                                ]),
                                config.spacer,

                                // Base site
                                EzTextField(
                                  controller: baseCon,
                                  constraints: BoxConstraints.tightFor(
                                    height: initConfig.fieldHeight,
                                    width: fieldWidth,
                                  ),
                                  hintText: 'Base site (ecosia.org)',
                                  onFieldSubmitted: shrink,
                                  onTap: grow,
                                  validator: validateName,
                                ),
                                config.spacer,

                                // Path
                                EzTextField(
                                  controller: pathCon,
                                  constraints: BoxConstraints.tightFor(
                                    height: initConfig.fieldHeight,
                                    width: fieldWidth,
                                  ),
                                  hintText: 'Path (/search)',
                                  onFieldSubmitted: shrink,
                                  onTap: grow,
                                  validator: validateName,
                                ),
                                config.spacer,

                                // Parameter
                                EzTextField(
                                  controller: queryCon,
                                  constraints: BoxConstraints.tightFor(
                                    height: initConfig.fieldHeight,
                                    width: fieldWidth,
                                  ),
                                  hintText: 'Parameter (q)',
                                  onFieldSubmitted: shrink,
                                  onTap: grow,
                                  validator: validateName,
                                ),
                                config.separator,

                                // Add/cancel
                                EzRow(config, children: <Widget>[
                                  EzTextIconButton(
                                    config,
                                    icon: EzIcon(config, Icons.cancel_outlined),
                                    label: 'Cancel',
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: config.colors.surfaceContainer,
                                    ),
                                    onPressed: () => Navigator.of(customCon).pop(),
                                  ),
                                  config.rowSpacer,
                                  EzTextIconButton(
                                    config,
                                    icon: EzIcon(config, Icons.done),
                                    label: 'Add',
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: config.colors.surfaceContainer,
                                    ),
                                    onPressed: () {
                                      if (nameCon.text.trim().isEmpty) {
                                        ezSnackBar(config,
                                            context: customCon, message: 'Need a non-empty name.');
                                        return;
                                      }

                                      if (shown.any((Engine e) => (!Engine.defaultSet.contains(e) &&
                                          e.name == nameCon.text))) {
                                        ezSnackBar(config,
                                            context: customCon,
                                            message:
                                                'A custom entry with that name already exists.\nPlease change the name and try again.');
                                        return;
                                      }

                                      Navigator.of(customCon).pop(Engine(
                                        name: nameCon.text,
                                        icon: icon,
                                        id: 'zz_custom_${nameCon.text}',
                                        base: baseCon.text,
                                        path: pathCon.text,
                                        query: queryCon.text,
                                      ));
                                    },
                                  ),
                                ]),
                                config.spacer,

                                // Warning
                                Text(
                                  'Liminal does minimal validation of these custom inputs.\nPlay at your own risk.',
                                  textAlign: TextAlign.center,
                                  style: config.labelStyle,
                                ),
                                EzSpacer(bottomSpace),
                              ]);
                            },
                          ),
                        );

                        if (custom != null) shown.add(custom);
                      },
                    ),
                  ),
                ]),
                EzTitledDivider(
                  Text('Hidden', textAlign: TextAlign.center, style: config.labelStyle),
                  height: config.spacing * 2,
                  margin: config.marginVal,
                ),

                // Hidden
                EzWrap(
                  children: hidden
                      .map((Engine e) => Padding(
                            padding: EzInsets.wrap(config.spacing),
                            child: EzElevatedIconButton(
                              key: ValueKey<Engine>(e),
                              config,
                              icon: EzIcon(config, e.icon),
                              label: e.name,
                              onPressed: () {
                                hidden.remove(e);
                                shown.add(e);
                                shown.sort();
                                setModal(() {});
                              },
                              onLongPress: Engine.defaultSet.contains(e)
                                  ? null
                                  : () {
                                      shown.remove(e);
                                      if (initConfig.engine == e) curr = shown.first;
                                      setModal(() {});
                                    },
                            ),
                          ))
                      .toList(),
                ),
                hidden.isEmpty ? config.separator : config.spacer,
              ]),
            ),
          );

          await appInfo.updateWidget(
            config,
            WidWidGetGet.search,
            TCC.searchEntry(size, curr, shown.map((Engine e) => e.value)),
            lane: lane,
            index: index,
          );
        },
      );
}

class _SearchConfig {
  final double fieldHeight;
  final WidgetSize size;
  final Engine engine;
  final List<Engine> choices;

  _SearchConfig({
    required this.fieldHeight,
    required this.size,
    required this.engine,
    required this.choices,
  });
}

//* Engine enum *//

class Engine implements Comparable<Engine> {
  final String name;
  final IconData icon;
  final String id;
  final String base;
  final String path;
  final String query;

  // A constant constructor allows us to define immutable static instances.
  const Engine({
    required this.name,
    required this.icon,
    required this.id,
    required this.base,
    required this.path,
    required this.query,
  });

  static const List<Engine> defaultOrder = <Engine>[
    archive,
    baidu,
    bing,
    ducks,
    ecosia,
    google,
    naver,
    qwant,
    wikipedia,
    wolframAlpha,
    yahoo,
    yandex,
    youTube,
  ];

  static const List<Engine> defaultSet = <Engine>[
    archive,
    baidu,
    bing,
    ducks,
    ecosia,
    google,
    naver,
    qwant,
    wikipedia,
    wolframAlpha,
    yahoo,
    yandex,
    youTube,
  ];

  static const Map<String?, Engine> library = <String?, Engine>{
    _archive: archive,
    _baidu: baidu,
    _bing: bing,
    _ducks: ducks,
    _ecosia: ecosia,
    _google: google,
    _naver: naver,
    _qwant: qwant,
    _wikipedia: wikipedia,
    _wolframAlpha: wolframAlpha,
    _yahoo: yahoo,
    _yandex: yandex,
    _youTube: youTube,
  };

  String get value => defaultSet.contains(this)
      ? id
      : <String>[name, icon.codePoint.toString(), id, base, path, query].join(engineSplit);

  @override
  int compareTo(Engine other) => id.compareTo(other.id);

  @override
  bool operator ==(Object other) => other is Engine && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

const String _archive = 'archive';
const Engine archive = Engine(
  name: 'Archive.org',
  icon: Icons.archive,
  id: _archive,
  base: 'archive.org',
  path: '/search',
  query: 'query',
);

const String _baidu = 'baidu';
const Engine baidu = Engine(
  name: 'Baidu',
  icon: LineIcons.paw,
  id: _baidu,
  base: 'baidu.com',
  path: '/s',
  query: 'wd',
);

const String _bing = 'bing';
const Engine bing = Engine(
  name: 'Bing',
  icon: Icons.search,
  id: _bing,
  base: 'bing.com',
  path: '/search',
  query: 'q',
);

const String _ducks = 'ducks';
const Engine ducks = Engine(
  name: 'DuckDuckGo',
  icon: Icons.bathtub,
  id: _ducks,
  base: 'duckduckgo.com',
  path: '/',
  query: 'q',
);

const String _ecosia = 'ecosia';
const Engine ecosia = Engine(
  name: 'Ecosia',
  icon: LineIcons.tree,
  id: _ecosia,
  base: 'ecosia.org',
  path: '/search',
  query: 'q',
);

const String _google = 'google';
const Engine google = Engine(
  name: 'Google',
  icon: LineIcons.googleLogo,
  id: _google,
  base: 'google.com',
  path: '/search',
  query: 'q',
);

const String _naver = 'naver';
const Engine naver = Engine(
  name: 'Naver',
  icon: LineIcons.neos,
  id: _naver,
  base: 'search.naver.com',
  path: '/search.naver',
  query: 'query',
);

const String _qwant = 'qwant';
const Engine qwant = Engine(
  name: 'Qwant',
  icon: LineIcons.quora,
  id: _qwant,
  base: 'qwant.com',
  path: '/',
  query: 'q',
);

const String _wikipedia = 'wikipedia';
const Engine wikipedia = Engine(
  name: 'Wikipedia',
  icon: LineIcons.wikipediaW,
  id: _wikipedia,
  base: 'wikipedia.org',
  path: '/w/index.php',
  query: 'search',
);

const String _wolframAlpha = 'wolframAlpha';
const Engine wolframAlpha = Engine(
  name: 'Wolfram Alpha',
  icon: LineIcons.equals,
  id: _wolframAlpha,
  base: 'wolframalpha.com',
  path: '/input',
  query: 'i',
);

const String _yahoo = 'yahoo';
const Engine yahoo = Engine(
  name: 'Yahoo',
  icon: LineIcons.yahooLogo,
  id: _yahoo,
  base: 'search.yahoo.com',
  path: '/search',
  query: 'p',
);

const String _yandex = 'yandex';
const Engine yandex = Engine(
  name: 'Yandex',
  icon: LineIcons.yandex,
  id: _yandex,
  base: 'yandex.com',
  path: '/search/',
  query: 'text',
);

const String _youTube = 'youTube';
const Engine youTube = Engine(
  name: 'YouTube',
  icon: LineIcons.youtube,
  id: _youTube,
  base: 'youtube.com',
  path: '/results',
  query: 'search_query',
);

/// :01000101: == :E:
const String engineSplit = ':01000101:';
