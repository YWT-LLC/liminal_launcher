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

class FolderTile extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _name;
  late final List<String> _appList;

  FolderTile(
    this.config, {
    required this.appInfo,
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

  Widget rowSpacer() => switch (state) {
        AppState.standard ||
        AppState.groupEdit ||
        AppState.verbose =>
          SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
        AppState.singleEdit => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => setState(() => state = AppState.standard),
            child: SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
          ),
      };

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
            AppState.standard || AppState.singleEdit => AppState.groupEdit,
            AppState.verbose || AppState.groupEdit => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
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
        widget.config,
        mod: 0.667,
        forceType: EzTransitionType.none,
        forceFade: true,
        child: switch (state) {
          AppState.standard => open
              ? TapRegion(
                  onTapOutside: (_) => setState(() => open = !open),
                  child: EzScrollView(
                    widget.config,
                    scrollDirection: Axis.horizontal,
                    mainAxisAlignment: hAlign(widget.config).mainAxis,
                    children: widget._appList
                        .map((String id) {
                          final AppInfo? app = widget.appInfo.appMap[id];
                          if (app == null) return null;

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: widget.config.spacing / 2),
                            child: AppTile(
                              widget.config,
                              appInfo: widget.appInfo,
                              app: app,
                              location: AppLocation.folder,
                              state: state,
                              onSelected: (AppInfo app) => launchApp(app),
                            ),
                          );
                        })
                        .whereType<Widget>()
                        .toList(),
                  ),
                )
              : wideTiles(widget.config)
                  ? InkWell(
                      onTap: () => setState(() => open = !open),
                      onLongPress: () => canEdit(
                        widget.config,
                        () async => setState(() => state = AppState.singleEdit),
                      ),
                      child: Container(
                        width: double.infinity,
                        alignment:
                            LAConfig.merge(h: hAlign(widget.config), v: vAlign(widget.config)),
                        child: FolderButton(
                          widget.config,
                          name: widget._name,
                          buttonType: folderBT(widget.config),
                          labelType: folderLabels(widget.config),
                          onPressed: () => setState(() => open = !open),
                          onLongPress: () => canEdit(
                            widget.config,
                            () async => setState(() => state = AppState.singleEdit),
                          ),
                        ),
                      ),
                    )
                  : FolderButton(
                      widget.config,
                      name: widget._name,
                      buttonType: folderBT(widget.config),
                      labelType: folderLabels(widget.config),
                      onPressed: () => setState(() => open = !open),
                      onLongPress: () => canEdit(
                        widget.config,
                        () async => setState(() => state = AppState.singleEdit),
                      ),
                    ),
          AppState.verbose => const SizedBox.shrink(), // Shouldn't be possible
          AppState.singleEdit || AppState.groupEdit => EzScrollView(
              widget.config,
              mainAxisSize: MainAxisSize.max,
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: hAlign(widget.config).mainAxis,
              children: <Widget>[
                // Name (and rename)
                EzLink(
                  widget.config,
                  text: widget._name,
                  style: widget.config.bodyStyle,
                  textColor: widget.config.colors.onSurface,
                  textAlign: TextAlign.center,
                  hint: 'Activate to rename.',
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext dCon) {
                      final TextEditingController renameCon = TextEditingController();

                      void onConfirm() async {
                        closeKeyboard(dCon);

                        final String name = renameCon.text.trim();
                        if (validateRename(name) != null) return null;

                        final bool success = await widget.appInfo.renameFolder(name, widget.index);
                        if (success && dCon.mounted) Navigator.of(dCon).pop(name);
                      }

                      void onDeny() {
                        closeKeyboard(dCon);
                        Navigator.of(dCon).pop();
                      }

                      return EzAlertDialog(
                        widget.config,
                        title: Text(
                          "Rename '${widget._name}'?",
                          textAlign: TextAlign.center,
                        ),
                        content: Form(
                          child: TextFormField(
                            controller: renameCon,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            autofillHints: const <String>[AutofillHints.name],
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            validator: validateRename,
                          ),
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
                ),
                rowSpacer(),

                // Edit apps
                EzIconButton(
                  widget.config,
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final TextEditingController renameCon =
                        TextEditingController(text: widget._name);
                    final ValueNotifier<List<String>> appsNotif =
                        ValueNotifier<List<String>>(widget._appList);

                    await ezModal(
                      widget.config,
                      context: context,
                      showDragHandle: false,
                      builder: (BuildContext mCon) => EzCol(children: <Widget>[
                        EzHeader(widget.config),

                        // Name (and rename (II))
                        EzIconLink(
                          widget.config,
                          label: renameCon.text,
                          icon: EzIcon(widget.config, Icons.edit),
                          style: widget.config.titleStyle,
                          textColor: widget.config.colors.onSurface,
                          textAlign: TextAlign.center,
                          hint: 'Activate to rename.',
                          onTap: () => showDialog(
                            context: mCon,
                            builder: (BuildContext dCon) {
                              void onConfirm() {
                                closeKeyboard(dCon);

                                final String newName = renameCon.text.trim();
                                if (validateRename(newName) != null) return;

                                Navigator.of(dCon).pop(newName);
                              }

                              void onDeny() {
                                closeKeyboard(dCon);
                                Navigator.of(dCon).pop();
                              }

                              return EzAlertDialog(
                                widget.config,
                                title: Text(
                                  "Rename '${renameCon.text}'?",
                                  textAlign: TextAlign.center,
                                ),
                                content: Form(
                                  child: TextFormField(
                                    controller: renameCon,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    autofillHints: const <String>[AutofillHints.name],
                                    autovalidateMode: AutovalidateMode.onUnfocus,
                                    validator: validateRename,
                                  ),
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
                        ),
                        widget.config.spacer,

                        // Apps
                        Expanded(
                          child: ValueListenableBuilder<List<String>>(
                            valueListenable: appsNotif,
                            builder: (_, List<String> apps, __) => Stack(children: <Widget>[
                              ReorderableListView(
                                onReorderItem: (int oldIndex, int newIndex) {
                                  if (oldIndex == newIndex) return;

                                  final List<String> update = List<String>.from(apps);
                                  final String element = update.removeAt(oldIndex);
                                  update.insert(newIndex, element);

                                  appsNotif.value = update;
                                },
                                children: apps
                                    .map((String id) {
                                      final AppInfo? app = widget.appInfo.appMap[id];
                                      if (app == null) return null;

                                      return InkWell(
                                        key: ValueKey<String>(id),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: widget.config.spacing / 2),
                                          child: EzRow(
                                            widget.config,
                                            reverseHands: false,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              // Drag handle
                                              EzIcon(
                                                widget.config,
                                                Icons.drag_handle,
                                                color: widget.config.colors.outline,
                                              ),

                                              // App icon && remove button
                                              EzRow(
                                                widget.config,
                                                reverseHands: false,
                                                children: <Widget>[
                                                  Image.memory(
                                                    app.icon!,
                                                    semanticLabel: app.name,
                                                    width: appIconSize(widget.config),
                                                    height: appIconSize(widget.config),
                                                  ),
                                                  widget.config.rowSpacer,
                                                  EzIconButton(
                                                    widget.config,
                                                    icon: const Icon(Icons.remove),
                                                    onPressed: () => appsNotif.value =
                                                        List<String>.from(apps)..remove(id),
                                                  ),
                                                ],
                                              ),

                                              // Drag handle
                                              EzIcon(
                                                widget.config,
                                                Icons.drag_handle,
                                                color: widget.config.colors.outline,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                    .whereType<Widget>()
                                    .toList(),
                              ),
                              Positioned(
                                bottom: widget.config.spargin,
                                left: widget.config.onLeft ? widget.config.spargin : null,
                                right: widget.config.onLeft ? null : widget.config.spargin,
                                child: EzCol(
                                  children: <Widget>[
                                    /// Add apps
                                    FloatingActionButton(
                                      heroTag: 'add_to_folder_FAB',
                                      onPressed: () => mCon.goNamed(
                                        appListPath,
                                        extra: ListConfig(
                                          localContent: appsNotif,
                                          listContent: <ListContent>{
                                            ListContent.hidden,
                                            ListContent.banished,
                                          },
                                          include: false,
                                          onSelected: (AppInfo app) async => appsNotif.value =
                                              List<String>.from(appsNotif.value)..add(app.id),
                                          title: EzText(
                                            widget.config,
                                            text: "Add to '${renameCon.text}'",
                                            style: widget.config.labelStyle,
                                          ),
                                        ),
                                      ),
                                      child: EzIcon(widget.config, Icons.add),
                                    ),
                                    widget.config.spacer,

                                    /// Done
                                    FloatingActionButton(
                                      heroTag: 'done_folder_edits_FAB',
                                      onPressed: () => Navigator.of(mCon).pop(),
                                      child: EzIcon(widget.config, Icons.done),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ]),
                    );

                    await ezNoTouch(() async => await widget.appInfo.updateFolder(
                          widget.index,
                          renameCon.text,
                          appsNotif.value,
                        ));
                  },
                ),
                rowSpacer(),

                // Delete folder
                EzIconButton(
                  widget.config,
                  icon: const Icon(Icons.delete),
                  onPressed: () => widget.appInfo.deleteFolder(widget.index),
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
  final EzCP config;
  final String name;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const FolderButton(
    this.config, {
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
              child: Icon(Icons.folder_open, size: appIconSize(config)),
            )),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: Icon(Icons.folder_open, size: appIconSize(config)),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            config,
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            config,
            label: buildLabel(name, labelType),
            icon: Icon(Icons.folder_open, size: appIconSize(config)),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(name, labelType),
            icon: Icon(Icons.folder_open, size: appIconSize(config)),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}
