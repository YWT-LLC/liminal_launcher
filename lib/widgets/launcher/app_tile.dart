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
  final AppLocation location;
  final AppState state;
  final Future<void> Function(String id) onSelected;
  final ValueNotifier<double>? rippleProgress;

  AppTile({
    required this.app,
    required this.location,
    required this.state,
    required this.onSelected,
    this.rippleProgress,
  }) : super(key: ValueKey<AppState>(state));

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Define the build data //

  late final bool inList = widget.location == AppLocation.list;
  late final bool inFolder = widget.location == AppLocation.home;

  late AppState state = widget.state;
  Timer? rippleThrottle;

  // Define custom functions //

  Widget editSpacer() => GestureDetector(
        onLongPress: () => switch (state) {
          AppState.standard || AppState.verbose || AppState.groupEdit => null,
          AppState.singleEdit => setState(() => state = AppState.standard),
        },
        child: state == AppState.verbose
            ? SizedBox(
                height: EzConfig.iconSize,
                child: VerticalDivider(
                  width: EzConfig.spacing,
                  color: EzConfig.colors.secondary,
                ),
              )
            : SizedBox(height: EzConfig.iconSize, width: EzConfig.spacing),
      );

  List<Widget> publisherLink() {
    final List<String> parts = widget.app.package.split('.');
    late final String base;

    if (parts.length >= 2) {
      base = '${parts[1]}.${parts[0]}';
    } else {
      return <Widget>[];
    }
    final bool isUrl = ezUrlCheck('https://$base');

    return isUrl
        ? <Widget>[
            EzLink(
              base,
              url: Uri.parse('https://$base'),
              hint: EzConfig.l10n.gOpenLink,
              style: EzConfig.styles.bodyLarge,
              textAlign: hAlign.textAlign,
            ),
            editSpacer(),
          ]
        : <Widget>[];
  }

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
      setState(() => state = switch (state) {
            AppState.standard ||
            AppState.singleEdit =>
              inList ? AppState.verbose : AppState.groupEdit,
            AppState.verbose || AppState.groupEdit => AppState.standard,
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
          AppState.standard => AppButton(
              app: widget.app,
              labelType: inFolder ? folderLabels : listLabels,
              buttonType: inFolder ? folderBT : listBT,
              onPressed: () => widget.onSelected(widget.app.id),
              onLongPress: () =>
                  inFolder ? doNothing() : setState(() => state = AppState.singleEdit),
            ),
          AppState.verbose => EzScrollView(
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              scrollDirection: Axis.horizontal,
              reverseHands: true,
              showScrollHint: true,
              children: <Widget>[
                // Name && icon
                AppButton(
                  app: widget.app,
                  labelType: inFolder ? folderLabels : listLabels,
                  buttonType: inFolder ? folderBT : listBT,
                  onPressed: () => widget.onSelected(widget.app.id),
                ),
                editSpacer(),

                // Publisher (plain text)
                EzText(widget.app.package, textAlign: hAlign.textAlign),
                editSpacer(),

                // Publisher (link)
                ...publisherLink(),

                // Install date
                EzText(
                  DateTypeConfig.buildDate(
                    context,
                    DateTime.fromMillisecondsSinceEpoch(widget.app.installDate),
                    DateType.compact,
                  ),
                  textAlign: hAlign.textAlign,
                ),
                editSpacer(),

                // Package size
                EzText(
                  '${(widget.app.packageSize / _toMB).toStringAsFixed(2)} MB',
                  textAlign: hAlign.textAlign,
                ),
              ],
            ),
          AppState.singleEdit || AppState.groupEdit => EzScrollView(
              mainAxisAlignment: hAlign.mainAxis,
              crossAxisAlignment: hAlign.crossAxis,
              scrollDirection: Axis.horizontal,
              reverseHands: true,
              showScrollHint: true,
              children: <Widget>[
                if (!inList) ...<Widget>[
                  // Drag handle
                  EzIcon(
                    Icons.drag_handle,
                    color: EzConfig.colors.outline,
                  ),
                  EzConfig.rowMargin,
                ],

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
                  editSpacer(),
                ],

                // Info
                EzIconButton(
                  onPressed: () async {
                    if (inList && context.mounted) Navigator.of(context).pop();
                    await openSettings(widget.app.id);
                  },
                  icon: const Icon(Icons.info),
                ),
                editSpacer(),

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
                        if (success && dCon.mounted) Navigator.of(dCon).pop(name);
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
                editSpacer(),

                // Add to home
                if (!appInfo.homeSet.contains(widget.app.id) &&
                    !appInfo.hiddenSet.contains(widget.app.id)) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success = await appInfo.addHomeApp(widget.app.id);

                      if (success && state == AppState.singleEdit) {
                        setState(() => state = AppState.standard);
                      }
                    },
                    icon: const Icon(Icons.add_to_home_screen),
                  ),
                  editSpacer(),
                ],

                // Remove from home
                if (!inList) ...<Widget>[
                  EzIconButton(
                    onPressed: () async {
                      final bool success = await appInfo.removeHomeApp(widget.app.id);
                      if (success && mounted) setState(() => state = AppState.standard);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  editSpacer(),
                ],

                // Show/hide
                EzIconButton(
                  onPressed: () async {
                    final bool success = appInfo.hiddenSet.contains(widget.app.id)
                        ? await appInfo.showApp(widget.app.id)
                        : await appInfo.hideApp(widget.app.id);
                    if (success && mounted) setState(() => state = AppState.standard);
                  },
                  icon: Icon(
                    appInfo.hiddenSet.contains(widget.app.id)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                editSpacer(),

                // Banish
                EzIconButton(
                  onPressed: () async {
                    final bool banished = await appInfo.banishApp(widget.app.id);
                    if (banished && mounted) setState(() => state = AppState.standard);
                  },
                  icon: const Icon(LineIcons.ghost),
                ),

                // Delete
                if (widget.app.removable) ...<Widget>[
                  editSpacer(),
                  EzIconButton(
                    onPressed: () async {
                      final bool deleted = await deleteApp(context, widget.app);

                      if (deleted) {
                        await appInfo.removeDeleted(widget.app.id);
                        if (mounted) setState(() => state = AppState.standard);
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],

                if (!inList) ...<Widget>[
                  // Drag handle
                  EzIcon(
                    Icons.drag_handle,
                    color: EzConfig.colors.outline,
                  ),
                  EzConfig.rowMargin,
                ],
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
            size: EzConfig.iconSize,
          )
      : Image.memory(
          app.icon!,
          semanticLabel: app.name,
          width: appIconSize,
          height: appIconSize,
        );

  @override
  Widget build(BuildContext context) => switch (buttonType) {
        ButtonType.icon => Tooltip(
            message: app.name,
            child: GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: appIcon(),
            )),
        ButtonType.eIcon => EzIconButton(
            tooltip: app.name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: appIcon(),
          ),
        ButtonType.text => EzTextButton(
            text: buildLabel(app.name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            text: buildLabel(app.name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            label: buildLabel(app.name, labelType),
            icon: appIcon(),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            label: buildLabel(app.name, labelType),
            icon: appIcon(),
            style: TextButton.styleFrom(padding: EdgeInsets.all(EzConfig.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}

const int _toMB = 1048576;
