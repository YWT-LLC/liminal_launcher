/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_ui/open_ui.dart';

//* Core Widget *//

class FolderTile extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _name;
  late final IconData _icon;
  late final double? _iconSize;
  late final ButtonType? _buttonType;
  late final LabelType? _labelType;
  late final List<String> _appList;

  FolderTile(
    this.config, {
    required this.appInfo,
    required this.pos,
    required this.state,
    this.rippleProgress,
  }) : super(key: ValueKey<String>('${pos.lane}-${pos.index}-${state.index}')) {
    final List<String> items =
        appInfo.homeItem(config, lane: pos.lane, index: pos.index).split(folderSplit);

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
    _iconSize = (data[1] == esSystem) ? null : double.tryParse(data[1]);

    _buttonType = BTConfig.lookup(data[2]);
    _labelType = LTConfig.lookup(data[3]);

    _appList = items.length > 2 ? items.sublist(2) : <String>[];
  }

  @override
  State<FolderTile> createState() => _AppFolderState();
}

class _AppFolderState extends State<FolderTile> {
  // Define the build data //

  late TileState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

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
      setState(
        () => state = switch (state) {
          TileState.standard => TileState.groupEdit,
          _ => TileState.standard,
        },
      );

      final Duration animDur = ezDuration(widget.config.animDur);
      rippleThrottle = Timer(
        (animDur + const Duration(milliseconds: 50)) - (animDur * widget.rippleProgress!.value),
        () => rippleThrottle = null,
      );
    }
  }

  Future<void> showApps() => ezModal(
        widget.config,
        context: context,
        builder: (BuildContext mCon) => ezModalScroll(
          widget.config,
          children: <Widget>[
            EzWrap(
              children: widget._appList
                  .map(
                    (String id) => widget.appInfo.appMap.containsKey(id)
                        ? Padding(
                            padding: EzInsets.wrap(widget.config.spacing),
                            child: AppTile(
                              widget.config,
                              appInfo: widget.appInfo,
                              state: state,
                              app: widget.appInfo.appMap[id]!,
                              location: AppLocation.folder,
                              onSelected: (AppInfo app) async {
                                Navigator.of(mCon).pop();
                                await launchApp(app);
                              },
                              hAlign: widget.pos.hAlign,
                              vAlign: widget.pos.vAlign,
                            ),
                          )
                        : const SizedBox.shrink(),
                  )
                  .where((Widget entry) => entry.runtimeType != SizedBox)
                  .toList(),
            ),
            widget.config.spacer,
          ],
        ),
      );

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

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: state == TileState.standard
          ? MenuAnchor(
              builder: (_, MenuController controller, __) => wideTiles(widget.config)
                  ? InkWell(
                      onTap: () => showApps(),
                      onLongPress: () async => await canToggleMenu(widget.config, controller),
                      child: Container(
                        width: double.infinity,
                        alignment: widget.pos.subAlign,
                        child: FolderButton(
                          widget.config,
                          name: widget._name,
                          icon: widget._icon,
                          iconSize: widget._iconSize ?? widget.config.iconSize,
                          buttonType: widget._buttonType ?? folderBT(widget.config),
                          labelType: widget._labelType ?? folderLabels(widget.config),
                          onPressed: () => showApps(),
                          onLongPress: () async => await canToggleMenu(widget.config, controller),
                        ),
                      ),
                    )
                  : FolderButton(
                      widget.config,
                      name: widget._name,
                      icon: widget._icon,
                      iconSize: widget._iconSize ?? widget.config.iconSize,
                      buttonType: widget._buttonType ?? folderBT(widget.config),
                      labelType: widget._labelType ?? folderLabels(widget.config),
                      onPressed: () => showApps(),
                      onLongPress: () async => await canToggleMenu(widget.config, controller),
                    ),
              menuChildren: _menuChildren(
                widget.config,
                appInfo: widget.appInfo,
                context: context,
                state: state,
                numLanes: numLanes,
                pos: widget.pos,
                initConfig: FolderConfig(
                  name: widget._name,
                  icon: widget._icon,
                  iconSize: widget._iconSize,
                  buttonType: widget._buttonType,
                  labelType: widget._labelType,
                  appList: widget._appList,
                ),
              ),
            )
          : EditContainer(
              widget.config,
              subAlign: widget.pos.subAlign,
              menuControl: menuControl,
              menuChildren: _menuChildren(
                widget.config,
                appInfo: widget.appInfo,
                context: context,
                state: state,
                numLanes: numLanes,
                pos: widget.pos,
                initConfig: FolderConfig(
                  name: widget._name,
                  icon: widget._icon,
                  iconSize: widget._iconSize ?? widget.config.iconSize,
                  buttonType: widget._buttonType,
                  labelType: widget._labelType,
                  appList: widget._appList,
                ),
              ),
              child: EzIconButton(
                widget.config,
                icon: Icon(widget._icon),
                onPressed: () => toggleMenu(menuControl),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required TileState state,
  required int numLanes,
  required LimPos pos,
  required FolderConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditFolder(
        config,
        appInfo,
        pContext: context,
        initConfig: initConfig,
        lane: pos.lane,
        index: pos.index,
      ),

      // Dupe
      EzMenuButton(
        config,
        label: 'Duplicate',
        icon: EzIcon(config, Icons.copy),
        onPressed: () => appInfo.dupeItem(
          config,
          editNew: () async {
            if (!ezRootIsMounted) return;
            await editFolder(
              config,
              appInfo: appInfo,
              pContext: context,
              initConfig: initConfig,
              lane: pos.lane,
              index: pos.index,
            );
          },
          lane: pos.lane,
          index: pos.index,
        ),
      ),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
        moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
      ],

      // Remove
      removeItem(config, appInfo, lane: pos.lane, index: pos.index),
    ];

