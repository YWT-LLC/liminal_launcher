/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class FolderTile extends StatefulWidget {
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _name;
  late final List<String> _appList;

  FolderTile({
    required this.index,
    required this.state,
    this.rippleProgress,
  }) : super(key: ValueKey<AppState>(state)) {
    final List<String> items = appInfo.homeList[index].split(folderSplit);

    _name = items[0];
    _appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
  }

  @override
  State<FolderTile> createState() => _AppFolderState();
}

class _AppFolderState extends State<FolderTile> {
  // Define the build data //

  bool open = false;
  late AppState state = widget.state;
  Timer? rippleThrottle;

  // Define custom functions //

  Widget editSpacer() => GestureDetector(
        onLongPress: () => switch (state) {
          AppState.standard || AppState.verbose || AppState.groupEdit => null,
          AppState.singleEdit => setState(() => state = AppState.standard),
        },
        child: EzConfig.rowSpacer,
      );

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }
    final Offset wya = ezWya(context);
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dy <= widget.rippleProgress!.value * heightOf(context)) {
      setState(() => state = switch (state) {
            AppState.standard || AppState.verbose || AppState.singleEdit => AppState.groupEdit,
            AppState.groupEdit => AppState.singleEdit,
          });

      final Duration animDur = ezAnimDuration(mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
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
  Widget build(BuildContext context) => EzAnimSwitch(
        mod: 0.667,
        forceType: EzTransitionType.none,
        forceFade: true,
        child: switch (state) {
          AppState.standard => open
              ? TapRegion(
                  onTapOutside: (_) => setState(() => open = !open),
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
                              location: AppLocation.folder,
                              state: state,
                              onSelected: (String id) => launchApp(id),
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
                  onPressed: () => setState(() => open = !open),
                  onLongPress: () => setState(() => state = AppState.singleEdit),
                ),
          AppState.verbose => const SizedBox.shrink(), // Shouldn't be possible
          AppState.singleEdit || AppState.groupEdit => EzScrollView(
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
                        if (success && dCon.mounted) Navigator.of(dCon).pop(name);
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
                editSpacer(),

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
                  },
                ),
                editSpacer(),

                // Delete folder
                EzIconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => appInfo.deleteFolder(widget.index),
                ),
              ],
            ),
        },
      );

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
  Widget build(BuildContext context) => switch (buttonType) {
        ButtonType.icon => Tooltip(
            message: name,
            child: GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: Icon(Icons.folder_open, size: appIconSize),
            )),
        ButtonType.eIcon => EzIconButton(
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: Icon(Icons.folder_open, size: appIconSize),
          ),
        ButtonType.text => EzTextButton(
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            label: buildLabel(name, labelType),
            icon: Icon(Icons.folder_open, size: appIconSize),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            label: buildLabel(name, labelType),
            icon: Icon(Icons.folder_open, size: appIconSize),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}
