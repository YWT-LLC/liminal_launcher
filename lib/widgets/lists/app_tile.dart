/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late final String? _name;
  late final String? _icon;
  late final String? _buttonType;
  late final String? _labelType;

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
  }) : super(key: ValueKey<String>('${app.id}-${state.index}')) {
    if (lane != null && index != null) {
      final List<String> data =
          appInfo.homeItem(config, lane: lane!, index: index!).split(idSplit)[2].split(configSplit);

      _name = data[0];
      _icon = data[1];
      _buttonType = data[2];
      _labelType = data[3];
    } else {
      _name = null;
      _icon = null;
      _buttonType = null;
      _labelType = null;
    }
  }

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Define the build data //

  late AppState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  late final bool inList = widget.location == AppLocation.list;
  late final bool inFolder = widget.location == AppLocation.folder;

  late String? name = widget._name;
  late IconData? iconData = (widget._icon == null || widget._icon == esSystem)
      ? null
      : (int.tryParse(widget._icon!) == null)
          ? null
          // ignore: non_const_argument_for_const_parameter
          : IconData(int.tryParse(widget._icon!)!);
  late Widget? icon = iconData == null ? null : Icon(iconData);
  late ButtonType? buttonType = BTConfig.lookup(widget._buttonType);
  late LabelType? labelType = LTConfig.lookup(widget._labelType);

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
            AppState.standard => inList ? AppState.verbose : AppState.groupEdit,
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
        AppState.verbose => SizedBox(
            height: widget.config.iconSize,
            child: VerticalDivider(
              width: widget.config.spacing,
              color: widget.config.colors.secondary,
            ),
          ),
        _ => SizedBox(height: widget.config.iconSize, width: widget.config.spacing),
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
    final int numLanes = widget.appInfo.numLanes(widget.config);

    final ListAlignment hA = hAlign(widget.config);
    final AlignmentGeometry subAlign = LAConfig.merge(h: hA, v: ListAlignment.center);

    late final EzMenuButton remove = removeItem(widget.config, widget.appInfo,
        lane: widget.lane!, index: widget.index!, delete: false);

    late final EzMenuButton uninstall = EzMenuButton(
      widget.config,
      label: 'Uninstall',
      icon: EzIcon(widget.config, Icons.delete),
      onPressed: () async => await openDelete(widget.app),
    );

    late final EzMenuButton banish = EzMenuButton(
      widget.config,
      label: 'Banish',
      icon: EzIcon(widget.config, LineIcons.ghost),
      onPressed: () async => await widget.appInfo.banishApp(widget.config, context, widget.app.id),
    );

    late final EzMenuButton hide = EzMenuButton(
      widget.config,
      label: 'Hide',
      icon: EzIcon(widget.config, Icons.visibility_off),
      onPressed: () async => await widget.appInfo.hideApp(widget.config, context, widget.app.id),
    );

    late final EzMenuButton show = EzMenuButton(
      widget.config,
      label: 'Show',
      icon: EzIcon(widget.config, Icons.visibility),
      onPressed: () async => await widget.appInfo.showApp(widget.config, widget.app.id),
    );

    late final EzMenuButton info = EzMenuButton(
      widget.config,
      label: 'Info',
      icon: EzIcon(widget.config, Icons.info),
      onPressed: () async {
        if (inList && context.mounted) Navigator.of(context).pop();
        await openSettings(widget.app);
      },
    );

    late final EzMenuButton add = EzMenuButton(
      widget.config,
      label: 'Add',
      icon: EzIcon(widget.config, Icons.add_home),
      onPressed: () async => await widget.appInfo.addApp(widget.config, lane: 0, id: widget.app.id),
    );

    late final EzMenuButton edit = EzMenuButton(
      widget.config,
      label: 'Edit',
      icon: EzIcon(widget.config, Icons.edit),
      onPressed: () async {
        final TextEditingController nameCon = TextEditingController(text: name ?? widget.app.label);

        await ezModal(
          widget.config,
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (BuildContext mCon, StateSetter setModal) => ezModalScroll(
              widget.config,
              children: <Widget>[
                // TODO: icon, name, button, label
              ],
            ),
          ),
        );

        // TODO: validate here (and all others)
        await widget.appInfo.updateApp(
          widget.config,
          lane: widget.lane!,
          index: widget.index!,
          id: widget.app.id,
          extra: TCC.appEntry(nameCon.text.trim(), iconData, buttonType, labelType),
        );
      },
    );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceType: EzTransitionType.none,
      forceFade: true,
      child: switch (state) {
        AppState.standard => inFolder
            ? AppButton(
                widget.config,
                name: widget.app.label,
                image: widget.app.icon,
                icon: icon,
                buttonType: folderBT(widget.config),
                labelType: folderLabels(widget.config),
                onPressed: () => widget.onSelected(widget.app),
              )
            : MenuAnchor(
                builder: (_, MenuController controller, __) => wideTiles(widget.config)
                    ? InkWell(
                        onTap: () => widget.onSelected(widget.app),
                        onLongPress: () => canToggleMenu(widget.config, controller),
                        child: Container(
                          width: double.infinity,
                          alignment: subAlign,
                          child: AppButton(
                            widget.config,
                            name: name ?? widget.app.label,
                            image: widget.app.icon,
                            icon: icon,
                            buttonType: buttonType ?? listBT(widget.config),
                            labelType: labelType ?? listLabels(widget.config),
                            onPressed: () => widget.onSelected(widget.app),
                            onLongPress: () => canToggleMenu(widget.config, controller),
                          ),
                        ),
                      )
                    : AppButton(
                        widget.config,
                        name: name ?? widget.app.label,
                        image: widget.app.icon,
                        icon: icon,
                        buttonType: buttonType ?? listBT(widget.config),
                        labelType: labelType ?? listLabels(widget.config),
                        onPressed: () => widget.onSelected(widget.app),
                        onLongPress: () => canToggleMenu(widget.config, controller),
                      ),
                menuChildren: inList
                    ? <Widget>[
                        info,
                        if (numLanes == 1 &&
                            !widget.appInfo.hidden(widget.config).contains(widget.app.id))
                          add,
                        widget.appInfo.hidden(widget.config).contains(widget.app.id) ? show : hide,
                        banish,
                        if (widget.app.removable) uninstall,
                      ]
                    : <Widget>[
                        edit,
                        info,
                        remove,
                        hide,
                        banish,
                        if (widget.app.removable) uninstall,
                      ],
              ),
        AppState.verbose => EzScrollBlocker(
            EzScrollView(
              widget.config,
              showScrollHint: true,
              thumbVisibility: false,
              mainAxisAlignment: hA.mainAxis,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                // Name && icon
                AppButton(
                  widget.config,
                  name: widget.app.label,
                  image: widget.app.icon,
                  icon: null,
                  buttonType: listBT(widget.config),
                  labelType: listLabels(widget.config),
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
        AppState.groupEdit => EditContainer(
            widget.config,
            menuControl: menuControl,
            menuChildren: <Widget>[
              edit,
              info,
              remove,
              hide,
              banish,
              if (widget.app.removable) uninstall,
            ],
            child: icon ??
                Image.memory(
                  widget.app.icon!,
                  semanticLabel: name,
                  width: appIconSize(widget.config),
                  height: appIconSize(widget.config),
                  alignment: subAlign,
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
  final String name;
  final Uint8List? image;
  final Widget? icon;
  final ButtonType buttonType;
  final LabelType labelType;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const AppButton(
    this.config, {
    super.key,
    required this.name,
    required this.image,
    required this.icon,
    required this.buttonType,
    required this.labelType,
    this.onPressed,
    this.onLongPress,
  });

  Widget appIcon() => (icon == null)
      ? (image == null)
          ? Icon(Icons.question_mark, semanticLabel: name)
          : Image.memory(
              image!,
              semanticLabel: name,
              width: appIconSize(config),
              height: appIconSize(config),
            )
      : icon!;

  @override
  Widget build(BuildContext context) => switch (buttonType) {
        ButtonType.icon => Tooltip(
            message: name,
            child: GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: appIcon(),
            )),
        ButtonType.eIcon => EzIconButton(
            config,
            tooltip: name,
            onPressed: onPressed,
            onLongPress: onLongPress,
            icon: appIcon(),
          ),
        ButtonType.text => EzTextButton(
            config,
            text: buildLabel(name, labelType),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < 0.01
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
            icon: appIcon(),
            style: TextButton.styleFrom(
              padding: config.textBackgroundOpacity < 0.01
                  ? EdgeInsets.zero
                  : EdgeInsets.all(config.padding),
            ),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ButtonType.eTextIcon => EzElevatedIconButton(
            config,
            label: buildLabel(name, labelType),
            icon: appIcon(),
            style: TextButton.styleFrom(padding: EdgeInsets.all(config.padding)),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
      };
}

const int _toMB = 1048576;
