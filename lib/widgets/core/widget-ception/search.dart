/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../utils/export.dart';
import '../../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

//* Core Widget *//

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final TileState state;
  final LimPos pos;
  final ValueNotifier<double>? rippleProgress;
  final void Function() editReset;

  final List<String> data;
  late final String _tp;
  late final WWGGSize _size;
  late final Engine _engine;
  late final List<Engine> _choices;

  SearchWidget(
    this.config,
    this.appInfo,
    this.state,
    this.pos,
    this.rippleProgress,
    this.editReset,
    this.data, {
    super.key,
  }) {
    _tp = data[0]; // Not used here; tracked so local updates don't clobber it
    _size = WSConfig.safeLookup(data[1]);

    final String storedCurr = data[2];
    if (storedCurr.contains(engineSplit)) {
      final List<String> details = storedCurr.split(engineSplit);

      _engine = Engine(
        name: details[0],
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          int.tryParse(details[1]) ?? Icons.search.codePoint,
          fontFamily: matIcons,
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
                fontFamily: matIcons,
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

  late TileState state = widget.state;
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
      setState(
        () => state = switch (state) {
          TileState.standard => TileState.groupEdit,
          _ => TileState.standard,
        },
      );

      final Duration animDur = ezDuration(widget.config.animDur);
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
    ezRootOverlay?.insert(overlayEntry!);
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
              WWGG.search,
              _searchEntry(
                tp: widget._tp,
                size: widget._size,
                engine: e,
                choices: widget._choices.map((Engine e) => e.value),
              ),
              lane: widget.pos.lane,
              index: widget.pos.index,
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

    late final double textWidth = ezTextSize(
      l10n(widget.config).gSearchBar,
      context: context,
      style: widget.config.bodyStyle,
    ).width;

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WWGGSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: Icon(widget._engine.icon),
                    onPressed: () => launchUrl(Uri.https(widget._engine.base, '/')),
                    onLongPress: () async => await canToggleMenu(widget.config, controller),
                  )
                : EzScrollBlocker(EzScrollView(
                    widget.config,
                    reverseHands: true,
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      EzTextField(
                        controller: queryCon,
                        constraints: BoxConstraints(
                          maxHeight: appIconSize(widget.config),
                          maxWidth: textWidth + widget.config.padding,
                        ),
                        errorConstraints: BoxConstraints(
                          maxWidth: (textWidth * 2) + widget.config.padding,
                        ),
                        hintText: widget._engine.name,
                        keyboardType: TextInputType.webSearch,
                        onChanged: onChanged,
                        onFieldSubmitted: search,
                        validator: null,
                      ),
                      widget.config.rowMargin,
                      EzIconButton(
                        widget.config,
                        icon: Icon(widget._engine.icon),
                        onPressed: () => search(queryCon.text),
                        onLongPress: () async => await canToggleMenu(widget.config, controller),
                      ),
                    ],
                  )),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              engineChoices: engineChoices,
              initConfig: _SearchConfig(
                tp: widget._tp,
                size: widget._size,
                engine: widget._engine,
                choices: widget._choices,
              ),
            ),
          ),
        _ => EditContainer(
            widget.config,
            subAlign: widget.pos.subAlign,
            menuControl: menuControl,
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              engineChoices: <Widget>[],
              initConfig: _SearchConfig(
                tp: widget._tp,
                size: widget._size,
                engine: widget._engine,
                choices: widget._choices,
              ),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required TileState state,
  required void Function() editReset,
  required int numLanes,
  required LimPos pos,
  required List<Widget> engineChoices,
  required _SearchConfig initConfig,
}) =>
    <Widget>[
      // Engines
      ...engineChoices,

      // Edit
      _EditSearch(
        config,
        appInfo,
        pContext: context,
        initConfig: initConfig,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: l10n(config).gDupe,
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: () async {
            if (!ezRootIsMounted) return;
            await _openEdits(
              config,
              appInfo: appInfo,
              pContext: ezRootContext,
              initConfig: initConfig,
              lane: pos.lane,
              index: pos.index,
            );
          },
          lane: pos.lane,
          index: pos.index,
        ),
      ),

      // Reposition
      reposition(config, appInfo, pos, stateCheck: editReset),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, pos, numLanes: numLanes),
        moveUpLane(config, appInfo, pos, numLanes: numLanes),
      ],

      // Remove
      removeItem(config, appInfo, pos),
    ];

//* Add Widget *//

