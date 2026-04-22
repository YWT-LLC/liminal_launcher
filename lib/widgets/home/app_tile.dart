/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;

  /// true == home list
  /// null == home folder
  /// false == false
  /// Quantum supremacy
  final bool? onHomeScreen;

  final Future<void> Function(String id) onSelected;
  final bool editable;
  final bool? editing;
  final void Function() onEdit;
  final ValueNotifier<double>? rippleProgress;

  const AppTile({
    super.key,
    required this.app,
    required this.onHomeScreen,
    required this.onSelected,
    this.editable = true,
    required this.editing,
    required this.onEdit,
    this.rippleProgress,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Define the build data //

  late bool? editing = widget.editable ? widget.editing : false;
  Timer? rippleThrottle;

  // Define custom functions //

  /// Handle rippling effect
  /// Transition to editing on home screen long press
  void rippling() {
    if (widget.editable == false ||
        rippleThrottle != null ||
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
    return Visibility(
      visible: rippleThrottle == null,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: editing == false
          ? Row(
              // The Row prevents the AppTile from auto-expanding
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              children: <Widget>[
                TileButton(
                  app: widget.app,
                  labelType:
                      (widget.onHomeScreen == null) ? folderLabels : listLabels,
                  showIcon:
                      (widget.onHomeScreen == null) ? folderIcons : listIcons,
                  onPressed: () => widget.onSelected(widget.app.id),
                  onLongPress: () => widget.editable
                      ? setState(() => editing = true)
                      : doNothing,
                ),
              ],
            )
          : EzScrollView(
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              scrollDirection: Axis.horizontal,
              reverseHands: true,
              showScrollHint: true,
              children: <Widget>[
                // App icon
                if (widget.app.icon != null) ...<Widget>[
                  GestureDetector(
                    onTap: () => widget.onSelected(widget.app.id),
                    child: Image.memory(
                      widget.app.icon!,
                      semanticLabel: widget.app.name,
                      width: appIconSize,
                      height: appIconSize,
                    ),
                  ),
                  EzConfig.rowSpacer,
                ],

                // Add to home
                if (!appInfo.homeSet.contains(widget.app.id) &&
                    !appInfo.hiddenSet.contains(widget.app.id)) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success =
                          await appInfo.addHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.onEdit();
                      }
                    },
                    icon: const Icon(Icons.add_to_home_screen),
                  ),
                  EzConfig.rowSpacer,
                ],

                // Remove from home
                if (widget.onHomeScreen == true) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success =
                          await appInfo.removeHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.onEdit();
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  EzConfig.rowSpacer,
                ],

                // Info
                EzIconButton(
                  onPressed: () async {
                    await openSettings(widget.app.id);
                    if (widget.onHomeScreen == false && context.mounted) {
                      Navigator.of(context).pop();
                    }
                    widget.onEdit();
                  },
                  icon: const Icon(Icons.info),
                ),
                EzConfig.rowSpacer,

                // Rename
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

                        final bool success = await appInfo.renameApp(
                            newName: name, appID: widget.app.id);

                        if (success) {
                          if (dCon.mounted) {
                            Navigator.of(dCon).pop(name);
                          }
                          widget.onEdit();
                        }
                      }

                      void onDeny() {
                        closeKeyboard(dCon);
                        Navigator.of(dCon).pop();
                      }

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
                  icon: const Icon(Icons.edit),
                ),
                EzConfig.rowSpacer,

                // Show/hide
                EzIconButton(
                  onPressed: () async {
                    final bool result =
                        appInfo.hiddenSet.contains(widget.app.id)
                            ? await appInfo.showApp(widget.app.id)
                            : await appInfo.hideApp(widget.app.id);

                    if (result) {
                      setState(() => editing = false);
                      widget.onEdit();
                    }
                  },
                  icon: Icon(
                    appInfo.hiddenSet.contains(widget.app.id)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                EzConfig.rowSpacer,

                // Banish
                EzIconButton(
                  onPressed: () async {
                    final bool banished =
                        await appInfo.banishApp(widget.app.id);

                    if (banished) {
                      setState(() => editing = false);
                      widget.onEdit();
                    }
                  },
                  icon: const Icon(LineIcons.ghost),
                ),

                // Delete
                if (widget.app.removable) ...<Widget>[
                  EzConfig.rowSpacer,
                  EzIconButton(
                    onPressed: () async {
                      final bool deleted = await deleteApp(context, widget.app);

                      if (deleted) {
                        setState(() => editing = false);
                        await appInfo.removeDeleted(widget.app.id);
                        widget.onEdit();
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],

                // Close/end edits
                if (editing == true) ...<Widget>[
                  EzConfig.rowSpacer,
                  EzIconButton(
                    onPressed: () => setState(() => editing = false),
                    icon: const Icon(Icons.close),
                  ),
                ],

                // Drag handle
                if (widget.onHomeScreen == true && editing == null) ...<Widget>[
                  EzConfig.rowSpacer,
                  EzIcon(
                    Icons.drag_handle,
                    color: EzConfig.colors.outline,
                  ),
                ],
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

class TileButton extends StatelessWidget {
  final AppInfo app;
  final LabelType labelType;
  final bool showIcon;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const TileButton({
    super.key,
    required this.app,
    required this.labelType,
    required this.showIcon,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget? appIcon = (app.icon == null)
        ? null
        : Image.memory(
            app.icon!,
            semanticLabel: app.name,
            width: appIconSize,
            height: appIconSize,
          );

    if (labelType == LabelType.none) {
      return Tooltip(
        message: app.name,
        child: GestureDetector(
          onTap: onPressed,
          onLongPress: onLongPress,
          child: appIcon,
        ),
      );
    }

    return (showIcon && appIcon != null)
        ? EzTextIconButton(
            label: buildLabel(app.name, labelType),
            icon: appIcon,
            style: TextButton.styleFrom(
                padding: EzInsets.wrap(EzConfig.marginVal)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          )
        : EzTextButton(
            text: buildLabel(app.name, labelType),
            style: TextButton.styleFrom(
                padding: EzInsets.wrap(EzConfig.marginVal)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          );
  }
}
