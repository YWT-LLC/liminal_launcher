/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:after_layout/after_layout.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;

  /// true == home list
  /// null == home folder
  /// false == false
  /// Quantum supremacy achieved (⌐■_■)
  final bool? onHomeScreen;

  final Future<void> Function(String id) onSelected;

  /// true == individual edits
  /// null == group edits
  /// false == false
  /// Quantum supremacy achieved (⌐■_■)
  final bool? editing;

  final void Function() onEdit;
  final ValueNotifier<double>? rippleProgress;

  const AppTile({
    super.key,
    required this.app,
    required this.onHomeScreen,
    required this.onSelected,
    required this.editing,
    required this.onEdit,
    this.rippleProgress,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> with AfterLayoutMixin<AppTile> {
  // Define the build data //

  late bool? editing = widget.editing;
  Timer? rippleThrottle;

  Size hideSize = Size(appIconSize, appIconSize);

  // Define custom functions //

  /// Handle rippling effect
  /// Transition to editing on home screen long press
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
      mod: 0.5,
      visible: rippleThrottle == null,
      size: hideSize,
      kid: editing == false
          ? EzRow(
              // The Row prevents the AppTile from auto-expanding
              reverseHands: false,
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              children: <Widget>[
                AppButton(
                  app: widget.app,
                  labelType: (widget.onHomeScreen == null) ? folderLabels : listLabels,
                  buttonType: (widget.onHomeScreen == null) ? folderBT : listBT,
                  onPressed: () => widget.onSelected(widget.app.id),
                  onLongPress: () =>
                      widget.onHomeScreen == null ? doNothing() : setState(() => editing = true),
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
                // Drag handle
                EzIcon(
                  Icons.drag_handle,
                  color: EzConfig.colors.outline,
                ),
                EzConfig.rowSpacer,

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
                  editSpacer,
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
                editSpacer,

                // Rename
                EzIconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext dCon) {
                      final TextEditingController renameController = TextEditingController();

                      void onConfirm() async {
                        closeKeyboard(dCon);

                        final String name = renameController.text.trim();
                        if (validateRename(name) != null) return null;

                        final bool success =
                            await appInfo.renameApp(newName: name, appID: widget.app.id);

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
                editSpacer,

                // Add to home
                if (!appInfo.homeSet.contains(widget.app.id) &&
                    !appInfo.hiddenSet.contains(widget.app.id)) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success = await appInfo.addHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.onEdit();
                      }
                    },
                    icon: const Icon(Icons.add_to_home_screen),
                  ),
                  editSpacer,
                ],

                // Remove from home
                if (widget.onHomeScreen == true) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success = await appInfo.removeHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.onEdit();
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  editSpacer,
                ],

                // Show/hide
                EzIconButton(
                  onPressed: () async {
                    final bool result = appInfo.hiddenSet.contains(widget.app.id)
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
                editSpacer,

                // Banish
                EzIconButton(
                  onPressed: () async {
                    final bool banished = await appInfo.banishApp(widget.app.id);

                    if (banished) {
                      setState(() => editing = false);
                      widget.onEdit();
                    }
                  },
                  icon: const Icon(LineIcons.ghost),
                ),

                // Delete
                if (widget.app.removable) ...<Widget>[
                  editSpacer,
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

                // Drag handle
                EzIcon(
                  Icons.drag_handle,
                  color: EzConfig.colors.outline,
                ),
                EzConfig.rowSpacer,
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

class AppButton extends StatelessWidget {
  final AppInfo app;
  final Widget? icon;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const AppButton({
    super.key,
    required this.app,
    this.icon,
    required this.buttonType,
    required this.labelType,
    this.onPressed,
    this.onLongPress,
  });

  Widget appIcon() => (app.icon == null)
      ? icon ??
          Icon(
            Icons.question_mark,
            semanticLabel: app.name,
            size: appIconSize,
          )
      : Image.memory(
          app.icon!,
          semanticLabel: app.name,
          width: appIconSize,
          height: appIconSize,
        );

  @override
  Widget build(BuildContext context) {
    switch (buttonType) {
      case ButtonType.icon:
        return Tooltip(
          message: app.name,
          child: GestureDetector(
            onTap: onPressed,
            onLongPress: onLongPress,
            child: appIcon(),
          ),
        );
      case ButtonType.eIcon:
        return EzIconButton(
          tooltip: app.name,
          onPressed: onPressed,
          onLongPress: onLongPress,
          icon: appIcon(),
        );
      case ButtonType.text:
        return EzTextButton(
          text: buildLabel(app.name, labelType),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.eText:
        return EzElevatedButton(
          text: buildLabel(app.name, labelType),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.textIcon:
        return EzTextIconButton(
          label: buildLabel(app.name, labelType),
          icon: appIcon(),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
      case ButtonType.eTextIcon:
        return EzElevatedIconButton(
          label: buildLabel(app.name, labelType),
          icon: appIcon(),
          style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
          onPressed: onPressed,
          onLongPress: onLongPress,
        );
    }
  }
}