class AddSearch extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int lane;
  final WWGGSize size;

  const AddSearch(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.lane,
    required this.size,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WWGG.search,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _SearchConfig(
            tp: nullTPS,
            size: size,
            engine: ecosia,
            choices: Engine.defaultOrder,
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => (size == WWGGSize.button)
      ? EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.search))
      : GestureDetector(
          onTap: onTap,
          child: EzScrollView(
            config,
            reverseHands: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              EzTextField(
                constraints: BoxConstraints(
                  maxHeight: appIconSize(config),
                  maxWidth:
                      ezTextSize(l10n(config).gSearchBar, context: context, style: config.bodyStyle)
                              .width +
                          config.padding,
                ),
                hintText: l10n(config).gSearch,
                onTap: onTap,
                readOnly: true,
                validator: null,
              ),
              config.rowMargin,
              EzIconButton(config, icon: const Icon(Icons.search), onPressed: onTap),
            ],
          ),
        );
}

String defaultSearchEntry() => _searchEntry(
      tp: nullTPS,
      size: WWGGSize.tile,
      engine: ecosia,
      choices: Engine.defaultOrder.map((Engine e) => e.value),
    );

String _searchEntry({
  required String tp,
  required WWGGSize size,
  required Engine engine,
  required Iterable<String> choices,
}) =>
    <String>[
      tp,
      size.value,
      engine.value,
      ...choices,
    ].join(configSplit);

//* Edit Widget *//

class _SearchConfig {
  final String tp;
  final WWGGSize size;
  final Engine engine;
  final List<Engine> choices;

  _SearchConfig({
    required this.tp,
    required this.size,
    required this.engine,
    required this.choices,
  });
}

