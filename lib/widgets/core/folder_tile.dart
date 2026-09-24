/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';

import 'dart:math';
import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//* Core Widget *//

class FolderTile extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;
  final void Function() editReset;
  final LimPos pos;

  late final String name;
  late final List<String> appList;
  final List<String> data;

  late final String _tp;
  late final IconData _icon;
  late final double? _iconSize;
  late final ButtonType? _buttonType;
  late final LabelType? _labelType;
  late final TxtStile? _labelStyle;
  late final Color? _textColor;
  late final Color? _iconColor;
  late final Color? _backgroundColor;
  late final Color? _outlineColor;

  FolderTile(
    this.config, {
    required this.appInfo,
    required this.state,
    required this.rippleProgress,
    required this.editReset,
    required this.pos,
    required this.name,
    required this.appList,
    required this.data,
  }) : super(key: ValueKey<String>('${pos.lane}-${pos.index}-${state.index}')) {
    _tp = data[0]; // Not used here; tracked so local updates don't clobber it

    final String storedIcon = safeData(data, 1);
    _icon = (storedIcon == esSystem)
        ? Icons.folder_outlined
        : IconData(
            // ignore: non_const_argument_for_const_parameter
            int.tryParse(storedIcon) ?? Icons.folder_outlined.codePoint,
            fontFamily: matIcons,
          );
    _iconSize = (safeData(data, 2) == esSystem) ? null : double.tryParse(safeData(data, 2));

    _buttonType = BTConfig.lookup(safeData(data, 3));
    _labelType = LTConfig.lookup(safeData(data, 4));
    _labelStyle = TSConfig.lookup(safeData(data, 5));

    late final int? tCV = int.tryParse(safeData(data, 6));
    _textColor = tCV == null ? null : Color(tCV);

    late final int? iCV = int.tryParse(safeData(data, 7));
    _iconColor = iCV == null ? null : Color(iCV);

    late final int? bCV = int.tryParse(safeData(data, 8));
    _backgroundColor = bCV == null ? null : Color(bCV);

    late final int? oCV = int.tryParse(safeData(data, 9));
    _outlineColor = oCV == null ? null : Color(oCV);
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

  Future<void> showApps() async {
    editingMarked
        ? (marked.value == widget.pos ? doNothing() : setState(() => marked.value = widget.pos))
        : await ezModal(
            widget.config,
            context: context,
            builder: (BuildContext mCon) => ezModalScroll(
              widget.config,
              children: <Widget>[
                EzWrap(
                  children: widget.appList
                      .map((String id) => widget.appInfo.appMap.containsKey(id)
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
                          : const SizedBox.shrink())
                      .where((Widget entry) => entry.runtimeType != SizedBox)
                      .toList(),
                ),
                widget.config.spacer,
              ],
            ),
          );
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

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: state == TileState.standard
          ? MenuAnchor(
              controller: menuControl,
              builder: (_, __, ___) => WideTile(
                widget.config,
                onTap: showApps,
                onLongPress: () async => await canToggleMenu(widget.config, menuControl),
                alignment: widget.pos.subAlign,
                child: FolderButton(
                  widget.config,
                  name: widget.name,
                  icon: widget._icon,
                  iconSize: widget._iconSize ?? widget.config.iconSize,
                  buttonType: widget._buttonType ?? folderBT(widget.config),
                  labelType: widget._labelType ?? folderLabels(widget.config),
                  labelStyle: widget._labelStyle ?? TxtStile.body,
                  textColor: widget._textColor ?? widget.config.colors.onSurface,
                  iconColor: widget._iconColor ?? widget.config.colors.primary,
                  backgroundColor: widget._backgroundColor ?? widget.config.colors.surface,
                  outlineColor: widget._outlineColor ?? widget.config.colors.primaryContainer,
                  onPressed: showApps,
                  onLongPress: () async => await canToggleMenu(widget.config, menuControl),
                ),
              ),
              menuChildren: _menuChildren(
                widget.config,
                appInfo: widget.appInfo,
                context: context,
                state: state,
                editReset: widget.editReset,
                numLanes: numLanes,
                pos: widget.pos,
                initConfig: FolderConfig(
                  tp: widget._tp,
                  appList: widget.appList,
                  name: widget.name,
                  icon: widget._icon,
                  iconSize: widget._iconSize ?? widget.config.iconSize,
                  buttonType: widget._buttonType,
                  labelType: widget._labelType,
                  labelStyle: widget._labelStyle,
                  textColor: widget._textColor,
                  iconColor: widget._iconColor,
                  backgroundColor: widget._backgroundColor,
                  outlineColor: widget._outlineColor,
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
                editReset: widget.editReset,
                numLanes: numLanes,
                pos: widget.pos,
                initConfig: FolderConfig(
                  tp: widget._tp,
                  appList: widget.appList,
                  name: widget.name,
                  icon: widget._icon,
                  iconSize: widget._iconSize ?? widget.config.iconSize,
                  buttonType: widget._buttonType,
                  labelType: widget._labelType,
                  labelStyle: widget._labelStyle,
                  textColor: widget._textColor,
                  iconColor: widget._iconColor,
                  backgroundColor: widget._backgroundColor,
                  outlineColor: widget._outlineColor,
                ),
              ),
              child: EzIconButton(
                widget.config,
                icon: Icon(widget._icon),
                tooltip: widget.name,
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
  required void Function() editReset,
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
        label: l10n(config).gDupe,
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

      // Reposition
      reposition(config, appInfo, pos, stateCheck: editReset),

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, pos, numLanes: numLanes),
        moveUpLane(config, appInfo, pos, numLanes: numLanes),
      ],

      // Remove
      removeItem(config, appInfo, pos),
    ];

//* Add Widget *//

class FolderButton extends StatelessWidget {
  final EzCP config;
  final String name;
  final IconData icon;
  final double iconSize;
  final ButtonType buttonType;
  final LabelType labelType;
  final TxtStile labelStyle;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color outlineColor;
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
    required this.labelStyle,
    required this.textColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.outlineColor,
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
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
          ),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: Icon(icon, size: iconSize, color: iconColor),
            style: IconButton.styleFrom(
              backgroundColor: backgroundColor,
              side: config.borderSide(color: outlineColor),
            ),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
              backgroundColor: backgroundColor,
              side: config.borderSide(color: outlineColor),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            config,
            text: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(config.padding),
              backgroundColor: backgroundColor,
              side: config.borderSide(color: outlineColor),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            config,
            label: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            icon: Icon(icon, size: iconSize, color: iconColor),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
              backgroundColor: backgroundColor,
              side: config.borderSide(color: outlineColor),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            icon: Icon(icon, size: iconSize, color: iconColor),
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(config.padding),
              backgroundColor: backgroundColor,
              side: config.borderSide(color: outlineColor),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}

String defaultFolderEntry() => _folderEntry(
      tp: nullTPS,
      icon: Icons.folder_outlined,
      iconSize: null,
      buttonType: null,
      labelType: null,
      labelStyle: null,
      textColor: null,
      iconColor: null,
      backgroundColor: null,
      outlineColor: null,
    );

String _folderEntry({
  required String tp,
  required IconData icon,
  required double? iconSize,
  required ButtonType? buttonType,
  required LabelType? labelType,
  required TxtStile? labelStyle,
  required Color? textColor,
  required Color? iconColor,
  required Color? backgroundColor,
  required Color? outlineColor,
}) =>
    <String>[
      tp,
      icon.codePoint.toString(),
      (iconSize == null ? esSystem : iconSize.toString()),
      (buttonType == null ? esSystem : buttonType.value),
      (labelType == null ? esSystem : labelType.value),
      (labelStyle == null ? esSystem : labelStyle.value),
      (textColor == null ? esSystem : textColor.toARGB32().toString()),
      (iconColor == null ? esSystem : iconColor.toARGB32().toString()),
      (backgroundColor == null ? esSystem : backgroundColor.toARGB32().toString()),
      (outlineColor == null ? esSystem : outlineColor.toARGB32().toString()),
    ].join(configSplit);

//* Edit Widget *//

class FolderConfig {
  final String tp;
  final List<String> appList;
  final String name;
  final IconData icon;
  final double? iconSize;
  final ButtonType? buttonType;
  final LabelType? labelType;
  final TxtStile? labelStyle;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? outlineColor;

  FolderConfig({
    required this.tp,
    required this.appList,
    required this.name,
    required this.icon,
    required this.iconSize,
    required this.buttonType,
    required this.labelType,
    required this.labelStyle,
    required this.textColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.outlineColor,
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
  final EdgeInsets wrapPadding = EzInsets.wrap(config.spacing);
  final double iconRadius = config.iconSize / 2;

  bool showUI = false;
  int delta = 0;

  final ValueNotifier<List<String>> appsNotif = ValueNotifier<List<String>>(initConfig.appList);

  final TextEditingController renameCon = TextEditingController(text: initConfig.name);

  IconData icon = initConfig.icon;
  double iconSize = initConfig.iconSize ?? config.iconSize;

  LabelType labelType = initConfig.labelType ?? folderLabels(config);
  TxtStile labelStyle = initConfig.labelStyle ?? TxtStile.body;
  bool showIcon = iconBTs.contains(initConfig.buttonType ?? folderBT(config));
  bool elevated = elevatedBTs.contains(initConfig.buttonType ?? folderBT(config));

  Color textColor = initConfig.textColor ?? config.colors.onSurface;
  Color iconColor = initConfig.iconColor ?? config.colors.primary;
  Color backgroundColor = initConfig.backgroundColor ?? config.colors.surface;
  Color outlineColor = initConfig.outlineColor ?? config.colors.primaryContainer;

  final bool? update = await ezFullScreenModal(
    config,
    context: pContext,
    child: StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) {
        // Define custom functions //

        void nav(bool choice) {
          delta = choice ? -1 : 1;
          setModal(() => showUI = choice);
        }

        // Define the builds //

        Widget appearanceSettings() => EzCol(children: <Widget>[
              // Preview
              FolderButton(
                config,
                name:
                    validateName(config, renameCon.text) == null ? renameCon.text : initConfig.name,
                icon: icon,
                iconSize: iconSize,
                buttonType: BTConfig.build(
                  labelType,
                  icons: showIcon,
                  elevated: elevated,
                ),
                labelType: labelType,
                labelStyle: labelStyle,
                textColor: textColor,
                iconColor: iconColor,
                backgroundColor: backgroundColor,
                outlineColor: outlineColor,
                onPressed: doNothing,
                onLongPress: doNothing,
              ),
              EzDivider(height: config.spacing * 2),

              // Settings
              Expanded(
                  child: EzScrollView(
                config,
                showScrollHint: true,
                children: <Widget>[
                  // Name && icon
                  EzScrollView(
                    config,
                    reverseHands: true,
                    startCentered: true,
                    thumbVisibility: false,
                    scrollDirection: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Text field
                      EzTextField(
                        controller: renameCon,
                        constraints: BoxConstraints.tightFor(
                          height: appIconSize(config),
                          width: widthOf(mCon) / 3,
                        ),
                        errorConstraints: BoxConstraints.tightFor(width: widthOf(mCon) / 3),
                        hintText: l10n(config).hsFolder,
                        autofillHints: const <String>[AutofillHints.name],
                        validator: (String? check) => validateName(config, check),
                      ),
                      config.rowSpacer,

                      // Plus/minus
                      EzIconButton(
                        config,
                        enabled: showIcon && (iconSize > minIconSize),
                        icon: const Icon(Icons.remove),
                        tooltip: config.ezL10n.gDecrease,
                        onPressed: () {
                          iconSize -= 1;
                          setModal(() => iconSize = max(iconSize, minIconSize));
                        },
                      ),
                      config.rowMargin,
                      EzIconButton(
                        config,
                        enabled: showIcon,
                        icon: Icon(icon, size: iconSize),
                        tooltip: l10n(config).gPreview,
                        onPressed: () async {
                          final IconData? choice = await chooseIcon(config, pContext);
                          if (choice != null) setModal(() => icon = choice);
                        },
                        onLongPress: () => setModal(() => iconSize = config.iconSize),
                      ),
                      config.rowMargin,
                      EzIconButton(
                        config,
                        enabled: showIcon && (iconSize < maxIconSize),
                        icon: const Icon(Icons.add),
                        tooltip: config.ezL10n.gIncrease,
                        onPressed: () {
                          iconSize += 1;
                          setModal(() => iconSize = min(iconSize, maxIconSize));
                        },
                      ),
                    ],
                  ),
                  EzSpacer(config.spacing * 1.5),

                  // Label type
                  EzDropdownMenu<LabelType?>(
                    config,
                    label: l10n(config).dbsLabelType,
                    widthEntry: l10n(config).dbsInitials,
                    dropdownMenuEntries: <DropdownMenuEntry<LabelType?>>[
                      DropdownMenuEntry<LabelType?>(value: null, label: l10n(config).gDefault),
                      ...LabelType.values.map((LabelType lt) =>
                          DropdownMenuEntry<LabelType?>(value: lt, label: lt.name(config))),
                    ],
                    enableSearch: false,
                    initialSelection: labelType,
                    onSelected: (LabelType? choice) {
                      if (choice == null) return;

                      if (choice == LabelType.none) showIcon = true;
                      setModal(() => labelType = choice);
                    },
                  ),
                  config.spacer,

                  // Text style
                  EzDropdownMenu<TxtStile>(
                    config,
                    label: l10n(config).gLabelStyle,
                    labelStyle: labelStyle.style(config),
                    enableSearch: false,
                    initialSelection: labelStyle,
                    widthEntry: TxtStile.display.value,
                    dropdownMenuEntries: TxtStile.values
                        .map((TxtStile ts) =>
                            DropdownMenuEntry<TxtStile>(value: ts, label: ts.name(config)))
                        .toList(),
                    menuStyle: labelStyle.style(config),
                    onSelected: (TxtStile? choice) {
                      if (choice == null) return;
                      setModal(() => labelStyle = choice);
                    },
                  ),
                  config.spacer,

                  // Show icon
                  EzSwitchPair(
                    config,
                    key: ValueKey<String>('icon-$showIcon'),
                    text: l10n(config).dbsShowIcon,
                    value: showIcon,
                    onChanged: (bool? choice) {
                      if (choice == null) return;

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
                    text: l10n(config).dbsElevatedButton,
                    value: elevated,
                    onChanged: (bool? choice) {
                      if (choice == null) return;
                      setModal(() => elevated = choice);
                    },
                  ),
                  config.spacer,

                  // Color wrap
                  EzWrap(children: <Widget>[
                    // Text
                    Padding(
                      padding: wrapPadding,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          Color curr = textColor;

                          await ezColorPicker(
                            config,
                            context: pContext,
                            startColor: curr,
                            onColorChange: (Color choice) => curr = choice,
                            onConfirm: () => setModal(() => textColor = curr),
                            onDeny: doNothing,
                          );
                        },
                        onLongPress: () => setModal(() => textColor = config.colors.onSurface),
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: config.colors.primaryContainer,
                              width: config.borderWidth,
                            ),
                          ),
                          child: textColor == Colors.transparent
                              ? CircleAvatar(
                                  backgroundColor: config.colors.surface,
                                  foregroundColor: config.colors.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : CircleAvatar(
                                  backgroundColor: textColor,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csOnSurface,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Icon
                    Padding(
                      padding: wrapPadding,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          Color curr = iconColor;

                          await ezColorPicker(
                            config,
                            context: pContext,
                            startColor: curr,
                            onColorChange: (Color choice) => curr = choice,
                            onConfirm: () => setModal(() => iconColor = curr),
                            onDeny: doNothing,
                          );
                        },
                        onLongPress: () => setModal(() => iconColor = config.colors.primary),
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: config.colors.primaryContainer,
                              width: config.borderWidth,
                            ),
                          ),
                          child: iconColor == Colors.transparent
                              ? CircleAvatar(
                                  backgroundColor: config.colors.surface,
                                  foregroundColor: config.colors.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : CircleAvatar(
                                  backgroundColor: iconColor,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Background
                    Padding(
                      padding: wrapPadding,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          Color curr = backgroundColor;

                          await ezColorPicker(
                            config,
                            context: pContext,
                            startColor: curr,
                            onColorChange: (Color choice) => curr = choice,
                            onConfirm: () => setModal(() => backgroundColor = curr),
                            onDeny: doNothing,
                          );
                        },
                        onLongPress: () => setModal(() => backgroundColor = config.colors.surface),
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: config.colors.primaryContainer,
                              width: config.borderWidth,
                            ),
                          ),
                          child: backgroundColor == Colors.transparent
                              ? CircleAvatar(
                                  backgroundColor: config.colors.surface,
                                  foregroundColor: config.colors.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : CircleAvatar(
                                  backgroundColor: backgroundColor,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csSurface,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Outline
                    Padding(
                      padding: wrapPadding,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          Color curr = outlineColor;

                          await ezColorPicker(
                            config,
                            context: pContext,
                            startColor: curr,
                            onColorChange: (Color choice) => curr = choice,
                            onConfirm: () => setModal(() => outlineColor = curr),
                            onDeny: doNothing,
                          );
                        },
                        onLongPress: () =>
                            setModal(() => outlineColor = config.colors.primaryContainer),
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: config.colors.primaryContainer,
                              width: config.borderWidth,
                            ),
                          ),
                          child: outlineColor == Colors.transparent
                              ? CircleAvatar(
                                  backgroundColor: config.colors.surface,
                                  foregroundColor: config.colors.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : CircleAvatar(
                                  backgroundColor: outlineColor,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csPrimaryContainer,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ],
              )),
              EzDivider(height: config.spacing * 2),

              EzRow(config, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                // Reset
                EzTextIconButton(
                  config,
                  label: l10n(config).gReset,
                  style: textButtonStyle,
                  icon: EzIcon(config, Icons.refresh),
                  onPressed: () => Navigator.of(mCon).pop(false),
                ),
                config.rowSpacer,

                // GoTo settings
                EzTextIconButton(
                  config,
                  label: l10n(config).gEditDefaults,
                  style: textButtonStyle,
                  icon: EzIcon(config, Icons.launch),
                  onPressed: () {
                    Navigator.of(mCon).pop();
                    pContext.goNamed(settingsPath, extra: (2, false));
                  },
                ),
              ]),
              config.spacer,

              EzRow(config, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                // Cancel
                EzTextIconButton(
                  config,
                  label: config.ezL10n.gCancel,
                  style: textButtonStyle,
                  icon: EzIcon(config, Icons.cancel),
                  onPressed: () => Navigator.of(mCon).pop(),
                ),
                config.rowSpacer,

                // Save
                EzTextIconButton(
                  config,
                  label: l10n(config).mcSave,
                  style: textButtonStyle,
                  icon: EzIcon(config, Icons.done),
                  onPressed: () => Navigator.of(mCon).pop(true),
                ),
              ]),
            ]);

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
                          label: l10n(config).hsApp,
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
                                    "Add to '${validateName(config, renameCon.text) == null ? renameCon.text : initConfig.name}'",
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
                                              tooltip: config.ezL10n.gRemove,
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
                                      text: l10n(config).fldAddTo(
                                          validateName(config, renameCon.text) == null
                                              ? renameCon.text
                                              : initConfig.name),
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
                                onPressed: () => Navigator.of(mCon).pop(true),
                                child: EzIcon(config, Icons.done),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );

        // Make it so //

        return EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
          EzHeader(config),
          SegmentedButton<bool>(
            segments: <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: true,
                label: Text(l10n(config).fldAppearance, textAlign: TextAlign.center),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text(l10n(config).fldApps, textAlign: TextAlign.center),
              ),
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
        ]);
      },
    ),
  );

  switch (update) {
    case true:
      await ezNoTouch(
        config,
        () => appInfo.updateFolder(
          config,
          lane: lane,
          index: index,
          name: validateName(config, renameCon.text) == null ? renameCon.text : initConfig.name,
          extra: _folderEntry(
            tp: initConfig.tp,
            icon: icon,
            iconSize: iconSize,
            buttonType: BTConfig.build(labelType, icons: showIcon, elevated: elevated),
            labelType: labelType,
            labelStyle: labelStyle,
            textColor: textColor,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
            outlineColor: outlineColor,
          ),
          ids: appsNotif.value,
        ),
      );
      return;

    case false:
      await ezNoTouch(
        config,
        () => appInfo.updateFolder(
          config,
          lane: lane,
          index: index,
          name: initConfig.name,
          extra: _folderEntry(
            tp: initConfig.tp,
            icon: Icons.folder_outlined,
            iconSize: null,
            buttonType: null,
            labelType: null,
            labelStyle: null,
            textColor: null,
            iconColor: null,
            backgroundColor: null,
            outlineColor: null,
          ),
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
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
      );
}