//* Add Widget *//

class FolderButton extends StatelessWidget {
  final EzCP config;
  final String name;
  final IconData icon;
  final double iconSize;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const FolderButton(
    this.config, {
    super.key,
    required this.name,
    required this.icon,
    required this.iconSize,
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
              child: Icon(icon, size: iconSize),
            ),
          ),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: Icon(icon, size: iconSize),
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
            icon: Icon(icon, size: iconSize),
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
            icon: Icon(icon, size: iconSize),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}

String defaultFolderEntry() => _folderEntry(Icons.folder_outlined, null, null, null);

String _folderEntry(
        IconData icon, double? iconSize, ButtonType? buttonType, LabelType? labelType) =>
    <String>[
      icon.codePoint.toString(),
      (iconSize == null ? esSystem : iconSize.toString()),
      (buttonType == null ? esSystem : buttonType.value),
      (labelType == null ? esSystem : labelType.value),
    ].join(configSplit);

//* Edit Widget *//

class FolderConfig {
  final String name;
  final IconData icon;
  final double? iconSize;
  final ButtonType? buttonType;
  final LabelType? labelType;
  final List<String> appList;

  FolderConfig({
    required this.name,
    required this.icon,
    required this.iconSize,
    required this.buttonType,
    required this.labelType,
    required this.appList,
  });
}