Future<void> _openEdits(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required _SearchConfig initConfig,
  required int lane,
  required int index,
}) async {
  final EdgeInsets wrapPadding = EzInsets.wrap(config.spacing);

  WWGGSize size = initConfig.size;
  Engine curr = initConfig.engine;

  final List<Engine> shown = List<Engine>.from(initConfig.choices);
  final List<Engine> hidden = List<Engine>.from(Engine.defaultOrder);
  hidden.removeWhere((Engine e) => initConfig.choices.contains(e));

  await ezModal(
    config,
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
        config,
        children: <Widget>[
          // Size
          EzFlipFlop(
            config,
            onLabel: l10n(config).gTile,
            offLabel: l10n(config).gButton,
            init: initConfig.size == WWGGSize.tile,
            onChanged: (bool tile) => setModal(() => size = tile ? WWGGSize.tile : WWGGSize.button),
          ),
          config.separator,

          // Shown
          Text(l10n(config).gShown, textAlign: TextAlign.center, style: config.labelStyle),
          EzWrap(
            children: <Widget>[
              ...shown.map(
                (Engine e) => Padding(
                  padding: wrapPadding,
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
                ),
              ),
              Padding(
                padding: wrapPadding,
                child: EzElevatedIconButton(
                  key: const ValueKey<String>('addNew'),
                  config,
                  icon: EzIcon(config, Icons.add),
                  label: l10n(config).srcCustom,
                  onPressed: () async {
                    final TextEditingController nameCon = TextEditingController();
                    IconData icon = Icons.search;
                    final TextEditingController baseCon = TextEditingController();
                    final TextEditingController pathCon = TextEditingController();
                    final TextEditingController queryCon = TextEditingController();

                    final double fieldHeight = appIconSize(config);
                    final double fieldWidth = widthOf(mCon) / 2;
                    double bottomSpace = config.spacing * 2;

                    final Engine? custom = await ezModal(
                      config,
                      context: pContext,
                      builder: (_) => StatefulBuilder(
                        builder: (BuildContext customCon, StateSetter setCustom) {
                          void shrink(_) => setCustom(() => bottomSpace = (config.spacing * 2));

                          Future<void> grow() async {
                            // Wait a bit for the keyboard to open
                            await Future<void>.delayed(keyTime);
                            setCustom(
                              () => bottomSpace = ((config.spacing * 2) +
                                  MediaQuery.of(pContext).viewInsets.bottom),
                            );
                          }

                          return ezModalScroll(
                            config,
                            children: <Widget>[
                              // Name && icon
                              EzRow(
                                config,
                                children: <Widget>[
                                  EzTextField(
                                    controller: nameCon,
                                    constraints: BoxConstraints.tightFor(
                                      height: fieldHeight,
                                      width: fieldWidth,
                                    ),
                                    errorConstraints: BoxConstraints.tightFor(width: fieldWidth),
                                    hintText: '${l10n(config).srcName}(Ecosia)',
                                    onFieldSubmitted: shrink,
                                    onTap: grow,
                                    validator: (String? check) => validateName(config, check),
                                  ),
                                  config.rowMargin,
                                  EzIconButton(
                                    config,
                                    icon: Icon(icon),
                                    onPressed: () async {
                                      final IconData? choice = await chooseIcon(config, pContext);
                                      if (choice != null) setCustom(() => icon = choice);
                                    },
                                  ),
                                ],
                              ),
                              config.spacer,

                              // Base site
                              EzTextField(
                                controller: baseCon,
                                constraints: BoxConstraints.tightFor(
                                  height: fieldHeight,
                                  width: fieldWidth,
                                ),
                                errorConstraints: BoxConstraints.tightFor(width: fieldWidth),
                                hintText: '${l10n(config).srcBase}(ecosia.org)',
                                onFieldSubmitted: shrink,
                                onTap: grow,
                                validator: (String? check) => validateName(config, check),
                              ),
                              config.spacer,

                              // Path
                              EzTextField(
                                controller: pathCon,
                                constraints: BoxConstraints.tightFor(
                                  height: fieldHeight,
                                  width: fieldWidth,
                                ),
                                errorConstraints: BoxConstraints.tightFor(width: fieldWidth),
                                hintText: '${l10n(config).srcPath}(/search)',
                                onFieldSubmitted: shrink,
                                onTap: grow,
                                validator: (String? check) => validateName(config, check),
                              ),
                              config.spacer,

                              // Parameter
                              EzTextField(
                                controller: queryCon,
                                constraints: BoxConstraints.tightFor(
                                  height: fieldHeight,
                                  width: fieldWidth,
                                ),
                                errorConstraints: BoxConstraints.tightFor(width: fieldWidth),
                                hintText: '${l10n(config).srcParameter}(q)',
                                onFieldSubmitted: shrink,
                                onTap: grow,
                                validator: (String? check) => validateName(config, check),
                              ),
                              config.separator,

                              // Add/cancel
                              EzRow(
                                config,
                                children: <Widget>[
                                  EzTextIconButton(
                                    config,
                                    icon: EzIcon(config, Icons.cancel_outlined),
                                    label: config.ezL10n.gCancel,
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
                                    label: l10n(config).gAdd,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: config.colors.surfaceContainer,
                                    ),
                                    onPressed: () {
                                      if (nameCon.text.trim().isEmpty) {
                                        ezSnackBar(
                                          config,
                                          context: customCon,
                                          message: l10n(config).srcNonEmpty,
                                        );
                                        return;
                                      }

                                      if (shown.any(
                                        (Engine e) => (!Engine.defaultSet.contains(e) &&
                                            e.name == nameCon.text),
                                      )) {
                                        ezSnackBar(
                                          config,
                                          context: customCon,
                                          message: l10n(config).srcSameName,
                                        );
                                        return;
                                      }

                                      Navigator.of(customCon).pop(
                                        Engine(
                                          name: nameCon.text,
                                          icon: icon,
                                          id: 'zz_custom_${nameCon.text}',
                                          base: baseCon.text,
                                          path: pathCon.text,
                                          query: queryCon.text,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              config.spacer,

                              // Warning
                              Text(
                                l10n(config).srcPlayResponsibly,
                                textAlign: TextAlign.center,
                                style: config.labelStyle,
                              ),
                              EzSpacer(bottomSpace),
                            ],
                          );
                        },
                      ),
                    );

                    if (custom != null) shown.add(custom);
                  },
                ),
              ),
            ],
          ),
          EzTitledDivider(
            config,
            title:
                Text(l10n(config).gHidden, textAlign: TextAlign.center, style: config.labelStyle),
            height: config.spacing * 2,
          ),

          // Hidden
          EzWrap(
            children: hidden
                .map((Engine e) => Padding(
                      padding: wrapPadding,
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
        ],
      ),
    ),
  );

  await appInfo.updateWidget(
    config,
    WWGG.search,
    _searchEntry(
      tp: initConfig.tp,
      size: size,
      engine: curr,
      choices: shown.map((Engine e) => e.value),
    ),
    lane: lane,
    index: index,
  );
}

class _EditSearch extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final _SearchConfig initConfig;
  final int lane;
  final int index;

  const _EditSearch(
    this.config,
    this.appInfo, {
    required this.pContext,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
        onPressed: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
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
