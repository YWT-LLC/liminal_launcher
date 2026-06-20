/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: can I use voice to text? if yes, let the user override long press on the icon button for insta voice...
// ...they will still be able to edit the widget in editing mode

class SearchWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int lane;
  final int index;
  final AppState state;

  late final WidgetSize _size;
  late final String _storedEngine;
  late final TextEditingController _queryCon;

  SearchWidget(this.config, this.appInfo, this.lane, this.index, this.state, {super.key}) {
    final List<String> data = appInfo.homeList(config, lane)[index].split(widgetSplit);

    final WidgetSize size = WSConfig.lookup(data[1]);
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;

    _storedEngine = data[2];
    _queryCon = TextEditingController();
  }

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // Define the build data //

  late Engine engine = Ignition.lookup(widget._storedEngine);

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

  // Define custom functions //

  void toggleChoices(MenuController c) => c.isOpen ? c.close() : c.open();

  // Return the build //

  // TODO: hint text
  // TODO: text in center of screen idea
  // TODO: fix field size and alignment
  // TODO: cleanup and tackle all of these, 40 is too many!!!!!

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
                ), // TODO: block scroll events
                child: TextFormField(
                  controller: widget._queryCon,
                  decoration: InputDecoration(hintText: engine.value),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  onFieldSubmitted: (String text) => launchUrl(Uri.https(
                    engine.base,
                    engine.path,
                    text.trim().isEmpty ? null : <String, dynamic>{engine.query: text.trim()},
                  )),
                ),
              ),
              widget.config.rowMargin,
              EzIconButton(
                widget.config,
                icon: icon(widget.config),
                iconSize: appIconSize(widget.config),
                onPressed: () => launchUrl(Uri.https(
                  engine.base,
                  engine.path,
                  widget._queryCon.text.trim().isEmpty
                      ? null
                      : <String, dynamic>{engine.query: widget._queryCon.text.trim()},
                )),
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
}
