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

  // Define custom functions //

  Widget icon(EzCP config) => switch (engine) {
        Engine.archive => EzIcon(config, Icons.archive),
        Engine.baidu => EzIcon(config, LineIcons.paw),
        Engine.bing => EzIcon(config, Icons.search),
        Engine.ducks => EzIcon(config, Icons.bathtub),
        Engine.ecosia => EzIcon(config, LineIcons.tree),
        Engine.google => EzIcon(config, LineIcons.googleLogo),
        Engine.naver => EzIcon(config, LineIcons.neos), // close enough
        Engine.qwant => EzIcon(config, LineIcons.quora), // ditto
        Engine.wikipedia => EzIcon(config, LineIcons.wikipediaW),
        Engine.wolframAlpha => EzIcon(config, LineIcons.equals),
        Engine.yahoo => EzIcon(config, LineIcons.yahooLogo),
        Engine.yandex => EzIcon(config, LineIcons.yandex),
        Engine.youTube => EzIcon(config, LineIcons.youtube),
      };

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
            icon: icon(widget.config),
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
                icon: icon(widget.config),
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
