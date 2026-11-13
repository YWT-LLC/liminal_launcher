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
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:material_ui/material_ui.dart';

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
  late final EzSwitchColor? _iconFill;
  late final EzSwitchColor? _backgroundFill;
  late final EzSwitchColor? _outlineFill;

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

      _iconFill = ezCOG(safeData(data!, 8));
      _backgroundFill = ezCOG(safeData(data!, 9));
      _outlineFill = ezCOG(safeData(data!, 10));
    } else {
      _name = null;
      _icon = null;
      _iconSize = null;
      _buttonType = null;
      _labelType = null;
      _labelStyle = null;
      _textColor = null;
      _iconFill = null;
      _backgroundFill = null;
      _outlineFill = null;
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
            child: EzVerticalDivider(
              widget.config,
              width: widget.config.spacing,
              fill: widget.config.secondaryFill,
            ),
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
                    textColor: widget._textColor ?? widget.config.onSurface,
                    iconFill: widget._iconFill ?? widget.config.primaryFill,
                    backgroundFill: widget._backgroundFill ?? widget.config.surfaceFill,
                    outlineFill: widget._outlineFill ?? widget.config.primaryContainerFill,
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
                      textColor: widget._textColor ?? widget.config.onSurface,
                      iconFill: widget._iconFill ?? widget.config.primaryFill,
                      backgroundFill: widget._backgroundFill ?? widget.config.surfaceFill,
                      outlineFill: widget._outlineFill ?? widget.config.primaryContainerFill,
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
                      iconFill: widget._iconFill,
                      backgroundFill: widget._backgroundFill,
                      outlineFill: widget._outlineFill,
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
                        textColor: widget._textColor ?? widget.config.onSurface,
                        iconFill: widget._iconFill ?? widget.config.primaryFill,
                        backgroundFill: widget._backgroundFill ?? widget.config.surfaceFill,
                        outlineFill: widget._outlineFill ?? widget.config.primaryContainerFill,
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
                iconFill: widget._iconFill,
                backgroundFill: widget._backgroundFill,
                outlineFill: widget._outlineFill,
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
                    icon: EzIcon(widget.config, widget._icon),
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
  final EzSwitchColor backgroundFill;
  final EzSwitchColor iconFill;
  final EzSwitchColor outlineFill;
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
    required this.backgroundFill,
    required this.iconFill,
    required this.outlineFill,
    this.onPressed,
    this.onLongPress,
  });

  Widget appIcon({bool excluding = true}) => ExcludeSemantics(
        excluding: excluding,
        child: (icon == null)
            ? (image == null)
                ? EzIcon(
                    config,
                    Icons.question_mark,
                    semanticLabel: name,
                    size: iconSize ?? appIconSize(config),
                    fill: iconFill,
                  )
                : Image.memory(
                    image!,
                    semanticLabel: name,
                    width: iconSize ?? appIconSize(config),
                    height: iconSize ?? appIconSize(config),
                  )
            : EzIcon(
                config,
                icon!,
                semanticLabel: name,
                size: iconSize ?? appIconSize(config),
                fill: iconFill,
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
            backgroundFill: backgroundFill,
            style: IconButton.styleFrom(side: config.borderSide(fill: outlineFill)),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            textStyle: labelStyle.style(config)?.copyWith(color: textColor),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(fill: backgroundFill),
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
              backgroundBuilder: config.buttonLayer(fill: backgroundFill),
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
            icon: appIcon(),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(fill: backgroundFill),
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
            icon: appIcon(),
            style: TextButton.styleFrom(
              backgroundBuilder: config.buttonLayer(fill: backgroundFill),
              backgroundColor: backgroundFill.asColor,
              padding: EdgeInsets.all(config.padding),
              side: config.borderSide(fill: outlineFill),
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
      iconFill: null,
      backgroundFill: null,
      outlineFill: null,
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
  required EzSwitchColor? iconFill,
  required EzSwitchColor? backgroundFill,
  required EzSwitchColor? outlineFill,
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
      (iconFill == null ? esSystem : iconFill.toString()),
      (backgroundFill == null ? esSystem : backgroundFill.toString()),
      (outlineFill == null ? esSystem : outlineFill.toString()),
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
  final EzSwitchColor? iconFill;
  final EzSwitchColor? backgroundFill;
  final EzSwitchColor? outlineFill;

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
    required this.iconFill,
    required this.backgroundFill,
    required this.outlineFill,
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
    backgroundColor: config.surfaceContainerFill.asColor,
    padding: EdgeInsets.zero,
  );
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

  Color textColor = initConfig.textColor ?? config.onSurface;
  EzSwitchColor iconFill = initConfig.iconFill ?? config.primaryFill;
  EzSwitchColor backgroundFill = initConfig.backgroundFill ?? config.surfaceFill;
  EzSwitchColor outlineFill = initConfig.outlineFill ?? config.primaryContainerFill;

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
          iconFill: iconFill,
          backgroundFill: backgroundFill,
          outlineFill: outlineFill,
          onPressed: doNothing,
          onLongPress: () => pContext.pushNamed(
            appListScreenName,
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
                  enabled: showIcon && (iconSize == null || iconSize! > ywt.minIconSize),
                  icon: EzIcon(config, Icons.remove),
                  tooltip: config.ezL10n.gDecrease,
                  onPressed: () {
                    iconSize = (iconSize == null) ? (appIconSize(config) - 1) : (iconSize! - 1);
                    setModal(() => iconSize = max(iconSize!, ywt.minIconSize));
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
                        icon: EzIcon(
                          config,
                          icon ?? Icons.settings,
                          size: iconSize ?? appIconSize(config),
                        ),
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
                  enabled: showIcon && (iconSize == null || iconSize! < ywt.maxIconSize),
                  icon: EzIcon(config, Icons.add),
                  tooltip: config.ezL10n.gIncrease,
                  onPressed: () {
                    iconSize = (iconSize == null) ? (appIconSize(config) + 1) : (iconSize! + 1);
                    setModal(() => iconSize = min(iconSize!, ywt.maxIconSize));
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
                      picking: textColor.toARGB32().toString(),
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
                      shape: BoxShape.circle,
                      border: config.boxBorder(),
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
                      setModal(() => backgroundFill = ezCOG(picked) ?? backgroundFill);
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
                      setModal(() => outlineFill = ezCOG(picked) ?? outlineFill);
                    }
                  },
                  onLongPress: () => setModal(() => outlineFill = config.primaryContainerFill),
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
          ]),
        ),
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
          EzTextIconButton(
            config,
            label: config.ezL10n.gCancel,
            style: TextButton.styleFrom(backgroundColor: config.surfaceContainerFill.asColor),
            icon: EzIcon(config, Icons.cancel),
            onPressed: () => Navigator.of(mCon).pop(),
          ),
          config.rowSpacer,
          EzTextIconButton(
            config,
            label: l10n(config).mcSave,
            style: TextButton.styleFrom(backgroundColor: config.surfaceContainerFill.asColor),
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
            iconFill: iconFill,
            backgroundFill: backgroundFill,
            outlineFill: outlineFill,
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
          iconFill: null,
          backgroundFill: null,
          outlineFill: null,
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
