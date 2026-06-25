/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

// TODO: add custom icons, same strategy as folder (not as rename, I don't want it to be global)
// TODO: edit container
// TODO: make the design page the "system" button, and allow for people to set per-tile shapes
// TODO: use numLanes per (saved) small screen value to decide whether to show scrolls or just the edit container
// TODO: fix padding on text button when no background opacity

import '../../utils/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTile extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int? lane;
  final int? index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  final AppInfo app;
  final AppLocation location;
  final Future<void> Function(AppInfo app) onSelected;

  AppTile(
    this.config, {
    required this.appInfo,
    this.lane,
    this.index,
    required this.state,
    this.rippleProgress,
    required this.app,
    required this.location,
    required this.onSelected,
  }) : super(key: ValueKey<String>('${app.id}-${state.name}'));

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  late final bool inList = widget.location == AppLocation.list;
  late final bool inFolder = widget.location == AppLocation.folder;

  // Define custom functions //

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
            _ => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  Widget rowSpacer() => switch (state) {
        AppState.standard ||
        AppState.groupEdit =>
          SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
        AppState.verbose => SizedBox(
            height: widget.config.iconSize,
            child: VerticalDivider(
                width: widget.config.spacing, color: widget.config.colors.secondary),
          ),
        AppState.singleEdit => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => setState(() => state = AppState.standard),
            child: SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
          ),
      };

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
              widget.config,
              text: base,
              url: Uri.parse('https://$base'),
              hint: widget.config.ezL10n.gOpenLink,
              style: widget.config.bodyStyle,
              textAlign: hAlign(widget.config).textAlign,
            ),
            rowSpacer(),
          ]
        : <Widget>[];
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
    final ListAlignment hA = hAlign(widget.config);

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard => !inFolder && wideTiles(widget.config)
            ? InkWell(
                onTap: () => widget.onSelected(widget.app),
                onLongPress: () => canEdit(
                  widget.config,
                  () async => setState(() => state = AppState.singleEdit),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: LAConfig.merge(h: hA, v: ListAlignment.center),
                  child: AppButton(
                    widget.config,
                    app: widget.app,
                    labelType: listLabels(widget.config),
                    buttonType: listBT(widget.config),
                    onPressed: () => widget.onSelected(widget.app),
                    onLongPress: () => canEdit(
                      widget.config,
                      () async => setState(() => state = AppState.singleEdit),
                    ),
                  ),
                ),
              )
            : inFolder
                ? AppButton(
                    widget.config,
                    app: widget.app,
                    labelType: folderLabels(widget.config),
                    buttonType: folderBT(widget.config),
                    onPressed: () => widget.onSelected(widget.app),
                    onLongPress: doNothing,
                  )
                : AppButton(
                    widget.config,
                    app: widget.app,
                    labelType: listLabels(widget.config),
                    buttonType: listBT(widget.config),
                    onPressed: () => widget.onSelected(widget.app),
                    onLongPress: () => canEdit(
                      widget.config,
                      () async => setState(() => state = AppState.singleEdit),
                    ),
                  ),
        AppState.verbose => EzScrollBlocker(
            EzScrollView(
              widget.config,
              reverseHands: true,
              showScrollHint: true,
              thumbVisibility: false,
              mainAxisAlignment: hA.mainAxis,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                // Name && icon
                AppButton(
                  widget.config,
                  app: widget.app,
                  labelType: inFolder ? folderLabels(widget.config) : listLabels(widget.config),
                  buttonType: inFolder ? folderBT(widget.config) : listBT(widget.config),
                  onPressed: () => widget.onSelected(widget.app),
                ),
                rowSpacer(),

                // Publisher (plain text)
                EzText(
                  widget.config,
                  text: widget.app.package,
                  textAlign: hA.textAlign,
                ),
                rowSpacer(),

                // Publisher (link)
                ...publisherLink(),

                // Install date
                EzText(
                  widget.config,
                  text: DTConfig.buildDate(
                    context,
                    DateTime.fromMillisecondsSinceEpoch(widget.app.installDate),
                    DateType.compact,
                  ),
                  textAlign: hA.textAlign,
                ),
                rowSpacer(),

                // Package size
                EzText(
                  widget.config,
                  text: '${(widget.app.packageSize / _toMB).toStringAsFixed(2)} MB',
                  textAlign: hA.textAlign,
                ),
              ],
            ),
          ),
        AppState.singleEdit || AppState.groupEdit => Container(
            width: double.infinity,
            alignment: LAConfig.merge(h: hA, v: ListAlignment.center),
            child: EzScrollBlocker(
              EzScrollView(
                widget.config,
                reverseHands: true,
                showScrollHint: true,
                thumbVisibility: false,
                mainAxisAlignment: hA.mainAxis,
                mainAxisSize: MainAxisSize.max,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  if (!inList && state != AppState.singleEdit) ...<Widget>[
                    // Drag handle
                    EzIcon(
                      widget.config,
                      Icons.drag_handle,
                      color: widget.config.colors.outline,
                    ),
                    widget.config.rowMargin,
                  ],

                  // App icon
                  if (widget.app.icon != null) ...<Widget>[
                    GestureDetector(
                      onTap: () => widget.onSelected(widget.app),
                      child: Image.memory(
                        widget.app.icon!,
                        semanticLabel: widget.app.name,
                        width: appIconSize(widget.config),
                        height: appIconSize(widget.config),
                        alignment: LAConfig.merge(h: hA, v: ListAlignment.center),
                      ),
                    ),
                    rowSpacer(),
                  ],

                  // Info
                  EzIconButton(
                    widget.config,
                    onPressed: () async {
                      if (inList && context.mounted) Navigator.of(context).pop();
                      await openSettings(widget.app);
                    },
                    icon: EzIcon(widget.config, Icons.info),
                  ),
                  rowSpacer(),

                  // Rename
                  EzIconButton(
                    widget.config,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext dCon) {
                        final TextEditingController renameController = TextEditingController();

                        Future<void> onConfirm() async {
                          closeKeyboard(dCon);

                          final String name = renameController.text.trim();
                          if (validateRename(name) != null) return;

                          final bool success =
                              await widget.appInfo.renameApp(newName: name, appID: widget.app.id);
                          if (success && dCon.mounted) Navigator.of(dCon).pop(name);
                        }

                        void onDeny() {
                          closeKeyboard(dCon);
                          Navigator.of(dCon).pop();
                        }

                        return EzAlertDialog(
                          widget.config,
                          title: Text(
                            'Rename ${widget.app.name}?',
                            textAlign: TextAlign.center,
                          ),
                          content: TextFormField(
                            controller: renameController,
                            textAlign: TextAlign.center,
                            autofillHints: const <String>[AutofillHints.name],
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            validator: validateRename,
                          ),
                          actions: ezActionPair(
                            widget.config,
                            confirmMsg: widget.config.ezL10n.gApply,
                            onConfirm: onConfirm,
                            confirmIsDestructive: true,
                            denyMsg: widget.config.ezL10n.gCancel,
                            onDeny: onDeny,
                          ),
                          needsClose: false,
                        );
                      },
                    ),
                    icon: EzIcon(widget.config, Icons.edit),
                  ),
                  rowSpacer(),

                  // Add to home
                  if (inList &&
                      widget.appInfo.numLanes(widget.config) == 1 &&
                      !widget.appInfo.homeSet(widget.config).contains(widget.app.id) &&
                      !widget.appInfo.hiddenSet.contains(widget.app.id)) ...<Widget>[
                    EzIconButton(
                      widget.config,
                      onPressed: () async {
                        await widget.appInfo.addApp(
                          widget.config,
                          lane: 0,
                          id: widget.app.id,
                        );
                        setState(() => state = AppState.standard);
                      },
                      icon: EzIcon(widget.config, Icons.add_to_home_screen),
                    ),
                    rowSpacer(),
                  ],

                  // Remove from home
                  if (!inList) ...<Widget>[
                    EzIconButton(
                      widget.config,
                      onPressed: () async {
                        final bool success = await widget.appInfo.removeHomeApp(
                          widget.config,
                          lane: widget.lane,
                          index: widget.index,
                          id: widget.app.id,
                        );

                        if (success && mounted) setState(() => state = AppState.standard);
                      },
                      icon: EzIcon(widget.config, Icons.remove),
                    ),
                    rowSpacer(),
                  ],

                  // Show/hide
                  EzIconButton(
                    widget.config,
                    onPressed: () async {
                      widget.appInfo.hiddenSet.contains(widget.app.id)
                          ? await widget.appInfo.showApp(widget.app.id)
                          : await widget.appInfo.hideApp(
                              widget.config,
                              context: context,
                              id: widget.app.id,
                              lane: widget.lane,
                              index: widget.index,
                            );

                      if (mounted) setState(() => state = AppState.standard);
                    },
                    icon: EzIcon(
                      widget.config,
                      widget.appInfo.hiddenSet.contains(widget.app.id)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  rowSpacer(),

                  // Banish
                  EzIconButton(
                    widget.config,
                    onPressed: () async {
                      final bool banished = await widget.appInfo.banishApp(
                        widget.config,
                        context: context,
                        id: widget.app.id,
                        lane: widget.lane,
                        index: widget.index,
                      );
                      if (banished && mounted) setState(() => state = AppState.standard);
                    },
                    icon: EzIcon(widget.config, LineIcons.ghost),
                  ),

                  // Delete
                  if (widget.app.removable) ...<Widget>[
                    rowSpacer(),
                    EzIconButton(
                      widget.config,
                      onPressed: () async => await openDelete(widget.app),
                      icon: EzIcon(widget.config, Icons.delete),
                    ),
                  ],

                  if (!inList && state != AppState.singleEdit) ...<Widget>[
                    // Drag handle
                    EzIcon(
                      widget.config,
                      Icons.drag_handle,
                      color: widget.config.colors.outline,
                    ),
                    widget.config.rowMargin,
                  ],
                ],
              ),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    widget.rippleProgress?.removeListener(rippling);
    super.dispose();
  }
}

class AppButton extends StatelessWidget {
  final EzCP config;
  final AppInfo app;
  final Widget? icon;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const AppButton(
    this.config, {
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
            size: appIconSize(config),
          )
      : Image.memory(
          app.icon!,
          semanticLabel: app.name,
          width: appIconSize(config),
          height: appIconSize(config),
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
            config,
            tooltip: app.name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: appIcon(),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(app.name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            config,
            text: buildLabel(app.name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            config,
            label: buildLabel(app.name, labelType),
            icon: appIcon(),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(app.name, labelType),
            icon: appIcon(),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}

const int _toMB = 1048576;
