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
  final int lane;
  final int index;
  final AppState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _name;
  late final IconData _icon;
  late final ButtonType? _buttonType;
  late final LabelType? _labelType;
  late final List<String> _appList;

  FolderTile(
    this.config, {
    required this.appInfo,
    required this.lane,
    required this.index,
    required this.state,
    this.rippleProgress,
  }) : super(key: ValueKey<String>('$lane-$index-${state.index}')) {
    final List<String> items =
        appInfo.homeItem(config, lane: lane, index: index).split(folderSplit);

    _name = items[0];

    final List<String> data = items[1].split(configSplit);

    final String storedIcon = data[0];
    _icon = (storedIcon == esSystem)
        ? Icons.folder_outlined
        : IconData(
            // ignore: non_const_argument_for_const_parameter
            int.tryParse(storedIcon) ?? Icons.folder_outlined.codePoint,
            fontFamily: 'MaterialIcons',
          );

    _buttonType = BTConfig.lookup(data[1]);
    _labelType = LTConfig.lookup(data[2]);

    _appList = items.length > 2 ? items.sublist(2) : <String>[];
  }

  @override
  State<FolderTile> createState() => _AppFolderState();
}

class _AppFolderState extends State<FolderTile> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  bool open = false;

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
            AppState.standard => AppState.groupEdit,
            _ => AppState.standard,
          });

      final Duration animDur = ezDuration(widget.config.animDur, mod: rippleMod);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  List<Widget> showApps(void Function() toggleMenu) {
    final List<Widget> toReturn = <Widget>[];

    for (final String id in widget._appList) {
      final AppInfo? app = widget.appInfo.appMap[id];
      if (app == null) continue;

      toReturn.addAll(<Widget>[
        AppTile(
          widget.config,
          appInfo: widget.appInfo,
          app: app,
          location: AppLocation.folder,
          state: state,
          onSelected: (AppInfo app) async {
            setState(() => open = false);
            await launchApp(app);
          },
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => open = false),
          onLongPress: toggleMenu,
          child: SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
        ),
      ]);
    }

    return toReturn;
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
    final int numLanes = widget.appInfo.numLanes(widget.config);
    final AlignmentGeometry subAlign =
        LAConfig.merge(h: hAlign(widget.config), v: ListAlignment.center);

    late final EzMenuButton remove =
        removeItem(widget.config, widget.appInfo, lane: widget.lane, index: widget.index);

    late final EzMenuButton edit = EzMenuButton(
      widget.config,
      onPressed: () async {
        bool showUI = false;
        int delta = 0;

        final TextEditingController renameCon = TextEditingController(text: widget._name);
        IconData icon = widget._icon;

        LabelType? labelType = widget._labelType;
        bool showIcon = iconBTs.contains(widget._buttonType ?? folderBT(widget.config));
        bool elevated = elevatedBTs.contains(widget._buttonType ?? folderBT(widget.config));
        // TODO: re-add colors when the over-overhaul is done
        // TODO: get app tiles to parity

        final ValueNotifier<List<String>> appsNotif = ValueNotifier<List<String>>(widget._appList);

        await ezModal(
          widget.config,
          context: context,
          enableDrag: false,
          isDismissible: false,
          showDragHandle: false,
          builder: (_) => StatefulBuilder(builder: (BuildContext mCon, StateSetter setModal) {
            void nav(bool choice) {
              delta = choice ? -1 : 1;
              setModal(() => showUI = choice);
            }

            void resetPreview() {
              labelType = null;

              showIcon = iconBTs.contains(folderBT(widget.config));
              elevated = elevatedBTs.contains(folderBT(widget.config));

              setModal(() {});
            }

            Widget appearanceSettings() => EzScrollView(widget.config, children: <Widget>[
                  EzRow(widget.config, children: <Widget>[
                    // (Re)name
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                        height: appIconSize(widget.config),
                        width: widthOf(mCon) / 3,
                      ),
                      child: TextFormField(
                        controller: renameCon,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        autofillHints: const <String>[AutofillHints.name],
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: validateName,
                      ),
                    ),
                    widget.config.rowSpacer,

                    // (Re)icon
                    EzIconButton(
                      widget.config,
                      icon: Icon(icon),
                      onPressed: () async {
                        final IconData? choice = await chooseIcon(widget.config, context);
                        if (choice != null) setModal(() => icon = choice);
                      },
                    ),
                  ]),
                  widget.config.separator,

                  // Label type
                  EzRow(
                    widget.config,
                    children: <Widget>[
                      EzText(widget.config, text: 'Label type'),
                      widget.config.rowSpacer,
                      EzDropdownMenu<LabelType?>(
                        widget.config,
                        widthEntry: 'Full name',
                        dropdownMenuEntries: <DropdownMenuEntry<LabelType?>>[
                          const DropdownMenuEntry<LabelType?>(
                            value: null,
                            label: 'Default',
                          ),
                          ...LabelType.values.map((LabelType lt) => DropdownMenuEntry<LabelType?>(
                                value: lt,
                                label: ezCamelToTitle(lt.value),
                              )),
                        ],
                        enableSearch: false,
                        initialSelection: labelType,
                        onSelected: (LabelType? choice) {
                          if (choice == null) {
                            resetPreview();
                            return;
                          }

                          if (choice == LabelType.none) showIcon = true;
                          setModal(() => labelType = choice);
                        },
                      ),
                    ],
                  ),
                  widget.config.spacer,

                  // Show icon
                  GestureDetector(
                    onLongPress: resetPreview,
                    child: EzSwitchPair(
                      widget.config,
                      key: ValueKey<String>('icon-$showIcon'),
                      text: 'Show icon',
                      value: showIcon,
                      onChanged: (bool? choice) {
                        if (choice == null) {
                          resetPreview();
                          return;
                        }

                        if (choice == false && labelType == LabelType.none) {
                          labelType = LabelType.full;
                        }
                        setModal(() => showIcon = choice);
                      },
                    ),
                  ),
                  widget.config.spacer,

                  // Elevated
                  GestureDetector(
                    onLongPress: resetPreview,
                    child: EzSwitchPair(
                      widget.config,
                      key: ValueKey<String>('elevated-$elevated'),
                      text: 'Elevated button',
                      value: elevated,
                      onChanged: (bool? choice) {
                        if (choice == null) {
                          resetPreview();
                          return;
                        }

                        setModal(() => elevated = choice);
                      },
                    ),
                  ),
                  widget.config.divider,

                  // Preview
                  FolderButton(
                    widget.config,
                    name: renameCon.text.trim(),
                    icon: icon,
                    buttonType: BTConfig.build(
                      labelType ?? folderLabels(widget.config),
                      icons: showIcon,
                      elevated: elevated,
                    ),
                    labelType: labelType ?? folderLabels(widget.config),
                    onPressed: doNothing,
                    onLongPress: doNothing,
                  ),
                  widget.config.separator,

                  // Default reminder && done
                  Text(
                    'Long pressing the switches also resets to default',
                    textAlign: TextAlign.center,
                    style: widget.config.labelStyle,
                  ),
                  EzTextIconButton(
                    widget.config,
                    label: 'Done',
                    style: TextButton.styleFrom(
                        backgroundColor: widget.config.colors.surfaceContainer),
                    icon: EzIcon(widget.config, Icons.done),
                    onPressed: () => Navigator.of(mCon).pop(),
                  ),
                ]);

            Widget appSettings() => ValueListenableBuilder<List<String>>(
                  valueListenable: appsNotif,
                  builder: (_, List<String> apps, __) => appsNotif.value.isEmpty
                      ? Center(
                          child: EzTextIconButton(
                            widget.config,
                            icon: EzIcon(widget.config, Icons.add),
                            label: 'Apps',
                            style: TextButton.styleFrom(
                                backgroundColor: widget.config.colors.surfaceContainer),
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
                                title: EzTextButton(
                                  widget.config,
                                  onPressed: doNothing,
                                  text: "Add to '${renameCon.text}'",
                                  textStyle: widget.config.labelStyle,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Stack(children: <Widget>[
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: widget.config.spacing / 2),
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
                                                semanticLabel: app.label,
                                                width: appIconSize(widget.config),
                                                height: appIconSize(widget.config),
                                              ),
                                              widget.config.rowSpacer,
                                              EzIconButton(
                                                widget.config,
                                                icon: EzIcon(widget.config, Icons.remove),
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
                            bottom: 0,
                            left: widget.config.onLeft ? widget.config.spacing : null,
                            right: widget.config.onLeft ? null : widget.config.spacing,
                            child: EzCol(children: <Widget>[
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
                                    title: EzTextButton(
                                      widget.config,
                                      onPressed: doNothing,
                                      text: "Add to '${renameCon.text}'",
                                      textStyle: widget.config.labelStyle,
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
                            ]),
                          ),
                        ]),
                );

            return EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
              EzHeader(widget.config),

              // Switcher
              SegmentedButton<bool>(
                segments: <ButtonSegment<bool>>[
                  const ButtonSegment<bool>(
                    value: true,
                    label: Text('Appearance', textAlign: TextAlign.center),
                  ),
                  const ButtonSegment<bool>(
                    value: false,
                    label: Text('Apps', textAlign: TextAlign.center),
                  ),
                ],
                selected: <bool>{showUI},
                showSelectedIcon: false,
                onSelectionChanged: (Set<bool> selected) => nav(selected.first),
              ),
              widget.config.spacer,

              // Settings
              Expanded(
                child: EzFauxCarousel(
                  widget.config,
                  position: showUI ? 0 : 1,
                  delta: delta,
                  child: showUI ? appearanceSettings() : appSettings(),
                ),
              ),
              widget.config.separator,
            ]);
          }),
        );

        await ezNoTouch(() async => await widget.appInfo.updateFolder(
              widget.config,
              lane: widget.lane,
              index: widget.index,
              name: renameCon.text,
              extra: TCC.folderEntry(
                  icon,
                  BTConfig.build(labelType ?? folderLabels(widget.config),
                      icons: showIcon, elevated: elevated),
                  labelType),
              ids: appsNotif.value,
            ));
      },
      label: 'Edit',
      icon: EzIcon(widget.config, Icons.edit),
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: state == AppState.standard
          ? MenuAnchor(
              builder: (_, MenuController controller, __) => open
                  ? TapRegion(
                      onTapOutside: (_) => setState(() => open = false),
                      child: EzScrollBlocker(
                        EzScrollView(
                          widget.config,
                          reverseHands: true,
                          thumbVisibility: false,
                          mainAxisAlignment: hAlign(widget.config).mainAxis,
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            ...showApps(() => canToggleMenu(widget.config, controller)),

                            // Close folder
                            EzIconButton(
                              widget.config,
                              icon: EzIcon(widget.config, Icons.close),
                              onPressed: () => setState(() => open = false),
                            ),
                          ],
                        ),
                      ),
                    )
                  : wideTiles(widget.config)
                      ? InkWell(
                          onTap: () => setState(() => open = true),
                          onLongPress: () => canToggleMenu(widget.config, controller),
                          child: Container(
                            width: double.infinity,
                            alignment: subAlign,
                            child: FolderButton(
                              widget.config,
                              name: widget._name,
                              icon: widget._icon,
                              buttonType: widget._buttonType ?? folderBT(widget.config),
                              labelType: widget._labelType ?? folderLabels(widget.config),
                              onPressed: () => setState(() => open = true),
                              onLongPress: () => canToggleMenu(widget.config, controller),
                            ),
                          ),
                        )
                      : FolderButton(
                          widget.config,
                          name: widget._name,
                          icon: widget._icon,
                          buttonType: widget._buttonType ?? folderBT(widget.config),
                          labelType: widget._labelType ?? folderLabels(widget.config),
                          onPressed: () => setState(() => open = true),
                          onLongPress: () => canToggleMenu(widget.config, controller),
                        ),
              menuChildren: <Widget>[edit, remove],
            )
          : EditContainer(
              widget.config,
              menuControl: menuControl,
              menuChildren: <Widget>[
                if (numLanes > 1)
                  moveDownLane(widget.config, widget.appInfo,
                      numLanes: numLanes, lane: widget.lane, index: widget.index),
                edit,
                remove,
                if (numLanes > 1)
                  moveUpLane(widget.config, widget.appInfo,
                      numLanes: numLanes, lane: widget.lane, index: widget.index),
              ],
              child: EzIconButton(
                widget.config,
                icon: Icon(widget._icon),
                onPressed: () => canToggleMenu(widget.config, menuControl),
              ),
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
  final EzCP config;
  final String name;
  final IconData icon;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const FolderButton(
    this.config, {
    super.key,
    required this.name,
    required this.icon,
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
              child: Icon(icon),
            )),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: Icon(icon),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
            ),
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
            icon: Icon(icon),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(name, labelType),
            icon: Icon(icon),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}
