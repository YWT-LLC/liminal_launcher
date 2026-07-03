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

// TODO: let people control their quick-list, and let them set custom ones

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final Engine _engine;

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

    final WidgetSize storedWS = WSConfig.lookup(data[0]);
    _size = (storedWS == WidgetSize.system) ? bt2WS(config) : storedWS;

    _engine = Ignition.lookup(data[1]);
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

  Widget get icon => switch (widget._engine) {
        Engine.archive => const Icon(Icons.archive),
        Engine.baidu => const Icon(LineIcons.paw),
        Engine.bing => const Icon(Icons.search),
        Engine.ducks => const Icon(Icons.bathtub),
        Engine.ecosia => const Icon(LineIcons.tree),
        Engine.google => const Icon(LineIcons.googleLogo),
        Engine.naver => const Icon(LineIcons.neos), // close enough
        Engine.qwant => const Icon(LineIcons.quora), // ditto
        Engine.wikipedia => const Icon(LineIcons.wikipediaW),
        Engine.wolframAlpha => const Icon(LineIcons.equals),
        Engine.yahoo => const Icon(LineIcons.yahooLogo),
        Engine.yandex => const Icon(LineIcons.yandex),
        Engine.youTube => const Icon(LineIcons.youtube),
      };

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

  List<Widget> get engineChoices => Engine.values
      .map((Engine e) => EzMenuButton(
            widget.config,
            label: ezCamelToTitle(e.value),
            onPressed: () => widget.appInfo.updateWidget(
              widget.config,
              WidWidGetGet.search,
              TCC.searchEntry(widget._size, e),
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

    late final EzMenuButton remove =
        removeItem(widget.config, widget.appInfo, lane: widget.lane, index: widget.index);

    late final EzMenuButton resize = EzMenuButton(
      widget.config,
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String? choice = await resizeWidgetDialog(
          widget.config,
          context,
          widget._size,
        );
        if (choice == null) return;

        await widget.appInfo.updateWidget(
          widget.config,
          WidWidGetGet.search,
          TCC.searchEntry(WSConfig.lookup(choice), widget._engine),
          lane: widget.lane,
          index: widget.index,
        );
      },
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: icon,
                    onPressed: () => launchUrl(Uri.https(widget._engine.base, '/')),
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(widget.config, children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ezTextSize(
                              'Search bar',
                              context: context,
                              style: widget.config.bodyStyle,
                            ).width +
                            widget.config.padding,
                        maxHeight: appIconSize(widget.config),
                      ),
                      child: EzScrollBlocker(TextFormField(
                        controller: queryCon,
                        decoration: InputDecoration(hintText: widget._engine.value),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.webSearch,
                        onChanged: onChanged,
                        onFieldSubmitted: search,
                      )),
                    ),
                    widget.config.rowMargin,
                    EzIconButton(
                      widget.config,
                      icon: icon,
                      onPressed: () => search(queryCon.text),
                      onLongPress: () => canToggleMenu(widget.config, controller),
                    ),
                  ]),
            menuChildren: <Widget>[...engineChoices, resize, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1)
                moveDownLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
              resize,
              remove,
              if (numLanes > 1)
                moveUpLane(widget.config, widget.appInfo,
                    numLanes: numLanes, lane: widget.lane, index: widget.index),
            ],
            child: EzIconButton(
              widget.config,
              icon: const Icon(Icons.search),
              onPressed: () => canToggleMenu(widget.config, menuControl),
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
