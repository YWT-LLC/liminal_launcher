/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppFolder extends StatefulWidget {
  final int index;
  final List<String> items;

  late final String name;
  late final List<String> appList;
  late final Set<String> appSet;

  /// true: individual edits
  /// false: not editing
  /// null: all folders are being edited
  /// Quantum supremacy
  final bool? editing;

  final void Function() onEdit;
  final ValueNotifier<double>? rippleProgress;

  AppFolder({
    super.key,
    required this.index,
    required this.editing,
    required this.onEdit,
    this.rippleProgress,
  }) : items = appInfo.homeList[index].split(folderSplit) {
    name = items[0];
    appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
    appSet = appList.toSet();
  }

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Define the build data //

  bool open = false;
  late bool? editing = widget.editing;
  Timer? rippleThrottle;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

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

      final Duration animDur = ezAnimDuration();
      rippleThrottle = Timer(
        animDur - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final EdgeInsets colPadding =
        EdgeInsets.symmetric(vertical: EzConfig.spacing / 2);
    final EdgeInsets rowPadding =
        EdgeInsets.symmetric(horizontal: EzConfig.spacing / 2);

    if (editing != false) {
      return Visibility(
        visible: rippleThrottle == null,
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        child: EzScrollView(
          scrollDirection: Axis.horizontal,
          mainAxisAlignment: hAlign.mainAxis,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Name
            EzText(
              widget.name,
              style: EzConfig.styles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            EzConfig.rowSpacer,

            // Add apps
            EzIconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.goNamed(
                appListPath,
                extra: ListConfig(
                  ids: widget.appSet,
                  include: false,
                  onSelected: (String id) =>
                      appInfo.addToFolder(id, widget.index),
                  title: EzTextBackground(EzRow(
                    children: <Widget>[
                      Text(
                        '${widget.name}\t',
                        style: EzConfig.styles.labelLarge,
                      ),
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
                builder: (BuildContext dCon) {
                  final TextEditingController renameController =
                      TextEditingController();

                  void onConfirm() async {
                    closeKeyboard(dCon);

                    final String name = renameController.text.trim();
                    if (validateRename(name) != null) return null;

                    final bool success =
                        await appInfo.renameFolder(name, widget.index);

                    if (success) {
                      if (dCon.mounted) Navigator.of(dCon).pop(name);
                      widget.onEdit();
                    }
                  }

                  void onDeny() {
                    closeKeyboard(dCon);
                    Navigator.of(dCon).pop();
                  }

                  return EzAlertDialog(
                    title: Text(
                      "Rename '${widget.name}'?",
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
            if (widget.appSet.isNotEmpty) ...<Widget>[
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
                          final String toMove =
                              widget.appList.removeAt(oldIndex);
                          widget.appList.insert(
                            oldIndex < newIndex ? newIndex - 1 : newIndex,
                            toMove,
                          );
                          setModal(() {});

                          // Storage update
                          await appInfo.reorderFolderItem(
                            oldIndex: oldIndex + 1, // name offset
                            newIndex: newIndex + 1,
                            folderIndex: widget.index,
                          );
                          widget.onEdit();
                          setModal(() {});
                        },
                        children: widget.appList
                            .map((String id) {
                              final AppInfo? app = appInfo.appMap[id];
                              if (app == null) return null;

                              return Padding(
                                key: ValueKey<String>(id),
                                padding: colPadding,
                                child: EzRow(
                                  // The Row prevents the AppTile from auto-expanding
                                  reverseHands: false,
                                  mainAxisAlignment: hAlign.mainAxis,
                                  crossAxisAlignment: hAlign.crossAxis,
                                  children: <Widget>[
                                    // App tile
                                    TileButton(
                                      app: app,
                                      labelType: folderLabels,
                                      showIcon: folderIcons,
                                    ),
                                    EzConfig.rowSpacer,

                                    // Remove button
                                    EzIconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () async {
                                        await appInfo.removeFromFolder(
                                            id, widget.index);
                                        widget.onEdit();
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
                final bool success = await appInfo.deleteFolder(
                  widget.appList.isEmpty
                      ? '${widget.name}$folderSplit$emptyTag'
                      : <String>[widget.name, ...widget.appList]
                          .join(folderSplit),
                );

                if (success) widget.onEdit();
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
                mainAxisAlignment: hAlign.mainAxis,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.appList
                        .map((String id) {
                          final AppInfo? app = appInfo.appMap[id];
                          if (app == null) return null;

                          return Padding(
                            padding: rowPadding,
                            child: AppTile(
                              app: app,
                              onHomeScreen: null,
                              onSelected: (String id) => launchApp(id),
                              editing: editing,
                              onEdit: widget.onEdit,
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
          : (folderIcons
              ? EzTextIconButton(
                  label: buildLabel(widget.name, folderLabels),
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
                  text: widget.name,
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
