/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// TODO: short and long press for everything
// TODO: have a tool tipper on the add screen that describes what it does ahead of time
// TODO: at least two, preferably three sizes for everything
// TODO: can I use voice to text? if yes, let the user override long press on the icon button for insta voice...
// ...they will still be able to edit the widget in editing mode

class SearchWidget extends StatelessWidget {
  final EzCP config;
  late final WidgetSize _size;
  final AppState state;
  late final TextEditingController _queryCon;

  SearchWidget(this.config, WidgetSize size, this.state, {super.key}) {
    _size = (size == WidgetSize.system) ? bt2WS(config) : size;
    _queryCon = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => switch (_size) {
        WidgetSize.system => const SizedBox.shrink(), // override above
        WidgetSize.button => EzIconButton(
            config,
            icon: EzIcon(config, Icons.search),
            onPressed: () => launchUrl(Uri.parse('https://duckduckgo.com/')),
          ),
        WidgetSize.tile => elevatedLists(config)
            ? EzIconButton(
                config,
                icon: EzRow(
                  config,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: ezTextFieldConstraints(context),
                      child: TextFormField(controller: _queryCon),
                    ),
                    config.rowMargin,
                    EzIconButton(
                      config,
                      icon: EzIcon(config, Icons.search),
                      onPressed: () => launchUrl(_queryCon.text.trim().isEmpty
                          ? Uri.parse('https://duckduckgo.com/')
                          : Uri.https(
                              'duckduckgo.com',
                              '/',
                              <String, dynamic>{'q': _queryCon.text.trim()},
                            )),
                    ),
                  ],
                ),
              )
            : EzRow(
                config,
                children: <Widget>[],
              ),
        WidgetSize.unbound => const SizedBox.shrink(), // TODO
      };
}
