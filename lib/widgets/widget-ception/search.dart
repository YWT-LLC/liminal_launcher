/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: states, ripples, and edits

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final WidgetSize _size;
  late final String _storedEngine;

  SearchWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
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

  void toggleChoices(MenuController c) => c.isOpen ? c.close() : c.open();

  void onChanged() {
    final String text = queryCon.text.trim();

    (text.isNotEmpty)
        ? ((overlayEntry == null) ? showOverlay() : overlayEntry?.markNeedsBuild())
        : removeOverlay();
  }

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
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // Init //

  @override
  void initState() {
    super.initState();
    queryCon = TextEditingController();
    queryCon.addListener(onChanged);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (_, MenuController controller, __) => switch (widget._size) {
        WidgetSize.button => EzIconButton(
            widget.config,
            icon: icon,
            iconSize: appIconSize(widget.config),
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
                iconSize: appIconSize(widget.config),
                onPressed: () => search(queryCon.text),
                onLongPress: () => toggleChoices(controller),
              ),
            ],
          ),
      },
      menuChildren: Engine.values
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
          .toList(),
    );
  }

  @override
  void dispose() {
    queryCon.removeListener(onChanged);
    queryCon.dispose();
    removeOverlay();
    super.dispose();
  }
}
