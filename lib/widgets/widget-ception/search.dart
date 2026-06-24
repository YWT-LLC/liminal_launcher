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
  late WidgetSize size = widget._size;

  final TextEditingController queryCon = TextEditingController();
  OverlayEntry? overlayEntry;

  late Engine engine = Ignition.lookup(widget._storedEngine);

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
      engine.base,
      engine.path,
      text.trim().isEmpty ? null : <String, dynamic>{engine.query: text.trim()},
    ));

    queryCon.clear();
    removeOverlay();
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  List<Widget> get engineMC => Engine.values
      .map((Engine e) => EzMenuButton(
            widget.config,
            label: ezCamelToTitle(e.value),
            onPressed: () async {
              await widget.appInfo.updateWidget(
                widget.config,
                WidWidGetGet.search,
                size,
                extra: <String>[e.value],
                lane: widget.lane,
                index: widget.index,
              );
              setState(() => engine = e);
            },
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

    late final EzMenuButton resize = EzMenuButton(
      widget.config,
      label: 'Resize',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final String? choice = await resizeWidgetDialog(
          widget.config,
          context,
          size,
        );
        if (choice == null) return;
        final WidgetSize trueChoice = WSConfig.lookup(choice);

        await widget.appInfo.updateWidget(
          widget.config,
          WidWidGetGet.search,
          trueChoice,
          extra: <String>[engine.value],
          lane: widget.lane,
          index: widget.index,
        );
        setState(() => size = trueChoice);
      },
    );

    late final EzMenuButton remove = EzMenuButton(
      widget.config,
      label: 'Remove',
      icon: EzIcon(widget.config, Icons.delete),
      onPressed: () => widget.appInfo.deleteWidget(
        widget.config,
        lane: widget.lane,
        index: widget.index,
      ),
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard || AppState.singleEdit => MenuAnchor(
            builder: (_, MenuController controller, __) => (size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: icon,
                    onPressed: () => launchUrl(Uri.https(engine.base, '/')),
                    onLongPress: () => toggleMenu(controller),
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
                      child: NotificationListener<ScrollNotification>(
                        // Block scroll notifications
                        onNotification: (ScrollNotification notification) => true,
                        child: TextFormField(
                          controller: queryCon,
                          decoration: InputDecoration(hintText: engine.value),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.webSearch,
                          onChanged: onChanged,
                          onFieldSubmitted: search,
                        ),
                      ),
                    ),
                    widget.config.rowMargin,
                    EzIconButton(
                      widget.config,
                      icon: icon,
                      onPressed: () => search(queryCon.text),
                      onLongPress: () => toggleMenu(controller),
                    ),
                  ]),
            menuChildren: <Widget>[...engineMC, resize, remove],
          ),
        _ => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              if (numLanes > 1 && widget.lane != 0)
                EzMenuButton(
                  widget.config,
                  label: widget.config.isLTR ? 'Move left' : 'Move right',
                  icon: EzIcon(widget.config, Icons.control_camera),
                  onPressed: () => widget.appInfo.moveItemDown(
                    widget.config,
                    lane: widget.lane,
                    index: widget.index,
                  ),
                ),
              if (numLanes > 1 && widget.lane < (numLanes - 1))
                EzMenuButton(
                  widget.config,
                  label: widget.config.isLTR ? 'Move right' : 'Move left',
                  icon: EzIcon(widget.config, Icons.control_camera),
                  onPressed: () => widget.appInfo.moveItemUp(
                    widget.config,
                    lane: widget.lane,
                    index: widget.index,
                  ),
                ),
              resize,
              remove,
            ],
            child: EzIconButton(
              widget.config,
              iconSize: appIconSize(widget.config),
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
