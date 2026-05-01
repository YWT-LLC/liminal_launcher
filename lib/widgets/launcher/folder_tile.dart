/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppFolder extends StatefulWidget {
  final int index;

  /// true == individual edits
  /// null == group edits
  /// false == false
  /// Quantum supremacy achieved (⌐■_■)
  final bool? editing;

  final void Function() onEdit;
  final ValueNotifier<double>? rippleProgress;

  late final String _name;
  late final List<String> _appList;

  AppFolder({
    super.key,
    required this.index,
    required this.editing,
    required this.onEdit,
    this.rippleProgress,
  }) {
    final List<String> items = appInfo.homeList[index].split(folderSplit);

    _name = items[0];
    _appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
  }

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> with AfterLayoutMixin<AppFolder> {
  // Define the build data //

  bool open = false;
  late bool? editing = widget.editing;
  Timer? rippleThrottle;

  Size hideSize = Size(appIconSize, appIconSize);

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }
    final Offset wya = ezWya(context);
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

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    setState(() => hideSize = (context.findRenderObject() as RenderBox).size);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final Widget editSpacer = GestureDetector(
      onLongPress: () => editing == true ? setState(() => editing = false) : null,
      child: EzConfig.rowSpacer,
    );

    return EzAnimHide(
      mod: 0.75,
      visible: rippleThrottle == null,
      size: hideSize,
      kid: (editing == false)
          ? (open
              ? TapRegion(
                  onTapOutside: (_) => toggleOpen,
                  child: EzScrollView(
                    scrollDirection: Axis.horizontal,
                    mainAxisAlignment: hAlign.mainAxis,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widget._appList
                        .map((String id) {
                          final AppInfo? app = appInfo.appMap[id];
                          if (app == null) return null;

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: EzConfig.spacing / 2),
                            child: AppTile(
                              app: app,
                              onHomeScreen: null,
                              onSelected: (String id) => launchApp(id),
                              editing: false,
                              onEdit: doNothing,
                            ),
                          );
                        })
                        .whereType<Widget>()
                        .toList(),
                  ),
                )
              : FolderButton(
                  name: widget._name,
                  buttonType: folderBT,
                  labelType: folderLabels,
                  onPressed: toggleOpen,
                  onLongPress: () => setState(() => editing = true),
                ))
          : EzScrollView(
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Name (and rename)
                EzLink(
                  widget._name,
                  style: EzConfig.styles.bodyLarge,
                  textColor: EzConfig.colors.onSurface,
                  textAlign: TextAlign.center,
                  hint: 'Activate to rename.',
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext dCon) {
                      final TextEditingController renameController = TextEditingController();

                      void onConfirm() async {
                        closeKeyboard(dCon);

                        final String name = renameController.text.trim();
                        if (validateRename(name) != null) return null;

                        final bool success = await appInfo.renameFolder(name, widget.index);

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
                          "Rename '${widget._name}'?",
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
                ),
                editSpacer,

                // Edit apps
                EzIconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await ezModal(
                      isDismissible: false,
                      enableDrag: false,
                      showDragHandle: false,
                      context: context,
                      builder: (_) => StatefulBuilder(
                        builder: (_, StateSetter setModal) => Expanded(
                          child: ReorderableListView(
                            onReorder: (int oldIndex, int newIndex) {
                              if (oldIndex == newIndex) return;

                              // Local UI update first
                              final String toMove = widget._appList.removeAt(oldIndex);
                              widget._appList.insert(
                                oldIndex < newIndex ? newIndex - 1 : newIndex,
                                toMove,
                              );
                              setModal(() {});
                            },
                            children: widget._appList
                                .map((String id) {
                                  final AppInfo? app = appInfo.appMap[id];
                                  if (app == null) return null;

                                  return Padding(
                                    key: ValueKey<String>(id),
                                    padding: EdgeInsets.symmetric(vertical: EzConfig.spacing / 2),
                                    child: EzRow(
                                      // The Row prevents the AppTile from auto-expanding
                                      reverseHands: false,
                                      mainAxisAlignment: hAlign.mainAxis,
                                      crossAxisAlignment: hAlign.crossAxis,
                                      children: <Widget>[
                                        // Drag handle
                                        EzIcon(
                                          Icons.drag_handle,
                                          color: EzConfig.colors.outline,
                                        ),
                                        EzConfig.rowMargin,

                                        // App tile
                                        AppButton(
                                          app: app,
                                          labelType: folderLabels,
                                          buttonType: folderBT,
                                        ),
                                        EzConfig.rowSpacer,

                                        // Remove button
                                        EzIconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            widget._appList.remove(id);
                                            setModal(() {});
                                          },
                                        ),

                                        // Drag handle
                                        EzConfig.rowMargin,
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
                    );

                    await appInfo.updateFolder(
                      name: widget._name,
                      index: widget.index,
                      ids: widget._appList,
                    );
                    widget.onEdit();
                  },
                ),
                editSpacer,

                // Delete folder
                EzIconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final bool success = await appInfo.deleteFolder(widget.index);
                    if (success) widget.onEdit();
                  },
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}

class FolderButton extends StatelessWidget {
  final String name;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const FolderButton({
    super.key,
    required this.name,
    required this.buttonType,
    required this.labelType,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    switch (buttonType) {
      case ButtonType.icon:
        return Tooltip(
          message: name,
          child: GestureDetector(
            onTap: onPressed,
            onLongPress: onLongPress,
            child: Icon(Icons.folder_open, size: appIconSize),
          ),
        );
      case ButtonType.eIcon:
        return EzIconButton(
          tooltip: name,
          onPressed: onPressed,
          onLongPress: onLongPress,
          icon: Icon(Icons.folder_open, size: appIconSize),
        );
      case ButtonType.text:
        return EzTextButton(
          text: buildLabel(name, labelType),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.eText:
        return EzElevatedButton(
          text: buildLabel(name, labelType),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.textIcon:
        return EzTextIconButton(
          label: buildLabel(name, labelType),
          icon: Icon(Icons.folder_open, size: appIconSize),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.eTextIcon:
        return EzElevatedIconButton(
          label: buildLabel(name, labelType),
          icon: Icon(Icons.folder_open, size: appIconSize),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
    }
  }
}
