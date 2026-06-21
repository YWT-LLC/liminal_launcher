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

// TODO: states, edits, && anim switches

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final WidgetSize _size;
  late final String _storedEngine;

  SearchWidget(
    this.config,
    this.appInfo,
    this.lane,
    this.index,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;

    _storedEngine = data[2];
  }

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late Engine engine = Ignition.lookup(widget._storedEngine);
  late final TextEditingController queryCon;
  OverlayEntry? overlayEntry;

  Widget get icon => switch (engine) {
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
            AppState.standard || AppState.singleEdit => AppState.groupEdit,
            _ => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  void toggleChoices(MenuController c) => c.isOpen ? c.close() : c.open();

  void onChanged() {
    final String text = queryCon.text.trim();

    (text.isNotEmpty)
        ? ((overlayEntry == null) ? showOverlay() : overlayEntry?.markNeedsBuild())
        : removeOverlay();
  }

  void showOverlay() {
    overlayEntry = textFormOverlay(widget.config, queryCon.text);
    ezRootNav.currentState?.overlay?.insert(overlayEntry!);
  }

  Future<void> search(String text) async {
    await launchUrl(Uri.https(
      engine.base,
      engine.path,
      text.trim().isEmpty ? null : <String, dynamic>{engine.query: text.trim()},
    ));

    queryCon.clear();
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  List<Widget> get engineMB => Engine.values
      .map((Engine e) => EzMenuButton(
            widget.config,
            label: ezCamelToTitle(e.value),
            onPressed: () async {
              setState(() => engine = e);
              await widget.appInfo.updateWidget(
                widget.config,
                WidWidGetGet.search,
                widget._size,
                extra: <String>[e.value],
                lane: widget.lane,
                index: widget.index,
                notify: false,
              );
            },
          ))
      .toList();

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);

    queryCon = TextEditingController();
    queryCon.addListener(onChanged);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return switch (widget.state) {
      AppState.standard || AppState.singleEdit => MenuAnchor(
          builder: (_, MenuController controller, __) => switch (widget._size) {
            WidgetSize.button => EzIconButton(
                widget.config,
                icon: icon,
                onPressed: () => launchUrl(Uri.https(engine.base, '/')),
                onLongPress: () => toggleChoices(controller),
              ),
            _ => EzRow(
                widget.config,
                children: <Widget>[
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
                    child: NotificationListener<ScrollNotification>(
                      // Block scroll notifications
                      onNotification: (ScrollNotification notification) => true,
                      child: TextFormField(
                        controller: queryCon,
                        decoration: InputDecoration(hintText: engine.value),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        onFieldSubmitted: search,
                      ),
                    ),
                  ),
                  widget.config.rowMargin,
                  EzIconButton(
                    widget.config,
                    icon: icon,
                    onPressed: () => search(queryCon.text),
                    onLongPress: () => toggleChoices(controller),
                  ),
                ],
              ),
          },
          menuChildren: engineMB, // TODO: Add remove and resize
        ),
      _ => EditContainer(
          widget.config,
          menuControl: menuControl,
          menuChildren: <Widget>[], // TODO: Ditto + move lane when relevant
          child: EzRow(widget.config, children: <Widget>[
            icon,
            widget.config.rowSpacer,
            EzIconButton(
              widget.config,
              icon: EzIcon(widget.config, Icons.delete),
              onPressed: () => widget.appInfo
                  .deleteWidget(widget.config, lane: widget.lane, index: widget.index),
            ),
          ]),
        ),
    };
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    queryCon.removeListener(onChanged);
    queryCon.dispose();
    removeOverlay();
    super.dispose();
  }
}
