/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ListConfig {
  final Set<String> ids;
  final bool include;
  final Future<void> Function(String id) onSelected;
  final Widget? title;

  /// How the [AppListScreen] should behave
  const ListConfig({
    required this.ids,
    required this.include,
    required this.onSelected,
    required this.title,
  });
}

class AppListScreen extends StatefulWidget {
  final ListConfig config;

  AppListScreen(this.config) : super(key: ValueKey<int>(EzConfig.seed));

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Define the fixed build data //

  final ScrollController scrollControl = ScrollController();
  final TextEditingController searchControl = TextEditingController();

  AppSort listSort = AppSortConfig.lookup(EzConfig.get(listSortKey));
  bool ascList = EzConfig.get(ascListKey);
  bool atTop = true;
  bool atBottom = false;

  bool searching = EzConfig.get(autoSearchKey);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final EdgeInsets listPadding =
        EdgeInsets.symmetric(vertical: EzConfig.spacing / 2);

    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (DragEndDetails details) {
          // Pop on swipe down (backup for non-scroll portions)
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              Navigator.of(context).pop();
            }
          }
        },
        child: EzCol(
          mainAxisAlignment: vAlign.mainAxis,
          crossAxisAlignment: hAlign.crossAxis,
          children: <Widget>[
            EzHeader(),

            // List controls
            EzScrollView(
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: vAlign.crossAxis,
              children: <Widget>[
                // Sort by...
                MenuAnchor(
                  builder: (_, MenuController controller, __) => EzIconButton(
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    icon: const Icon(Icons.sort),
                  ),
                  menuChildren: <EzMenuButton>[
                    // Name
                    EzMenuButton(
                      label: 'Name',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.name;
                        await EzConfig.setString(listSortKey, listSort.value);

                        appInfo.sort(listSort, ascList);
                        setState(() {});
                      },
                    ),

                    // Publisher
                    EzMenuButton(
                      label: 'Publisher',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.publisher;
                        await EzConfig.setString(listSortKey, listSort.value);

                        appInfo.sort(listSort, ascList);
                        setState(() {});
                      },
                    ),

                    // Install date
                    EzMenuButton(
                      label: 'Install date',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.date;
                        await EzConfig.setString(listSortKey, listSort.value);

                        appInfo.sort(listSort, ascList);
                        setState(() {});
                      },
                    ),

                    // Package size
                    EzMenuButton(
                      label: 'Package size',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.size;
                        await EzConfig.setString(listSortKey, listSort.value);

                        appInfo.sort(listSort, ascList);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                EzConfig.rowSpacer,

                // Order
                EzIconButton(
                  icon: Icon(
                    ascList ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () async {
                    ascList = !ascList;

                    await EzConfig.setBool(ascListKey, ascList);
                    appInfo.sort(listSort, ascList);
                    setState(() {});
                  },
                ),
                EzConfig.rowSpacer,

                // Search
                AnimatedContainer(
                  duration: ezAnimDuration(),
                  width: searching ? 200 : null,
                  curve: Curves.easeInOut,
                  child: EzRow(
                    children: <Widget>[
                      EzIconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (searching) {
                            closeKeyboard(context);
                            searchControl.clear();
                            setState(() => searching = false);
                          } else {
                            setState(() => searching = true);
                          }
                        },
                      ),
                      if (searching) ...<Widget>[
                        EzMargin(vertical: false),
                        Expanded(
                          child: TextField(
                            controller: searchControl,
                            autofocus: searching,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.config.title != null) ...<Widget>[
              EzConfig.margin,
              widget.config.title!,
            ],
            EzConfig.spacer,

            // App list
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is OverscrollNotification &&
                    notification.overscroll < 0) {
                  // Pop on top overscroll
                  if (atTop) {
                    Navigator.of(context).pop();
                    return true;
                  } else {
                    setState(() => atTop = true);
                    return true;
                  }
                } else if (notification is ScrollUpdateNotification) {
                  if (atTop && notification.metrics.pixels > 0) {
                    setState(() => atTop = false);
                  }

                  if (atBottom &&
                      notification.metrics.pixels <
                          notification.metrics.maxScrollExtent) {
                    setState(() => atBottom = false);
                  }
                } else if (notification is ScrollEndNotification) {
                  atTop = (notification.metrics.pixels == 0);
                  atBottom = (notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent);
                  setState(() {});
                }
                return false;
              },
              child: Expanded(
                child: EzScrollView(
                  mainAxisSize: MainAxisSize.max,
                  controller: scrollControl,
                  physics: const ClampingScrollPhysics(),
                  children: appInfo.apps
                      .where((AppInfo app) =>
                          (widget.config.ids.contains(app.id) ==
                              widget.config.include) &&
                          (searching
                              ? app.name
                                  .toLowerCase()
                                  .contains(searchControl.text.toLowerCase())
                              : true))
                      .map((AppInfo app) => Padding(
                            key: ValueKey<String>(app.id),
                            padding: listPadding,
                            child: AppTile(
                              app: app,
                              onHomeScreen: false,
                              onSelected: widget.config.onSelected,
                              editing: false,
                              onEdit: () => setState(() {}),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      fabs: <Widget>[
        EzConfig.spacer,

        // Scroll to top
        SizedBox(
          height: EzConfig.iconSize + EzConfig.padding,
          child: Visibility(
            visible: !atTop,
            child: FloatingActionButton(
              onPressed: () {
                scrollControl.animateTo(
                  0,
                  duration: ezAnimDuration(),
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(Icons.arrow_upward),
            ),
          ),
        ),
        EzConfig.spacer,

        // Scroll to bottom
        SizedBox(
          height: EzConfig.iconSize + EzConfig.padding,
          child: Visibility(
            visible: !atBottom,
            child: FloatingActionButton(
              onPressed: () {
                scrollControl.animateTo(
                  scrollControl.position.maxScrollExtent,
                  duration: ezAnimDuration(),
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(Icons.arrow_downward),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    scrollControl.dispose();
    searchControl.dispose();
    super.dispose();
  }
}
