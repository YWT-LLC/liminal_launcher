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
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';

//* Core Widget *//

class AppTile extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final AppInfo app;
  final Future<void> Function(AppInfo app) onSelected;
  final AppLocation location;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  // For home
  final LimPos? pos;
  final void Function()? editReset;

  // For app list
  final ListAlignment? hAlign;
  final ListAlignment? vAlign;
  final ListSort? verbStart;

  // Local
  late final List<String>? data;
  late final String _tp;
  late final String? _name;
  late final IconData? _icon;
  late final double? _iconSize;
  late final ButtonType? _buttonType;
  late final LabelType? _labelType;
  late final TxtStile? _labelStyle;
  late final Color? _textColor;
  late final Color? _iconColor;
  late final Color? _backgroundColor;
  late final Color? _outlineColor;

  AppTile(
    this.config, {
    required this.appInfo,
    required this.app,
    required this.onSelected,
    required this.location,
    required this.state,
    this.rippleProgress,
    this.pos,
    this.editReset,
    this.hAlign,
    this.vAlign,
    this.verbStart,
    this.data,
  })  : assert(
          ((pos == null) != (hAlign == null)) && (hAlign == null) == (vAlign == null),
          'Provide pos OR (hAlign AND vAlign)',
        ),
        super(key: ValueKey<String>('${app.id}-${state.index}')) {
    if (data != null) {
      _tp = data![0]; // Not used here; tracked so local updates don't clobber it
      _name = data![1];

      final String storedIcon = safeData(data!, 2);
      _icon = (storedIcon == esSystem)
          ? null
          : (int.tryParse(storedIcon) == null)
              ? null
              // ignore: non_const_argument_for_const_parameter
              : IconData(int.tryParse(storedIcon)!, fontFamily: matIcons);
      _iconSize = (data![3] == esSystem) ? null : double.tryParse(safeData(data!, 3));

      _buttonType = BTConfig.lookup(safeData(data!, 4));
      _labelType = LTConfig.lookup(safeData(data!, 5));
      _labelStyle = TSConfig.lookup(safeData(data!, 6));

      late final int? tCV = int.tryParse(safeData(data!, 7));
      _textColor = tCV == null ? null : Color(tCV);

      late final int? iCV = int.tryParse(safeData(data!, 8));
      _iconColor = iCV == null ? null : Color(iCV);

      late final int? bCV = int.tryParse(safeData(data!, 9));
      _backgroundColor = bCV == null ? null : Color(bCV);

      late final int? oCV = int.tryParse(safeData(data!, 10));
      _outlineColor = oCV == null ? null : Color(oCV);
    } else {
      _name = null;
      _icon = null;
      _iconSize = null;
      _buttonType = null;
      _labelType = null;
      _labelStyle = null;
      _textColor = null;
      _iconColor = null;
      _backgroundColor = null;
      _outlineColor = null;
    }
  }

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
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
          TileState.standard =>
            (widget.location == AppLocation.list) ? TileState.verbose : TileState.groupEdit,
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

  // Init //

  @override
  void initState() {
    super.initState();
    widget.rippleProgress?.addListener(rippling);
  }

  // Return the build //

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
            verboseSpace(),
            EzLink(
              widget.config,
              text: base,
              url: Uri.parse('https://$base'),
              hint: widget.config.ezL10n.gOpenLink,
              style: widget.config.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ]
        : <Widget>[];
  }

  Widget verboseSpace() => switch (state) {
        TileState.verbose => SizedBox(
            height: widget.config.iconSize,
            child: VerticalDivider(
                width: widget.config.spacing, color: widget.config.colors.secondary),
          ),
        _ => SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
      };

  @override
  Widget build(BuildContext context) {
    final int numLanes = widget.appInfo.numLanes(widget.config);

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            controller: menuControl,
            builder: (_, __, ___) => (widget.location == AppLocation.folder)
                ? AppButton(
                    widget.config,
                    name: widget.app.label,
                    image: widget.app.icon,
                    icon: widget._icon,
                    iconSize: widget._iconSize,
                    buttonType: listBT(widget.config),
                    labelType: listLabels(widget.config),
                    labelStyle: widget._labelStyle ?? TxtStile.body,
                    textColor: widget._textColor ?? widget.config.colors.onSurface,
                    iconColor: widget._iconColor ?? widget.config.colors.primary,
                    backgroundColor: widget._backgroundColor ?? widget.config.colors.surface,
                    outlineColor: widget._outlineColor ?? widget.config.colors.primaryContainer,
                    onPressed: () => widget.onSelected(widget.app),
                    onLongPress: () async => await canToggleMenu(widget.config, menuControl),
                  )
                : WideTile(
                    widget.config,
                    onTap: () => widget.onSelected(widget.app),
                    onLongPress: () async => await canToggleMenu(widget.config, menuControl),
                    alignment: widget.pos == null
                        ? LAConfig.merge(h: widget.hAlign!, v: widget.vAlign!)
                        : widget.pos!.subAlign,
                    child: AppButton(
                      widget.config,
                      name: widget._name ?? widget.app.label,
                      image: widget.app.icon,
                      icon: widget._icon,
                      iconSize: widget._iconSize,
                      buttonType: widget._buttonType ?? listBT(widget.config),
                      labelType: widget._labelType ?? listLabels(widget.config),
                      labelStyle: widget._labelStyle ?? TxtStile.body,
                      textColor: widget._textColor ?? widget.config.colors.onSurface,
                      iconColor: widget._iconColor ?? widget.config.colors.primary,
                      backgroundColor: widget._backgroundColor ?? widget.config.colors.surface,
                      outlineColor: widget._outlineColor ?? widget.config.colors.primaryContainer,
                      onPressed: () => widget.onSelected(widget.app),
                      onLongPress: () async => await canToggleMenu(widget.config, menuControl),
                    ),
                  ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              app: widget.app,
              location: widget.location,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: (widget.location == AppLocation.home)
                  ? AppConfig(
                      tp: widget._tp,
                      app: widget.app,
                      name: widget._name,
                      icon: widget._icon,
                      iconSize: widget._iconSize,
                      buttonType: widget._buttonType,
                      labelType: widget._labelType,
                      labelStyle: widget._labelStyle,
                      textColor: widget._textColor,
                      iconColor: widget._iconColor,
                      backgroundColor: widget._backgroundColor,
                      outlineColor: widget._outlineColor,
                    )
                  : null,
            ),
          ),
        TileState.verbose => EzScrollBlocker(
            EzScrollView(
              widget.config,
              showScrollHint: true,
              thumbVisibility: false,
              scrollDirection: Axis.horizontal,
              mainAxisAlignment: widget.hAlign!.mainAxis,
              children: LSConfig.verbOrder(widget.verbStart!).fold(
                <Widget>[],
                (List<Widget>? acc, ListSort field) => <Widget>[
                  ...acc!,
                  switch (field) {
                    ListSort.name => AppButton(
                        widget.config,
                        name: widget.app.label,
                        image: widget.app.icon,
                        icon: null,
                        iconSize: null,
                        buttonType: listBT(widget.config),
                        labelType: listLabels(widget.config),
                        labelStyle: widget._labelStyle ?? TxtStile.body,
                        textColor: widget._textColor ?? widget.config.colors.onSurface,
                        iconColor: widget._iconColor ?? widget.config.colors.primary,
                        backgroundColor: widget._backgroundColor ?? widget.config.colors.surface,
                        outlineColor: widget._outlineColor ?? widget.config.colors.primaryContainer,
                        onPressed: () => widget.onSelected(widget.app),
                      ),
                    ListSort.publisher => EzRow(
                        widget.config,
                        children: <Widget>[
                          EzText(
                            widget.config,
                            text: widget.app.package,
                            textAlign: TextAlign.center,
                          ),
                          ...publisherLink(),
                        ],
                      ),
                    ListSort.date => EzText(
                        widget.config,
                        text: DTConfig.buildDate(
                          context,
                          DateTime.fromMillisecondsSinceEpoch(widget.app.installDate),
                          DateType.compact,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ListSort.size => EzText(
                        widget.config,
                        text: '${(widget.app.packageSize / _toMB).toStringAsFixed(2)} MB',
                        textAlign: TextAlign.center,
                      ),
                  },
                  verboseSpace(),
                ],
              ),
            ),
          ),
        TileState.groupEdit => EditContainer(
            widget.config,
            subAlign: widget.pos!.subAlign,
            menuControl: menuControl,
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              app: widget.app,
              location: widget.location,
              state: state,
              editReset: widget.editReset,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: AppConfig(
                tp: widget._tp,
                app: widget.app,
                name: widget._name,
                icon: widget._icon,
                iconSize: widget._iconSize,
                buttonType: widget._buttonType,
                labelType: widget._labelType,
                labelStyle: widget._labelStyle,
                textColor: widget._textColor,
                iconColor: widget._iconColor,
                backgroundColor: widget._backgroundColor,
                outlineColor: widget._outlineColor,
              ),
            ),
            child: widget._icon == null
                ? GestureDetector(
                    onTap: () => toggleMenu(menuControl),
                    child: Image.memory(
                      widget.app.icon!,
                      semanticLabel: widget._name ?? widget.app.label,
                      width: appIconSize(widget.config),
                      height: appIconSize(widget.config),
                    ),
                  )
                : EzIconButton(
                    widget.config,
                    icon: Icon(widget._icon),
                    tooltip: widget._name ?? widget.app.label,
                    onPressed: () => toggleMenu(menuControl),
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

List<Widget> _menuChildren(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext context,
  required AppInfo app,
  required AppLocation location,
  required TileState state,
  required void Function()? editReset,
  required int numLanes,
  required LimPos? pos,
  required AppConfig? initConfig,
}) =>
    switch (location) {
      AppLocation.home => <Widget>[
          // Edit
          _EditApp(
            config,
            appInfo,
            pContext: context,
            initConfig: initConfig!,
            lane: pos!.lane,
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
                await editApp(
                  config,
                  appInfo: appInfo,
                  pContext: ezRootContext,
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
          reposition(config, appInfo, pos, stateCheck: editReset!),

          // Move
          if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
            moveDownLane(config, appInfo, pos, numLanes: numLanes),
            moveUpLane(config, appInfo, pos, numLanes: numLanes),
          ],

          // Remove
          removeItem(config, appInfo, pos),

          // Base
          ..._baseMC(config, appInfo, context: context, app: app),
        ],
      _ => _baseMC(config, appInfo, context: context, app: app),
    };

List<Widget> _baseMC(
  EzCP config,
  AppInfoProvider appInfo, {
  required BuildContext context,
  required AppInfo app,
}) =>
    <Widget>[
      // Info
      EzMenuButton(
        config,
        label: l10n(config).mcInfo,
        icon: EzIcon(config, Icons.info),
        onPressed: () => openAppSettings(app),
      ),

      // Show/hide
      appInfo.hidden(config).contains(app.id)
          ? EzMenuButton(
              config,
              label: l10n(config).mcShow,
              icon: EzIcon(config, Icons.visibility),
              onPressed: () => appInfo.showApp(config, app.id),
            )
          : EzMenuButton(
              config,
              label: l10n(config).mcHide,
              icon: EzIcon(config, Icons.visibility_off),
              onPressed: () => appInfo.hideApp(config, context, app.id),
            ),

      // Banish
      EzMenuButton(
        config,
        label: l10n(config).mcBanish,
        icon: EzIcon(config, LineIcons.ghost),
        onPressed: () => appInfo.banishApp(config, context, app),
      ),

      // Uninstall
      if (app.removable)
        EzMenuButton(
          config,
          label: l10n(config).mcUninstall,
          icon: EzIcon(config, Icons.delete),
          onPressed: () => openDelete(app),
        ),
    ];

//* Add Widget *//

class AppButton extends StatelessWidget {
  final EzCP config;
  final String name;
  final Uint8List? image;
  final IconData? icon;
  final double? iconSize;
  final ButtonType buttonType;
  final LabelType labelType;
  final TxtStile labelStyle;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color outlineColor;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const AppButton(
    this.config, {
    super.key,
    required this.name,
    required this.image,
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

  Widget appIcon({bool excluding = true}) => ExcludeSemantics(
        excluding: excluding,
        child: (icon == null)
            ? (image == null)
                ? Icon(
                    Icons.question_mark,
                    semanticLabel: name,
                    size: iconSize ?? appIconSize(config),
                    color: iconColor,
                  )
                : Image.memory(
                    image!,
                    semanticLabel: name,
                    width: iconSize ?? appIconSize(config),
                    height: iconSize ?? appIconSize(config),
                  )
            : Icon(
                icon!,
                semanticLabel: name,
                size: iconSize ?? appIconSize(config),
                color: iconColor,
              ),
      );

  @override
  Widget build(BuildContext context) => switch (buttonType) {
        ButtonType.icon => Tooltip(
            message: name,
            child: GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: appIcon(excluding: false),
            ),
          ),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: appIcon(),
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
            icon: appIcon(),
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
            icon: appIcon(),
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

String defaultAppEntry(String name) => _appEntry(
      tp: nullTPS,
      name: name,
      icon: null,
      iconSize: null,
      buttonType: null,
      labelType: null,
      labelStyle: null,
      textColor: null,
      iconColor: null,
      backgroundColor: null,
      outlineColor: null,
    );

String _appEntry({
  required String tp,
  required String name,
  required IconData? icon,
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
      name,
      (icon == null ? esSystem : icon.codePoint.toString()),
      (iconSize == null ? esSystem : iconSize.toString()),
      (buttonType == null ? esSystem : buttonType.value),
      (labelType == null ? esSystem : labelType.value),
      (labelStyle == null ? esSystem : labelStyle.value),
      (textColor == null ? esSystem : textColor.toARGB32().toString()),
      (iconColor == null ? esSystem : iconColor.toARGB32().toString()),
      (backgroundColor == null ? esSystem : backgroundColor.toARGB32().toString()),
      (outlineColor == null ? esSystem : outlineColor.toARGB32().toString()),
    ].join(configSplit);

const int _toMB = 1048576;

//* Edit Widget *//

class AppConfig {
  final String tp;
  final AppInfo app;
  final String? name;
  final IconData? icon;
  final double? iconSize;
  final ButtonType? buttonType;
  final LabelType? labelType;
  final TxtStile? labelStyle;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? outlineColor;

  AppConfig({
    required this.tp,
    required this.app,
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

Future<void> editApp(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required AppConfig initConfig,
  required int lane,
  required int index,
}) async {
  final ButtonStyle textButtonStyle = TextButton.styleFrom(
    backgroundColor: config.colors.surfaceContainer,
    padding: EdgeInsets.zero,
  );
  final EdgeInsets wrapPadding = EzInsets.wrap(config.spacing);
  final double iconRadius = config.iconSize / 2;

  AppInfo app = initConfig.app;

  final TextEditingController renameCon = TextEditingController(
    text: initConfig.name ?? app.label,
  );

  IconData? icon = initConfig.icon;
  double? iconSize = initConfig.iconSize;

  LabelType? labelType = initConfig.labelType;
  TxtStile labelStyle = initConfig.labelStyle ?? TxtStile.body;
  bool showIcon = iconBTs.contains(initConfig.buttonType ?? listBT(config));
  bool elevated = elevatedBTs.contains(initConfig.buttonType ?? listBT(config));

  Color textColor = initConfig.textColor ?? config.colors.onSurface;
  Color iconColor = initConfig.iconColor ?? config.colors.primary;
  Color backgroundColor = initConfig.backgroundColor ?? config.colors.surface;
  Color outlineColor = initConfig.outlineColor ?? config.colors.primaryContainer;

  final bool? update = await ezFullScreenModal<bool>(
    config,
    context: pContext,
    child: StatefulBuilder(
      builder: (BuildContext mCon, StateSetter setModal) =>
          EzCol(mainAxisSize: MainAxisSize.max, children: <Widget>[
        EzHeader(config),

        // Preview
        AppButton(
          config,
          name: validateName(config, renameCon.text) == null ? renameCon.text : app.label,
          image: app.icon,
          icon: icon,
          iconSize: iconSize,
          buttonType: BTConfig.build(
            labelType ?? listLabels(config),
            icons: showIcon,
            elevated: elevated,
          ),
          labelType: labelType ?? listLabels(config),
          labelStyle: labelStyle,
          textColor: textColor,
          iconColor: iconColor,
          backgroundColor: backgroundColor,
          outlineColor: outlineColor,
          onPressed: doNothing,
          onLongPress: () => pContext.pushNamed(
            appListPath,
            extra: ListConfig(
              listContent: <ListContent>{ListContent.banished, ListContent.hidden},
              include: false,
              onSelected: (AppInfo newApp) async {
                if (newApp == app) {
                  if (pContext.mounted) Navigator.of(pContext).pop();
                  return;
                }
                if (renameCon.text == app.label) renameCon.text = newApp.label;
                setModal(() => app = newApp);

                if (pContext.mounted) Navigator.of(pContext).pop();
              },
              title: EzTextIconButton(
                config,
                onPressed: doNothing,
                label: renameCon.text,
                icon: EzIcon(config, Icons.edit),
                textStyle: config.labelStyle,
              ),
            ),
          ),
        ),
        EzTitledDivider(
          config,
          header: true,
          title: Text(
            l10n(config).dbsChangeApp,
            textAlign: TextAlign.center,
            style: config.labelStyle,
          ),
          height: config.spacing * 2,
        ),

        Expanded(
          child: EzScrollView(config, showScrollHint: true, children: <Widget>[
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
                  hintText: l10n(config).hsApp,
                  autofillHints: const <String>[AutofillHints.name],
                  validator: (String? check) => validateName(config, check),
                ),
                config.rowSpacer,

                // Plus/minus
                EzIconButton(
                  config,
                  enabled: showIcon && (iconSize == null || iconSize! > minIconSize),
                  icon: const Icon(Icons.remove),
                  tooltip: config.ezL10n.gDecrease,
                  onPressed: () {
                    iconSize = (iconSize == null) ? (appIconSize(config) - 1) : (iconSize! - 1);
                    setModal(() => iconSize = max(iconSize!, minIconSize));
                  },
                ),
                config.rowMargin,
                (icon == null && app.icon != null)
                    ? GestureDetector(
                        onTap: showIcon
                            ? () async {
                                final IconData? choice = await chooseIcon(config, pContext);
                                if (choice != null) setModal(() => icon = choice);
                              }
                            : null,
                        onLongPress: showIcon ? () => setModal(() => iconSize = null) : null,
                        child: Image.memory(
                          app.icon!,
                          semanticLabel: app.label,
                          width: iconSize ?? appIconSize(config),
                          height: iconSize ?? appIconSize(config),
                        ),
                      )
                    : EzIconButton(
                        config,
                        icon: Icon(icon ?? Icons.settings, size: iconSize ?? appIconSize(config)),
                        tooltip: l10n(config).gPreview,
                        onPressed: showIcon
                            ? () async {
                                final IconData? choice = await chooseIcon(config, pContext);
                                if (choice != null) setModal(() => icon = choice);
                              }
                            : null,
                        onLongPress: showIcon
                            ? () => setModal(() {
                                  iconSize = null;
                                  icon = null;
                                })
                            : null,
                      ),
                config.rowMargin,
                EzIconButton(
                  config,
                  enabled: showIcon && (iconSize == null || iconSize! < maxIconSize),
                  icon: const Icon(Icons.add),
                  tooltip: config.ezL10n.gIncrease,
                  onPressed: () {
                    iconSize = (iconSize == null) ? (appIconSize(config) + 1) : (iconSize! + 1);
                    setModal(() => iconSize = min(iconSize!, maxIconSize));
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
                  onLongPress: () => setModal(() => outlineColor = config.colors.primaryContainer),
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
          ]),
        ),
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
          EzTextIconButton(
            config,
            label: config.ezL10n.gCancel,
            style: TextButton.styleFrom(backgroundColor: config.colors.surfaceContainer),
            icon: EzIcon(config, Icons.cancel),
            onPressed: () => Navigator.of(mCon).pop(),
          ),
          config.rowSpacer,
          EzTextIconButton(
            config,
            label: l10n(config).mcSave,
            style: TextButton.styleFrom(backgroundColor: config.colors.surfaceContainer),
            icon: EzIcon(config, Icons.done),
            onPressed: () => Navigator.of(mCon).pop(true),
          ),
        ]),
        config.separator,
      ]),
    ),
  );

  switch (update) {
    case true:
      await appInfo.updateApp(config,
          lane: lane,
          index: index,
          id: app.id,
          extra: _appEntry(
            tp: initConfig.tp,
            name: validateName(config, renameCon.text) == null
                ? renameCon.text
                : (initConfig.name ?? app.label),
            icon: icon,
            iconSize: iconSize,
            buttonType: BTConfig.build(labelType ?? listLabels(config),
                icons: showIcon, elevated: elevated),
            labelType: labelType,
            labelStyle: labelStyle,
            textColor: textColor,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
            outlineColor: outlineColor,
          ));
      return;

    case false:
      await appInfo.updateApp(
        config,
        lane: lane,
        index: index,
        id: app.id,
        extra: _appEntry(
          tp: initConfig.tp,
          name: app.label,
          icon: null,
          iconSize: null,
          buttonType: null,
          labelType: null,
          labelStyle: null,
          textColor: null,
          iconColor: null,
          backgroundColor: null,
          outlineColor: null,
        ),
      );
      return;

    default:
      return;
  }
}

class _EditApp extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final AppConfig initConfig;
  final int lane;
  final int index;

  const _EditApp(
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
        label: l10n(config).gEdit,
        icon: EzIcon(config, Icons.edit),
        onPressed: () => editApp(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
}
