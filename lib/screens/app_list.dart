/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Map<String, dynamic> listData({
  required bool Function(String id) listCheck,
  required Future<void> Function(String id) onSelected,
  required void Function() refresh,
  bool autoRefresh = false,
  bool editable = true,
  Widget? icon,
}) =>
    <String, dynamic>{
      ListData.listCheck.key: listCheck,
      ListData.onSelected.key: onSelected,
      ListData.refresh.key: refresh,
      ListData.autoRefresh.key: autoRefresh,
      ListData.editable.key: editable,
      ListData.icon.key: icon,
    };

class AppListScreen extends StatefulWidget {
  final bool Function(String) listCheck;
  final Future<void> Function(String id) onSelected;
  final void Function() refresh;
  final bool autoRefresh;
  final bool editable;
  final Widget? icon;

  const AppListScreen({
    super.key,
    required this.listCheck,
    required this.onSelected,
    required this.refresh,
    required this.autoRefresh,
    required this.editable,
    this.icon,
  });

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Gather the fixed theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  final EzSpacer rowMargin = EzMargin(vertical: false);

  final double iconSize = EzConfig.get(iconSizeKey);

  final double margin = EzConfig.get(marginKey);
  final double padding = EzConfig.get(paddingKey);
  final double spacing = EzConfig.get(spacingKey);

  final Duration animDuration = ezAnimDuration();

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  final LabelType listLabel =
      LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey));
  final bool listIcon = EzConfig.get(listIconKey);

  final ListAlignment hAlign =
      ListAlignmentConfig.fromValue(EzConfig.get(listHAlignKey));
  final ListAlignment vAlign =
      ListAlignmentConfig.fromValue(EzConfig.get(listVAlignKey));

  // Define the build data //

  late final AppInfoProvider listener = Provider.of<AppInfoProvider>(context);
  late final AppInfoProvider editor =
      Provider.of<AppInfoProvider>(context, listen: false);

  late List<AppInfo> appList = getApps();
  late List<AppInfo> searchList = appList;

  bool searching = EzConfig.get(autoSearchKey);
  final TextEditingController searchControl = TextEditingController();

  AppSort listSort = AppSortConfig.fromValue(EzConfig.get(listSortKey));
  bool ascList = EzConfig.get(ascListKey);

  final ScrollController scrollControl = ScrollController();

  bool atTop = true;
  bool atBottom = false;

  // Define custom functions //

  void refreshList() => setState(() => appList = getApps());

  void refreshAll() {
    widget.refresh();
    refreshList();
  }

  Future<void> onSelected(String id) async {
    await widget.onSelected(id);
    if (widget.autoRefresh) refreshAll();
  }

  List<AppInfo> getApps() =>
      listener.apps.where((AppInfo app) => widget.listCheck(app.id)).toList();

  List<AppInfo> searchApps(List<AppInfo> appList) => appList
      .where((AppInfo app) =>
          app.name.toLowerCase().contains(searchControl.text.toLowerCase()))
      .toList();

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Pop on swipe down (backup for non-scroll portions)
              Navigator.of(context).pop();
            }
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: vAlign.mainAxis,
          crossAxisAlignment: hAlign.crossAxis,
          children: <Widget>[
            if (spacing > margin) EzSpacer(space: spacing - margin),

            // List controls
            EzScrollView(
              scrollDirection: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: vAlign.crossAxis,
              children: <Widget>[
                // Sort
                MenuAnchor(
                  builder: (_, MenuController controller, __) => EzIconButton(
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    icon: const Icon(Icons.sort),
                  ),
                  menuChildren: <EzMenuButton>[
                    // By name
                    EzMenuButton(
                      label: 'Name',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.name;

                        await EzConfig.setString(
                          listSortKey,
                          listSort.configValue,
                        );
                        editor.sort(listSort, ascList);

                        refreshList();
                      },
                    ),
                    // By publisher
                    EzMenuButton(
                      label: 'Publisher',
                      textAlign: hAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.publisher;

                        await EzConfig.setString(
                          listSortKey,
                          listSort.configValue,
                        );
                        editor.sort(listSort, ascList);

                        refreshList();
                      },
                    ),
                  ],
                ),
                rowSpacer,

                // Order
                EzIconButton(
                  icon: EzIcon(
                      ascList ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () async {
                    ascList = !ascList;

                    await EzConfig.setBool(ascListKey, ascList);
                    editor.sort(listSort, ascList);

                    refreshList();
                  },
                ),
                rowSpacer,

                // Search
                AnimatedContainer(
                  duration: animDuration,
                  width: searching ? 200 : null,
                  curve: Curves.easeInOut,
                  child: EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EzIconButton(
                        icon: Icon(PlatformIcons(context).search),
                        onPressed: () {
                          if (searching) {
                            closeKeyboard(context);
                            searchControl.clear();

                            searchList = appList;
                            setState(() => searching = false);
                          } else {
                            searchList = searchApps(appList);
                            setState(() => searching = true);
                          }
                        },
                      ),
                      if (searching) ...<Widget>[
                        rowMargin,
                        Expanded(
                          child: TextField(
                            controller: searchControl,
                            autofocus: searching,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(
                                () => searchList = searchApps(appList)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.icon != null) ...<Widget>[
              EzMargin(),
              widget.icon!,
            ],
            spacer,

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
              child: searching
                  ? Expanded(
                      child: ListView.builder(
                        controller: scrollControl,
                        physics: const ClampingScrollPhysics(),
                        itemCount: searchList.length,
                        itemBuilder: (_, int index) => Padding(
                          key: ValueKey<String>(searchList[index].id),
                          padding: listPadding,
                          child: AppTile(
                            app: searchList[index],
                            listener: listener,
                            editor: editor,
                            onHomeScreen: false,
                            labelType: listLabel,
                            showIcon: listIcon,
                            onSelected: onSelected,
                            editable: widget.editable,
                            editing: false,
                            refresh: refreshAll,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        controller: scrollControl,
                        physics: const ClampingScrollPhysics(),
                        itemCount: appList.length,
                        itemBuilder: (_, int index) => Padding(
                          key: ValueKey<String>(appList[index].id),
                          padding: listPadding,
                          child: AppTile(
                            app: appList[index],
                            listener: listener,
                            editor: editor,
                            onHomeScreen: false,
                            labelType: listLabel,
                            showIcon: listIcon,
                            onSelected: onSelected,
                            editable: widget.editable,
                            editing: false,
                            refresh: refreshAll,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      fabs: <Widget>[
        spacer,

        // Scroll to top
        SizedBox(
          height: iconSize + padding,
          child: Visibility(
            visible: !atTop,
            child: FloatingActionButton(
              onPressed: () {
                scrollControl.animateTo(
                  0,
                  duration: animDuration,
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(PlatformIcons(context).upArrow),
            ),
          ),
        ),
        spacer,

        // Scroll to bottom
        SizedBox(
          height: iconSize + padding,
          child: Visibility(
            visible: !atBottom,
            child: FloatingActionButton(
              onPressed: () {
                scrollControl.animateTo(
                  scrollControl.position.maxScrollExtent,
                  duration: animDuration,
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(PlatformIcons(context).downArrow),
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
