/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';
import 'package:ywt_private/ywt_private.dart' as ywt;

import 'dart:math';
import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
  late final EzSwitchColor? _iconFill;
  late final EzSwitchColor? _backgroundFill;
  late final EzSwitchColor? _outlineFill;

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

    _iconFill = ezCOG(safeData(data, 7));
    _backgroundFill = ezCOG(safeData(data, 8));
    _outlineFill = ezCOG(safeData(data, 9));
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
                          ? ezWrap(
                              widget.config,
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
                  textColor: widget._textColor ?? widget.config.onSurface,
                  iconFill: widget._iconFill ?? widget.config.primaryFill,
                  backgroundFill: widget._backgroundFill ?? widget.config.surfaceFill,
                  outlineFill: widget._outlineFill ?? widget.config.primaryContainerFill,
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
                  iconFill: widget._iconFill,
                  backgroundFill: widget._backgroundFill,
                  outlineFill: widget._outlineFill,
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
                  iconFill: widget._iconFill,
                  backgroundFill: widget._backgroundFill,
                  outlineFill: widget._outlineFill,
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

  final EzSwitchColor backgroundFill;
  final ButtonType buttonType;
  final IconData icon;
  final EzSwitchColor iconFill;
  final double iconSize;
  final TxtStile labelStyle;
  final LabelType labelType;
  final String name;
  final void Function()? onLongPress;
  final void Function()? onPressed;
  final EzSwitchColor outlineFill;
  final Color textColor;

  const FolderButton(
    this.config, {
    super.key,
    required this.backgroundFill,
    required this.buttonType,
    required this.icon,
    required this.iconFill,
    required this.iconSize,
    required this.labelType,
    required this.labelStyle,
    required this.name,
    this.onLongPress,
    this.onPressed,
    required this.outlineFill,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) => switch (buttonType) {
        ButtonType.icon => Tooltip(
            message: name,
            child: GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: EzIcon(config, icon, size: iconSize, fill: iconFill),
            ),
          ),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: EzIcon(config, icon, size: iconSize, fill: iconFill),
            backgroundFill: backgroundFill,
            style: IconButton.styleFrom(
              side: config.borderSide(fill: outlineFill),
            ),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(
                fill: backgroundFill,
                border: config.boxBorder(fill: outlineFill),
              ),
              backgroundColor: backgroundFill.asColor,
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
              side: config.borderSide(fill: outlineFill),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eText => EzElevatedButton(
            config,
            text: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(
                fill: backgroundFill,
                border: config.boxBorder(fill: outlineFill),
              ),
              backgroundColor: backgroundFill.asColor,
              padding: EdgeInsets.all(config.padding),
              side: config.borderSide(fill: outlineFill),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.textIcon => EzTextIconButton(
            config,
            label: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            icon: EzIcon(config, icon, size: iconSize, fill: iconFill),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(
                fill: backgroundFill,
                border: config.boxBorder(fill: outlineFill),
              ),
              backgroundColor: backgroundFill.asColor,
              padding: config.textBackgroundOpacity < oneP
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
              side: config.borderSide(fill: outlineFill),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            icon: EzIcon(config, icon, size: iconSize, fill: iconFill),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(
                fill: backgroundFill,
                border: config.boxBorder(fill: outlineFill),
              ),
              backgroundColor: backgroundFill.asColor,
              padding: EdgeInsets.all(config.padding),
              side: config.borderSide(fill: outlineFill),
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
      iconFill: null,
      backgroundFill: null,
      outlineFill: null,
    );

String _folderEntry({
  required String tp,
  required IconData icon,
  required double? iconSize,
  required ButtonType? buttonType,
  required LabelType? labelType,
  required TxtStile? labelStyle,
  required Color? textColor,
  required EzSwitchColor? iconFill,
  required EzSwitchColor? backgroundFill,
  required EzSwitchColor? outlineFill,
}) =>
    <String>[
      tp,
      icon.codePoint.toString(),
      (iconSize == null ? esSystem : iconSize.toString()),
      (buttonType == null ? esSystem : buttonType.value),
      (labelType == null ? esSystem : labelType.value),
      (labelStyle == null ? esSystem : labelStyle.value),
      (textColor == null ? esSystem : textColor.toARGB32().toString()),
      (iconFill == null ? esSystem : iconFill.toString()),
      (backgroundFill == null ? esSystem : backgroundFill.toString()),
      (outlineFill == null ? esSystem : outlineFill.toString()),
    ].join(configSplit);

//* Edit Widget *//

class FolderConfig {
  final List<String> appList;
  final EzSwitchColor? backgroundFill;
  final ButtonType? buttonType;
  final IconData icon;
  final EzSwitchColor? iconFill;
  final double? iconSize;
  final LabelType? labelType;
  final TxtStile? labelStyle;
  final String name;
  final EzSwitchColor? outlineFill;
  final Color? textColor;
  final String tp;

  FolderConfig({
    required this.appList,
    required this.backgroundFill,
    required this.buttonType,
    required this.icon,
    required this.iconFill,
    required this.iconSize,
    required this.labelStyle,
    required this.labelType,
    required this.name,
    required this.outlineFill,
    required this.textColor,
    required this.tp,
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
    backgroundColor: config.surfaceContainerFill.asColor,
    padding: EdgeInsets.zero,
  );
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

  Color textColor = initConfig.textColor ?? config.onSurface;
  EzSwitchColor iconFill = initConfig.iconFill ?? config.primaryFill;
  EzSwitchColor backgroundFill = initConfig.backgroundFill ?? config.surfaceFill;
  EzSwitchColor outlineFill = initConfig.outlineFill ?? config.primaryContainerFill;

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
                iconFill: iconFill,
                backgroundFill: backgroundFill,
                outlineFill: outlineFill,
                onPressed: doNothing,
                onLongPress: doNothing,
              ),
              EzDivider(config, height: config.spacing * 2),

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
                        enabled: showIcon && (iconSize > ywt.minIconSize),
                        icon: const Icon(Icons.remove),
                        tooltip: config.ezL10n.gDecrease,
                        onPressed: () {
                          iconSize -= 1;
                          setModal(() => iconSize = max(iconSize, ywt.minIconSize));
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
                        enabled: showIcon && (iconSize < ywt.maxIconSize),
                        icon: const Icon(Icons.add),
                        tooltip: config.ezL10n.gIncrease,
                        onPressed: () {
                          iconSize += 1;
                          setModal(() => iconSize = min(iconSize, ywt.maxIconSize));
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
                    dropdownMenuEntries: <EzDropMenuEntry<LabelType?>>[
                      EzDropMenuEntry<LabelType?>(
                        config,
                        value: null,
                        label: l10n(config).gDefault,
                      ),
                      ...LabelType.values.map((LabelType lt) => EzDropMenuEntry<LabelType?>(
                            config,
                            value: lt,
                            label: lt.name(config),
                          )),
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
                        .map((TxtStile ts) => EzDropMenuEntry<TxtStile>(
                              config,
                              value: ts,
                              label: ts.name(config),
                            ))
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
                    ezWrap(
                      config,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          final String? picked = await ezColorPicker(
                            config,
                            context: pContext,
                            picking: textColor.toString(),
                            allowGradient: false,
                          );

                          if (picked != null) {
                            final int? cv = int.tryParse(picked);
                            if (cv != null) setModal(() => textColor = Color(cv));
                          }
                        },
                        onLongPress: () => setModal(() => textColor = config.onSurface),
                        icon: Container(
                          decoration: config.boxDeco(
                            border: config.boxBorder(),
                            shape: BoxShape.circle,
                          ),
                          child: textColor == Colors.transparent
                              ? EzAvatar(
                                  config,
                                  fill: config.surfaceFill,
                                  foregroundColor: config.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : EzAvatar(
                                  config,
                                  fill: EzSwitchColor(color: textColor),
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csOnSurface,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Icon
                    ezWrap(
                      config,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          final String? picked = await ezColorPicker(
                            config,
                            context: pContext,
                            picking: iconFill.toString(),
                          );

                          if (picked != null) setModal(() => iconFill = ezCOG(picked) ?? iconFill);
                        },
                        onLongPress: () => setModal(() => iconFill = config.primaryFill),
                        icon: Container(
                          decoration: config.boxDeco(
                            border: config.boxBorder(),
                            shape: BoxShape.circle,
                          ),
                          child: iconFill.asColor == Colors.transparent
                              ? EzAvatar(
                                  config,
                                  fill: config.surfaceFill,
                                  foregroundColor: config.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : EzAvatar(
                                  config,
                                  fill: iconFill,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Background
                    ezWrap(
                      config,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          final String? picked = await ezColorPicker(
                            config,
                            context: pContext,
                            picking: backgroundFill.toString(),
                          );

                          if (picked != null) {
                            setModal(() => backgroundFill = ezCOG(picked) ?? iconFill);
                          }
                        },
                        onLongPress: () => setModal(() => backgroundFill = config.surfaceFill),
                        icon: Container(
                          decoration: config.boxDeco(
                            border: config.boxBorder(),
                            shape: BoxShape.circle,
                          ),
                          child: backgroundFill.asColor == Colors.transparent
                              ? EzAvatar(
                                  config,
                                  fill: config.surfaceFill,
                                  foregroundColor: config.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : EzAvatar(
                                  config,
                                  fill: backgroundFill,
                                  radius: iconRadius + config.padding,
                                ),
                        ),
                        label: config.ezL10n.csSurface,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Outline
                    ezWrap(
                      config,
                      child: EzElevatedIconButton(
                        config,
                        onPressed: () async {
                          final String? picked = await ezColorPicker(
                            config,
                            context: pContext,
                            picking: outlineFill.toString(),
                          );

                          if (picked != null) {
                            setModal(() => outlineFill = ezCOG(picked) ?? iconFill);
                          }
                        },
                        onLongPress: () =>
                            setModal(() => outlineFill = config.primaryContainerFill),
                        icon: Container(
                          decoration: config.boxDeco(
                            border: config.boxBorder(),
                            shape: BoxShape.circle,
                          ),
                          child: outlineFill.asColor == Colors.transparent
                              ? EzAvatar(
                                  config,
                                  fill: config.surfaceFill,
                                  foregroundColor: config.onSurface,
                                  radius: iconRadius + config.padding,
                                  child: EzIcon(config, Icons.visibility_off),
                                )
                              : EzAvatar(
                                  config,
                                  fill: outlineFill,
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
              EzDivider(config, height: config.spacing * 2),

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
                    pContext.goNamed(settingsScreenName, extra: (2, false));
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
                          style: TextButton.styleFrom(
                              backgroundColor: config.surfaceContainerFill.asColor),
                          onPressed: () => mCon.goNamed(
                            appListScreenName,
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
                                          fill: config.outlineFiller,
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
                                          fill: config.outlineFiller,
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
                                  appListScreenName,
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
            iconFill: iconFill,
            backgroundFill: backgroundFill,
            outlineFill: outlineFill,
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
            iconFill: null,
            backgroundFill: null,
            outlineFill: null,
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
