/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;
  final AppInfoProvider listener;
  final AppInfoProvider editor;

  /// true for home list, null for home folder, false for false
  /// Quantum computing
  final bool? onHomeScreen;

  final ListAlignment hAlign;
  final LabelType labelType;
  final bool showIcon;
  final Future<void> Function(String id) onSelected;
  final bool editable;
  final bool editing;
  final void Function() refresh;

  const AppTile({
    super.key,
    required this.app,
    required this.listener,
    required this.editor,
    required this.onHomeScreen,
    required this.hAlign,
    required this.labelType,
    required this.showIcon,
    required this.onSelected,
    this.editable = true,
    required this.editing,
    required this.refresh,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Gather the theme data //

  final double iconSize = EzConfig.get(iconSizeKey);
  final double padding = EzConfig.get(paddingKey);

  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late bool editing = widget.editable && widget.editing;

  // Define custom functions //

  void holdTile() =>
      widget.editable ? setState(() => editing = !editing) : doNothing;

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return editing
        ? EzScrollView(
            mainAxisSize: MainAxisSize.min,
            reverseHands: true,
            scrollDirection: Axis.horizontal,
            showScrollHint: true,
            children: <Widget>[
              // App icon
              if (widget.app.icon != null) ...<Widget>[
                GestureDetector(
                  onTap: () => widget.onSelected(widget.app.id),
                  child: Image.memory(
                    widget.app.icon!,
                    semanticLabel: widget.app.name,
                    width: iconSize + padding,
                    height: iconSize + padding,
                  ),
                ),
                ezRowSpacer,
              ],

              // Rename
              EzIconButton(
                onPressed: () => showPlatformDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      final TextEditingController renameController =
                          TextEditingController();

                      void onConfirm() async {
                        closeKeyboard(dialogContext);

                        final String name = renameController.text.trim();
                        if (validateRename(name) != null) return null;

                        final bool success = await widget.editor
                            .renameApp(newName: name, appID: widget.app.id);

                        if (success) {
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(name);
                          }
                          widget.refresh();
                        }
                      }

                      void onDeny() {
                        closeKeyboard(dialogContext);
                        Navigator.of(dialogContext).pop();
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
                          'Rename ${widget.app.name}?',
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
                    }),
                icon: Icon(PlatformIcons(context).edit),
              ),
              ezRowSpacer,

              // Add to home
              if (!widget.listener.hiddenSet.contains(widget.app.id) &&
                  !widget.listener.homeSet.contains(widget.app.id)) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    final bool success =
                        await widget.editor.addHomeApp(widget.app.id);

                    if (success) {
                      setState(() => editing = false);
                      widget.refresh();
                    }
                  },
                  icon: const Icon(Icons.add_to_home_screen),
                ),
                ezRowSpacer,
              ],

              // Remove from home
              if (widget.onHomeScreen == true) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    final bool success =
                        await widget.editor.removeHomeApp(widget.app.id);

                    if (success) {
                      setState(() => editing = false);
                      widget.refresh();
                    }
                  },
                  icon: Icon(PlatformIcons(context).remove),
                ),
                ezRowSpacer,
              ],

              // Show/hide
              EzIconButton(
                onPressed: () async {
                  widget.listener.hiddenSet.contains(widget.app.id)
                      ? await widget.editor.showApp(widget.app.id)
                      : await widget.editor.hideApp(widget.app.id);
                  setState(() => editing = false);
                  widget.refresh();
                },
                icon: Icon(widget.listener.hiddenSet.contains(widget.app.id)
                    ? PlatformIcons(context).eyeSolid
                    : PlatformIcons(context).eyeSlash),
              ),
              ezRowSpacer,

              // Info
              EzIconButton(
                onPressed: () async {
                  await openSettings(widget.app.id);
                  if (widget.onHomeScreen == false && context.mounted) {
                    Navigator.of(context).pop();
                  }
                  widget.refresh();
                },
                icon: Icon(PlatformIcons(context).info),
              ),
              ezRowSpacer,

              // Delete
              if (widget.app.removable) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    final bool deleted = await deleteApp(context, widget.app);

                    if (deleted) {
                      setState(() => editing = false);
                      await widget.editor.removeDeleted(widget.app.id);
                      widget.refresh();
                    }
                  },
                  icon: Icon(PlatformIcons(context).delete),
                ),
                ezRowSpacer,
              ],

              // Close
              EzIconButton(
                onPressed: () => setState(() => editing = false),
                icon: const Icon(Icons.close),
              ),

              // Drag handle
              if (widget.onHomeScreen == true) ...<Widget>[
                ezRowSpacer,
                EzIcon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ],
          )
        :
        // Row prevents the tile from auto-expanding
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.hAlign.mainAxis,
            crossAxisAlignment: widget.hAlign.crossAxis,
            children: <Widget>[
              TileButton(
                app: widget.app,
                type: widget.labelType,
                showIcon: widget.showIcon,
                onPressed: () => widget.onSelected(widget.app.id),
                onLongPress: holdTile,
              ),
            ],
          );
  }
}

class TileButton extends StatelessWidget {
  final AppInfo app;
  final LabelType type;
  final bool showIcon;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const TileButton({
    super.key,
    required this.app,
    required this.type,
    required this.showIcon,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    late final double iconSize = EzConfig.get(iconSizeKey);
    late final double padding = EzConfig.get(paddingKey);

    late final Widget iconImage = (app.icon == null)
        ? const SizedBox.shrink()
        : Image.memory(
            app.icon!,
            semanticLabel: app.name,
            width: iconSize + padding,
            height: iconSize + padding,
          );

    if (type == LabelType.none) {
      return Tooltip(
        message: app.name,
        child: GestureDetector(
          onTap: onPressed,
          onLongPress: onLongPress,
          child: iconImage,
        ),
      );
    }

    late final String label;

    switch (type) {
      case LabelType.none:
        label = '';
        break;
      case LabelType.initials:
        label = app.name
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();
        break;
      case LabelType.full:
        label = app.name;
        break;
      case LabelType.wingding:
        label = app.name
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
        break;
    }

    return showIcon
        ? EzTextIconButton(
            icon: iconImage,
            label: label,
            onPressed: onPressed,
            onLongPress: onLongPress,
          )
        : EzTextButton(
            text: label,
            onPressed: onPressed,
            onLongPress: onLongPress,
          );
  }
}
