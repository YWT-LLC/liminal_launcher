/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppFolder extends StatefulWidget {
  final AppInfoProvider appProvider;
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
    required this.appProvider,
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
  // Define the build data //

  late int index = widget.index;
  late List<String> items =
      widget.appProvider.homeList[index].split(folderSplit);

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
    items = widget.appProvider.homeList[index].split(folderSplit);
    name = items[0];
    appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
    appSet = appList.toSet();
    if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    final EdgeInsets colPadding =
        EdgeInsets.symmetric(vertical: EzConfig.spacing / 2);
    final EdgeInsets rowPadding =
        EdgeInsets.symmetric(horizontal: EzConfig.spacing / 2);

    // Return the build //

    if (editing != false) {
      return Visibility(
        visible: rippleThrottle == null,
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        child: EzScrollView(
          scrollDirection: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: widget.hAlign.mainAxis,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Name
            EzText(
              name,
              style: EzConfig.styles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            EzConfig.rowSpacer,

            // Add apps
            EzIconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.goNamed(
                appListPath,
                extra: listData(
                  listCheck: (String id) => !appSet.contains(id),
                  onSelected: (String id) async {
                    final int? indexMod =
                        await widget.appProvider.addToFolder(id, index);

                    if (indexMod != null) index += indexMod;
                  },
                  refresh: refreshAll,
                  autoRefresh: true,
                  icon: EzTextBackground(EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('$name\t', style: EzConfig.styles.labelLarge),
                      EzIcon(
                        Icons.add,
                        color: EzConfig.colors.onSurface,
                      ),
                    ],
                  )),
                ),
              ),
            ),
            EzConfig.rowSpacer,

            // Info (rename)
            EzIconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext dContext) {
                  final TextEditingController renameController =
                      TextEditingController();

                  void onConfirm() async {
                    closeKeyboard(dContext);

                    final String name = renameController.text.trim();
                    if (validateRename(name) != null) return null;

                    final bool success =
                        await widget.appProvider.renameFolder(name, index);

                    if (success) {
                      if (dContext.mounted) Navigator.of(dContext).pop(name);
                      refreshAll();
                    }
                  }

                  void onDeny() {
                    closeKeyboard(dContext);
                    Navigator.of(dContext).pop();
                  }

                  return EzAlertDialog(
                    title: Text("Rename '$name'?", textAlign: TextAlign.center),
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
                    actions: ezActionPair(
                      context: context,
                      confirmMsg: EzConfig.l10n.gApply,
                      onConfirm: onConfirm,
                      confirmIsDestructive: true,
                      denyMsg: EzConfig.l10n.gCancel,
                      onDeny: onDeny,
                    ),
                    needsClose: false,
                  );
                },
              ),
              icon: const Icon(Icons.info),
            ),
            EzConfig.rowSpacer,

            // Edit apps
            if (appSet.isNotEmpty) ...<Widget>[
              EzIconButton(
                icon: const Icon(Icons.edit),
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
                          await widget.appProvider.reorderFolderItem(
                            oldIndex: oldIndex + 1, // name offset
                            newIndex: newIndex + 1,
                            folderIndex: widget.index,
                          );
                          refreshFolder();
                          setModal(() {});
                        },
                        children: appList
                            .map((String id) {
                              final AppInfo? app =
                                  widget.appProvider.appMap[id];
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
                                    EzConfig.rowSpacer,

                                    // Remove button
                                    EzIconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () async {
                                        await widget.appProvider
                                            .removeFromFolder(id, widget.index);
                                        refreshAll();
                                        setModal(() {});
                                      },
                                    ),
                                    EzConfig.rowSpacer,

                                    // Drag handle
                                    EzIcon(
                                      Icons.drag_handle,
                                      color: EzConfig.colors.outline,
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
              EzConfig.rowSpacer,
            ],

            // Delete folder
            EzIconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final bool success = await widget.appProvider.deleteFolder(
                  appList.isEmpty
                      ? '$name$folderSplit$emptyTag'
                      : <String>[name, ...appList].join(folderSplit),
                );

                if (success) widget.refresh();
              },
            ),

            // Close/end edits
            if (editing == true) ...<Widget>[
              EzConfig.rowSpacer,
              EzIconButton(
                onPressed: () => setState(() => editing = false),
                icon: const Icon(Icons.close),
              ),
            ],

            // Drag handle
            if (editing == null) ...<Widget>[
              EzConfig.rowSpacer,
              EzIcon(Icons.drag_handle, color: EzConfig.colors.outline),
            ],
          ],
        ),
      );
    }

    return Visibility(
      visible: rippleThrottle == null,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: open
          ? TapRegion(
              onTapOutside: (_) => toggleOpen,
              child: EzScrollView(
                scrollDirection: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: widget.hAlign.mainAxis,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: appList
                        .map((String id) {
                          final AppInfo? app = widget.appProvider.appMap[id];
                          if (app == null) return null;

                          return Padding(
                            padding: rowPadding,
                            child: AppTile(
                              app: app,
                              appProvider: widget.appProvider,
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
                    <Widget>[
                      EzSpacer(space: EzConfig.spacing / 2, vertical: false),
                      EzIconButton(
                          icon: const Icon(Icons.close), onPressed: toggleOpen),
                    ],
              ),
            )
          : (widget.appIcon
              ? EzTextIconButton(
                  label: folderLabel,
                  icon: Icon(
                    Icons.folder_open,
                    size: EzConfig.iconSize + EzConfig.padding,
                  ),
                  style: TextButton.styleFrom(
                      padding: EzInsets.wrap(EzConfig.marginVal)),
                  onPressed: toggleOpen,
                  onLongPress: () => setState(() => editing = true),
                )
              : EzTextButton(
                  text: name,
                  style: TextButton.styleFrom(
                      padding: EzInsets.wrap(EzConfig.marginVal)),
                  onPressed: toggleOpen,
                  onLongPress: () => setState(() => editing = true),
                )),
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}