Future<void> editFolder(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required FolderConfig initConfig,
  required int lane,
  required int index,
}) async {
  final ButtonStyle textButtonStyle = TextButton.styleFrom(
    backgroundColor: config.colors.surfaceContainer,
    padding: EdgeInsets.zero,
  );

  bool showUI = false;
  int delta = 0;

  final TextEditingController renameCon = TextEditingController(text: initConfig.name);
  IconData icon = initConfig.icon;

  double? iconSize = initConfig.iconSize;
  LabelType? labelType = initConfig.labelType;
  bool showIcon = iconBTs.contains(initConfig.buttonType ?? folderBT(config));
  bool elevated = elevatedBTs.contains(initConfig.buttonType ?? folderBT(config));

  bool shapeEdits =
      initConfig.iconSize != null || initConfig.labelType != null || initConfig.buttonType != null;

  final ValueNotifier<List<String>> appsNotif = ValueNotifier<List<String>>(initConfig.appList);

  final bool? update = await ezModal(
    config,
    context: pContext,
    enableDrag: false,
    isDismissible: false,
    showDragHandle: false,
    builder: (_) => StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) {
        // Define custom functions //

        void nav(bool choice) {
          delta = choice ? -1 : 1;
          setModal(() => showUI = choice);
        }

        // Define the builds //

        Widget appearanceSettings() => EzScrollView(
              config,
              children: <Widget>[
                // Preview
                FolderButton(
                  config,
                  name: validateName(renameCon.text) == null ? renameCon.text : initConfig.name,
                  icon: icon,
                  iconSize: iconSize ?? config.iconSize,
                  buttonType: BTConfig.build(
                    labelType ?? folderLabels(config),
                    icons: showIcon,
                    elevated: elevated,
                  ),
                  labelType: labelType ?? folderLabels(config),
                  onPressed: doNothing,
                  onLongPress: doNothing,
                ),
                config.divider,

                EzScrollView(
                  config,
                  reverseHands: true,
                  startCentered: true,
                  thumbVisibility: false,
                  scrollDirection: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Name
                    EzTextField(
                      controller: renameCon,
                      constraints: BoxConstraints.tightFor(
                        height: appIconSize(config),
                        width: widthOf(mCon) / 3,
                      ),
                      errorConstraints: BoxConstraints.tightFor(width: widthOf(mCon) / 3),
                      hintText: 'Folder',
                      autofillHints: const <String>[AutofillHints.name],
                      validator: validateName,
                    ),
                    config.rowSpacer,

                    // IconData && size
                    EzIconButton(
                      config,
                      enabled: showIcon && (iconSize == null || iconSize! > minIconSize),
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        iconSize = (iconSize == null) ? (config.iconSize - 1) : (iconSize! - 1);
                        setModal(() => iconSize = max(iconSize!, minIconSize));
                      },
                    ),
                    config.rowMargin,
                    EzIconButton(
                      config,
                      enabled: showIcon,
                      icon: Icon(icon, size: iconSize ?? config.iconSize),
                      onPressed: () async {
                        final IconData? choice = await chooseIcon(config, pContext);
                        if (choice != null) setModal(() => icon = choice);
                      },
                      onLongPress: () => setModal(() => iconSize = null),
                    ),
                    config.rowMargin,
                    EzIconButton(
                      config,
                      enabled: showIcon && (iconSize == null || iconSize! < maxIconSize),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        iconSize = (iconSize == null) ? (config.iconSize + 1) : (iconSize! + 1);
                        setModal(() => iconSize = min(iconSize!, maxIconSize));
                      },
                    ),
                  ],
                ),
                config.separator,

                // Label type
                EzScrollView(
                  config,
                  reverseHands: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Text('Label type', style: config.bodyStyle),
                    config.rowMargin,
                    EzDropdownMenu<LabelType?>(
                      config,
                      widthEntry: 'Full name',
                      dropdownMenuEntries: <DropdownMenuEntry<LabelType?>>[
                        const DropdownMenuEntry<LabelType?>(value: null, label: 'Default'),
                        ...LabelType.values.map((LabelType lt) => DropdownMenuEntry<LabelType?>(
                            value: lt, label: ezCamelToTitle(lt.value))),
                      ],
                      enableSearch: false,
                      initialSelection: labelType,
                      onSelected: (LabelType? choice) {
                        if (choice == null) return;
                        shapeEdits = true;

                        if (choice == LabelType.none) showIcon = true;
                        setModal(() => labelType = choice);
                      },
                    ),
                  ],
                ),
                config.spacer,

                // Show icon
                EzSwitchPair(
                  config,
                  key: ValueKey<String>('icon-$showIcon'),
                  text: 'Show icon',
                  value: showIcon,
                  onChanged: (bool? choice) {
                    if (choice == null) return;
                    shapeEdits = true;

                    if (choice == false && labelType == LabelType.none) {
                      labelType = LabelType.full;
                    }
                    setModal(() => showIcon = choice);
                  },
                ),
                config.spacer,

                // Elevated
                EzSwitchPair(
                  config,
                  key: ValueKey<String>('elevated-$elevated'),
                  text: 'Elevated button',
                  value: elevated,
                  onChanged: (bool? choice) {
                    if (choice == null) return;
                    shapeEdits = true;

                    setModal(() => elevated = choice);
                  },
                ),
                config.divider,

                EzRow(
                  config,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Reset
                    EzTextIconButton(
                      config,
                      label: 'Reset',
                      style: textButtonStyle,
                      icon: EzIcon(config, Icons.refresh),
                      onPressed: () => Navigator.of(mCon).pop(false),
                    ),
                    config.rowSpacer,

                    // GoTo settings
                    EzTextIconButton(
                      config,
                      label: 'Edit defaults',
                      style: textButtonStyle,
                      icon: EzIcon(config, Icons.launch),
                      onPressed: () {
                        Navigator.of(mCon).pop();
                        pContext.goNamed(settingsPath, extra: (2, false));
                      },
                    ),
                  ],
                ),
                config.spacer,

                EzRow(
                  config,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Cancel
                    EzTextIconButton(
                      config,
                      label: 'Cancel',
                      style: textButtonStyle,
                      icon: EzIcon(config, Icons.cancel),
                      onPressed: () => Navigator.of(mCon).pop(),
                    ),
                    config.rowSpacer,

                    // Save
                    EzTextIconButton(
                      config,
                      label: 'Save',
                      style: textButtonStyle,
                      icon: EzIcon(config, Icons.done),
                      onPressed: () => Navigator.of(mCon).pop(true),
                    ),
                  ],
                ),
              ],
            );

        Widget appSettings() => ValueListenableBuilder<List<String>>(
              valueListenable: appsNotif,
              builder: (_, List<String> apps, __) => appsNotif.value.isEmpty
                  ? InkWell(
                      child: Container(
                        alignment: AlignmentGeometry.center,
                        constraints: BoxConstraints.tight(Size.infinite),
                        child: EzTextIconButton(
                          config,
                          icon: EzIcon(config, Icons.add),
                          label: 'Apps',
                          style:
                              TextButton.styleFrom(backgroundColor: config.colors.surfaceContainer),
                          onPressed: () => mCon.goNamed(
                            appListPath,
                            extra: ListConfig(
                              localContent: appsNotif,
                              listContent: <ListContent>{ListContent.hidden, ListContent.banished},
                              include: false,
                              onSelected: (AppInfo app) async =>
                                  appsNotif.value = List<String>.from(appsNotif.value)..add(app.id),
                              title: EzTextButton(
                                config,
                                onPressed: doNothing,
                                text:
                                    "Add to '${validateName(renameCon.text) == null ? renameCon.text : initConfig.name}'",
                                textStyle: config.labelStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Stack(
                      children: <Widget>[
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
                                final AppInfo? app = appInfo.appMap[id];
                                if (app == null) return null;

                                return InkWell(
                                  key: ValueKey<String>(id),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: config.spacing / 2),
                                    child: EzRow(
                                      config,
                                      reverseHands: false,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        // Drag handle
                                        EzIcon(
                                          config,
                                          Icons.drag_handle,
                                          color: config.colors.outline,
                                        ),

                                        // App icon && remove button
                                        EzRow(
                                          config,
                                          reverseHands: false,
                                          children: <Widget>[
                                            Image.memory(
                                              app.icon!,
                                              semanticLabel: app.label,
                                              width: appIconSize(config),
                                              height: appIconSize(config),
                                            ),
                                            config.rowSpacer,
                                            EzIconButton(
                                              config,
                                              icon: const Icon(Icons.remove),
                                              onPressed: () => appsNotif.value =
                                                  List<String>.from(apps)..remove(id),
                                            ),
                                          ],
                                        ),

                                        // Drag handle
                                        EzIcon(
                                          config,
                                          Icons.drag_handle,
                                          color: config.colors.outline,
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
                          left: config.onLeft ? config.spacing : null,
                          right: config.onLeft ? null : config.spacing,
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
                                    title: EzTextButton(
                                      config,
                                      onPressed: doNothing,
                                      text:
                                          "Add to '${validateName(renameCon.text) == null ? renameCon.text : initConfig.name}'",
                                      textStyle: config.labelStyle,
                                    ),
                                  ),
                                ),
                                child: EzIcon(config, Icons.add),
                              ),
                              config.spacer,

                              /// Done
                              FloatingActionButton(
                                heroTag: 'done_folder_edits_FAB',
                                onPressed: () => Navigator.of(mCon).pop(),
                                child: EzIcon(config, Icons.done),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );

        // Make it so //

        return EzCol(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            EzHeader(config),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Appearance', textAlign: TextAlign.center),
                ),
                ButtonSegment<bool>(value: false, label: Text('Apps', textAlign: TextAlign.center)),
              ],
              selected: <bool>{showUI},
              showSelectedIcon: false,
              onSelectionChanged: (Set<bool> selected) => nav(selected.first),
            ),
            config.spacer,
            Expanded(
              child: EzSwipeDetector(
                rtl: () => showUI ? nav(false) : doNothing(),
                ltr: () => showUI ? doNothing() : nav(true),
                child: EzFauxCarousel(
                  config,
                  position: showUI ? 0 : 1,
                  delta: delta,
                  child: showUI ? appearanceSettings() : appSettings(),
                ),
              ),
            ),
            config.separator,
          ],
        );
      },
    ),
  );

  switch (update) {
    case true:
      await ezNoTouch(
        () => appInfo.updateFolder(
          config,
          lane: lane,
          index: index,
          name: validateName(renameCon.text) == null ? renameCon.text : initConfig.name,
          extra: shapeEdits
              ? _folderEntry(
                  icon,
                  iconSize,
                  BTConfig.build(labelType ?? folderLabels(config),
                      icons: showIcon, elevated: elevated),
                  labelType,
                )
              : _folderEntry(
                  icon,
                  null,
                  null,
                  null,
                ),
          ids: appsNotif.value,
        ),
      );
      return;

    case false:
      await ezNoTouch(
        () => appInfo.updateFolder(
          config,
          lane: lane,
          index: index,
          name: initConfig.name,
          extra: _folderEntry(Icons.folder_outlined, null, null, null),
          ids: appsNotif.value,
        ),
      );
      return;

    default:
      return;
  }
}

class _EditFolder extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final FolderConfig initConfig;
  final int lane;
  final int index;

  const _EditFolder(
    this.config,
    this.appInfo, {
    required this.pContext,
    required this.initConfig,
    required this.lane,
    required this.index,
  });

  @override
  Widget build(_) => EzMenuButton(
        config,
        onPressed: () => editFolder(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
        label: 'Edit',
        icon: EzIcon(config, Icons.edit),
      );
}
