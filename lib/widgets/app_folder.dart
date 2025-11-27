/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppFolder extends StatefulWidget {
  final AppInfoProvider listener;
  final AppInfoProvider editor;
  final int index;
  final ListAlignment hAlign;
  final LabelType folderLabel;
  final bool folderIcon;
  final LabelType appLabel;
  final bool appIcon;
  final bool? editing;
  final void Function() refresh;
  final ValueNotifier<double>? rippleProgress;

  const AppFolder({
    super.key,
    required this.listener,
    required this.editor,
    required this.index,
    required this.hAlign,
    required this.folderLabel,
    required this.folderIcon,
    required this.appLabel,
    required this.appIcon,
    required this.editing,
    required this.refresh,
    this.rippleProgress,
  });

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Gather the fixed theme data //

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets colPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);
  late final EdgeInsets rowPadding =
      EdgeInsets.symmetric(horizontal: spacing / 2);

  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late int index = widget.index;
  late List<String> items = widget.listener.homeList[index].split(folderSplit);

  late String name = items[0];
  late final String folderLabel;

  late List<String> appList =
      (items[1] == emptyTag) ? <String>[] : items.sublist(1);
  late Set<String> appSet = appList.toSet();

  bool open = false;
  late bool? editing = widget.editing;
  Timer? rippleThrottle;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  void refreshFolder() {
    items = widget.listener.homeList[index].split(folderSplit);
    name = items[0];
    appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
    appSet = appList.toSet();
    setState(() {});
  }

  void refreshAll() {
    widget.refresh();
    refreshFolder();
  }

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }
    final Offset wya =
        (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dy <= widget.rippleProgress!.value * heightOf(context)) {
      setState(() => editing = (editing == null) ? false : null);

      rippleThrottle = Timer(
        animDuration - (animDuration * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);

    switch (widget.appLabel) {
      case LabelType.none:
        folderLabel = '';

      case LabelType.initials:
        folderLabel = name
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();

      case LabelType.full:
        folderLabel = name;

      case LabelType.wingding:
        folderLabel = name
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
    }
  }

  // Return the build //

  late final List<Widget> closeTail = <Widget>[
    EzSpacer(space: spacing / 2, vertical: false),
    EzIconButton(icon: const Icon(Icons.close), onPressed: toggleOpen),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (editing != false) {
      return EzScrollView(
        scrollDirection: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.hAlign.mainAxis,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Name
          EzText(
            name,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          ezRowSpacer,

          // Add apps
          EzIconButton(
            icon: Icon(PlatformIcons(context).add),
            onPressed: () => context.goNamed(
              appListPath,
              extra: listData(
                listCheck: (String id) => !appSet.contains(id),
                onSelected: (String id) async {
                  final int? indexMod =
                      await widget.editor.addToFolder(id, index);

                  if (indexMod != null) index += indexMod;
                },
                refresh: refreshAll,
                autoRefresh: true,
                icon: EzTextBackground(EzRow(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('$name\t', style: textTheme.labelLarge),
                    EzIcon(
                      PlatformIcons(context).add,
                      color: colorScheme.onSurface,
                    ),
                  ],
                )),
              ),
            ),
          ),
          ezRowSpacer,

          // Info (rename)
          EzIconButton(
            onPressed: () => showPlatformDialog(
              context: context,
              builder: (BuildContext dContext) {
                final TextEditingController renameController =
                    TextEditingController();

                void onConfirm() async {
                  closeKeyboard(dContext);

                  final String name = renameController.text.trim();
                  if (validateRename(name) != null) return null;

                  final bool success =
                      await widget.editor.renameFolder(name, index);

                  if (success) {
                    if (dContext.mounted) Navigator.of(dContext).pop(name);
                    refreshAll();
                  }
                }

                void onDeny() {
                  closeKeyboard(dContext);
                  Navigator.of(dContext).pop();
                }

                late final List<Widget> materialActions;
                late final List<Widget> cupertinoActions;

                (materialActions, cupertinoActions) = ezActionPairs(
                  context: context,
                  confirmMsg: el10n.gApply,
                  onConfirm: onConfirm,
                  confirmIsDestructive: true,
                  denyMsg: el10n.gCancel,
                  onDeny: onDeny,
                );

                return EzAlertDialog(
                  title: Text(
                    "Rename '$name'?",
                    textAlign: TextAlign.center,
                  ),
                  content: Form(
                    child: TextFormField(
                      controller: renameController,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      autofillHints: const <String>[AutofillHints.name],
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      validator: validateRename,
                    ),
                  ),
                  materialActions: materialActions,
                  cupertinoActions: cupertinoActions,
                  needsClose: false,
                );
              },
            ),
            icon: Icon(PlatformIcons(context).info),
          ),
          ezRowSpacer,

          // Edit apps
          if (appSet.isNotEmpty) ...<Widget>[
            EzIconButton(
              icon: Icon(PlatformIcons(context).edit),
              onPressed: () => ezModal(
                context: context,
                builder: (_) => StatefulBuilder(
                  builder: (_, StateSetter setModal) => Expanded(
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) async {
                        if (oldIndex == newIndex) return;

                        // Local UI update first
                        final String toMove = appList.removeAt(oldIndex);
                        appList.insert(
                          oldIndex < newIndex ? newIndex - 1 : newIndex,
                          toMove,
                        );
                        setModal(() {});

                        // Storage update
                        await widget.editor.reorderFolderItem(
                          oldIndex: oldIndex + 1, // name offset
                          newIndex: newIndex + 1,
                          folderIndex: widget.index,
                        );
                        refreshFolder();
                        setModal(() {});
                      },
                      children: appList
                          .map((String id) {
                            final AppInfo? app = widget.listener.appMap[id];
                            if (app == null) return null;

                            return Padding(
                              key: ValueKey<String>(id),
                              padding: colPadding,
                              child: Row(
                                // The Row prevents the AppTile from auto-expanding
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: widget.hAlign.mainAxis,
                                crossAxisAlignment: widget.hAlign.crossAxis,
                                children: <Widget>[
                                  // App tile
                                  TileButton(
                                    app: app,
                                    labelType: widget.appLabel,
                                    showIcon: widget.appIcon,
                                  ),
                                  ezRowSpacer,

                                  // Remove button
                                  EzIconButton(
                                    icon: Icon(PlatformIcons(context).remove),
                                    onPressed: () async {
                                      await widget.editor
                                          .removeFromFolder(id, widget.index);
                                      refreshAll();
                                      setModal(() {});
                                    },
                                  ),
                                  ezRowSpacer,

                                  // Drag handle
                                  EzIcon(
                                    Icons.drag_handle,
                                    color: colorScheme.outline,
                                  ),
                                ],
                              ),
                            );
                          })
                          .whereType<Widget>()
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            ezRowSpacer,
          ],

          // Delete folder
          EzIconButton(
            icon: Icon(PlatformIcons(context).delete),
            onPressed: () async {
              final bool success = await widget.editor.deleteFolder(
                appList.isEmpty
                    ? '$name$folderSplit$emptyTag'
                    : <String>[name, ...appList].join(folderSplit),
              );

              if (success) refreshAll();
            },
          ),

          // Close/end edits
          if (editing == true) ...<Widget>[
            ezRowSpacer,
            EzIconButton(
              onPressed: () => setState(() => editing = false),
              icon: const Icon(Icons.close),
            ),
          ],

          // Drag handle
          if (editing == null) ...<Widget>[
            ezRowSpacer,
            EzIcon(
              Icons.drag_handle,
              color: colorScheme.outline,
            ),
          ],
        ],
      );
    }

    return open
        ? TapRegion(
            onTapOutside: (_) => toggleOpen,
            child: EzScrollView(
              scrollDirection: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.hAlign.mainAxis,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: appList
                      .map((String id) {
                        final AppInfo? app = widget.listener.appMap[id];
                        if (app == null) return null;

                        return Padding(
                          padding: rowPadding,
                          child: AppTile(
                            app: app,
                            listener: widget.listener,
                            editor: widget.editor,
                            onHomeScreen: null,
                            hAlign: widget.hAlign,
                            labelType: widget.folderLabel,
                            showIcon: widget.folderIcon,
                            onSelected: (String id) => launchApp(id),
                            editing: editing,
                            refresh: refreshAll,
                          ),
                        );
                      })
                      .whereType<Widget>()
                      .toList() +
                  closeTail,
            ),
          )
        : (widget.appIcon
            ? EzTextIconButton(
                label: folderLabel,
                icon: Icon(
                  PlatformIcons(context).folderOpen,
                  size: EzConfig.get(iconSizeKey) + EzConfig.get(paddingKey),
                ),
                style: TextButton.styleFrom(padding: EzInsets.wrap(margin)),
                onPressed: toggleOpen,
                onLongPress: () => setState(() => editing = true),
              )
            : EzTextButton(
                text: name,
                style: TextButton.styleFrom(padding: EzInsets.wrap(margin)),
                onPressed: toggleOpen,
                onLongPress: () => setState(() => editing = true),
              ));
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
