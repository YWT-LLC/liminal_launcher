/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;
  final AppInfoProvider appProvider;

  /// true for home list, null for home folder, false for false
  /// Quantum computing
  final bool? onHomeScreen;

  final ListAlignment hAlign;
  final LabelType labelType;
  final bool showIcon;
  final Future<void> Function(String id) onSelected;
  final bool editable;
  final bool? editing;
  final void Function() refresh;
  final ValueNotifier<double>? rippleProgress;

  const AppTile({
    super.key,
    required this.app,
    required this.appProvider,
    required this.onHomeScreen,
    required this.hAlign,
    required this.labelType,
    required this.showIcon,
    required this.onSelected,
    this.editable = true,
    required this.editing,
    required this.refresh,
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
  }

  @override
  Widget build(BuildContext context) {
    // Gather the contextual theme data //

    final double appIconSize = (EzConfig.iconSize * 1.25) + EzConfig.padding;

    // Return the build //
    return Visibility(
      visible: rippleThrottle == null,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: editing == false
          ? Row(
              // The Row prevents the AppTile from auto-expanding
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.hAlign.mainAxis,
              crossAxisAlignment: widget.hAlign.crossAxis,
              children: <Widget>[
                TileButton(
                  app: widget.app,
                  labelType: widget.labelType,
                  showIcon: widget.showIcon,
                  onPressed: () => widget.onSelected(widget.app.id),
                  onLongPress: () => widget.editable
                      ? setState(() => editing = true)
                      : doNothing,
                ),
              ],
            )
          : EzScrollView(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.hAlign.mainAxis,
              crossAxisAlignment: widget.hAlign.crossAxis,
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
                  EzConfig.layout.rowSpacer,
                ],

                // Add to home
                if (!widget.appProvider.hiddenSet.contains(widget.app.id) &&
                    !widget.appProvider.homeSet
                        .contains(widget.app.id)) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success =
                          await widget.appProvider.addHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.refresh();
                      }
                    },
                    icon: const Icon(Icons.add_to_home_screen),
                  ),
                  EzConfig.layout.rowSpacer,
                ],

                // Remove from home
                if (widget.onHomeScreen == true) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success =
                          await widget.appProvider.removeHomeApp(widget.app.id);

                      if (success) {
                        setState(() => editing = false);
                        widget.refresh();
                      }
                    },
                    icon: Icon(PlatformIcons(context).remove),
                  ),
                  EzConfig.layout.rowSpacer,
                ],

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
                EzConfig.layout.rowSpacer,

                // Rename
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

                          final bool success = await widget.appProvider
                              .renameApp(newName: name, appID: widget.app.id);

                          if (success) {
                            if (dContext.mounted) {
                              Navigator.of(dContext).pop(name);
                            }
                            widget.refresh();
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
                          confirmMsg: EzConfig.l10n.gApply,
                          onConfirm: onConfirm,
                          confirmIsDestructive: true,
                          denyMsg: EzConfig.l10n.gCancel,
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
                              autofillHints: const <String>[
                                AutofillHints.name,
                              ],
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
                EzConfig.layout.rowSpacer,

                // Show/hide
                EzIconButton(
                  onPressed: () async {
                    widget.appProvider.hiddenSet.contains(widget.app.id)
                        ? await widget.appProvider.showApp(widget.app.id)
                        : await widget.appProvider.hideApp(widget.app.id);
                    setState(() => editing = false);
                    widget.refresh();
                  },
                  icon: Icon(
                      widget.appProvider.hiddenSet.contains(widget.app.id)
                          ? PlatformIcons(context).eyeSolid
                          : PlatformIcons(context).eyeSlash),
                ),

                // Delete
                if (widget.app.removable) ...<Widget>[
                  EzConfig.layout.rowSpacer,
                  EzIconButton(
                    onPressed: () async {
                      final bool deleted = await deleteApp(context, widget.app);

                      if (deleted) {
                        setState(() => editing = false);
                        await widget.appProvider.removeDeleted(widget.app.id);
                        widget.refresh();
                      }
                    },
                    icon: Icon(PlatformIcons(context).delete),
                  ),
                ],

                // Close/end edits
                if (editing == true) ...<Widget>[
                  EzConfig.layout.rowSpacer,
                  EzIconButton(
                    onPressed: () => setState(() => editing = false),
                    icon: const Icon(Icons.close),
                  ),
                ],

                // Drag handle
                if (widget.onHomeScreen == true && editing == null) ...<Widget>[
                  EzConfig.layout.rowSpacer,
                  EzIcon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.outline,
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
    late final double appIconSize =
        (EzConfig.iconSize * 1.25) + EzConfig.padding;

    late final Widget? iconImage = (app.icon == null)
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
          child: iconImage,
        ),
      );
    }

    late final String label;

    switch (labelType) {
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

    return (showIcon && iconImage != null)
        ? EzTextIconButton(
            label: label,
            icon: iconImage,
            style:
                TextButton.styleFrom(padding: EzInsets.wrap(EzConfig.margin)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          )
        : EzTextButton(
            text: label,
            style:
                TextButton.styleFrom(padding: EzInsets.wrap(EzConfig.margin)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          );
  }
}
