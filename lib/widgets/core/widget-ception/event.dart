/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../../screens/export.dart';
import '../../../utils/export.dart';
import '../../export.dart';

import 'dart:async';
import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//* Core Widget *//

class EventWidget extends StatefulWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final LimPos pos;
  final TileState state;
  final ValueNotifier<double>? rippleProgress;

  late final String _tp;
  late final WWGGSize _size;
  late final bool _isCalendar;
  late final AppInfo? _shareDest;
  late final bool? _useAppIcon;

  EventWidget(
    this.config,
    this.appInfo,
    this.pos,
    this.state,
    this.rippleProgress, {
    super.key,
  }) {
    final List<String> data = appInfo
        .homeItem(config, lane: pos.lane, index: pos.index)
        .split(widgetSplit)[1]
        .split(configSplit);

    _tp = data[0]; // Not used here; tracked so local updates don't clobber it
    _size = WSConfig.safeLookup(data[1]);
    _isCalendar = bool.tryParse(data[2]) ?? true;
    _shareDest = appInfo.appMap[data[3]];
    _useAppIcon = bool.tryParse(data[4]);
  }

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  // Define the build data //

  late TileState state = widget.state;
  Timer? rippleThrottle;

  final MenuController menuControl = MenuController();

  final TextEditingController eventCon = TextEditingController();
  OverlayEntry? overlayEntry;

  // Define custom functions //

  void rippling() {
    if (rippleThrottle != null ||
        widget.rippleProgress == null ||
        widget.rippleProgress!.value <= 0) {
      return;
    }

    final Offset wya = ezWya(context);
    final double dy = (wya.dy - lastRipple.dy).abs();

    if (dy <= (widget.rippleProgress!.value * heightOf(context))) {
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

  void onChanged(String text) => text.isEmpty
      ? removeOverlay()
      : ((overlayEntry == null) ? showOverlay() : overlayEntry!.markNeedsBuild());

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: safeTop(context),
        left: widget.config.marginVal,
        right: widget.config.marginVal,
        child: Material(
          type: MaterialType.transparency,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.all(widget.config.marginVal),
              decoration: BoxDecoration(
                color: widget.config.colors.surfaceContainer,
                border: Border.all(
                  color: widget.config.colors.secondaryContainer,
                  width: widget.config.borderWidth,
                ),
                borderRadius: widget.config.textRadius,
              ),
              child: Text(
                eventCon.text,
                style: widget.config.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    ezRootOverlay?.insert(overlayEntry!);
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<dynamic> selfDestruct() => showDialog(
        context: context,
        builder: (_) => EzAlertDialog(
          widget.config,
          title: Text(l10n(widget.config).gFailed, textAlign: TextAlign.center),
          content: Text(l10n(widget.config).evtNoCalendar, textAlign: TextAlign.center),
          actions: <Widget>[
            EzAction(
              widget.config,
              text: l10n(widget.config).evtUseTasks,
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.appInfo.updateWidget(
                  widget.config,
                  WWGG.event,
                  _eventEntry(
                    tp: widget._tp,
                    size: widget._size,
                    isCalendar: false,
                    shareDest: widget._shareDest,
                    useAppIcon: widget._useAppIcon,
                  ),
                  lane: widget.pos.lane,
                  index: widget.pos.index,
                );
              },
              isDefaultAction: true,
            ),
            EzAction(
              widget.config,
              text: l10n(widget.config).gNothing,
              onPressed: () => Navigator.of(context).pop(),
            ),
            EzAction(
              widget.config,
              text: l10n(widget.config).gSelfDestruct,
              onPressed: () async {
                Navigator.of(context).pop();
                await ezNoTouch(
                  () => widget.appInfo.removeItem(
                    widget.config,
                    lane: widget.pos.lane,
                    index: widget.pos.index,
                  ),
                );
              },
              isDestructiveAction: true,
            ),
          ],
          needsClose: false,
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

    final ButtonStyle alwaysOn = IconButton.styleFrom(
      foregroundColor: widget.config.colors.primary,
      backgroundColor: widget.config.colors.surface,
      disabledForegroundColor: widget.config.colors.primary,
      disabledBackgroundColor: widget.config.colors.surface,
    );
    late final double textWidth = ezTextSize(
      '\t${widget._isCalendar ? l10n(widget.config).evtNewEvent : l10n(widget.config).evtNewTask}\t',
      context: context,
      style: widget.config.bodyStyle,
    ).width;
    final Widget icon = widget._isCalendar
        ? EzIconButton(
            widget.config,
            icon: const Icon(Icons.edit_calendar),
            style: alwaysOn,
          )
        : (widget._useAppIcon == true && widget._shareDest?.icon != null)
            ? Image.memory(
                widget._shareDest!.icon!,
                semanticLabel: widget._shareDest!.label,
                width: appIconSize(widget.config),
                height: appIconSize(widget.config),
              )
            : EzIconButton(
                widget.config,
                icon: const Icon(Icons.edit_calendar),
                style: alwaysOn,
              );

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WWGGSize.button)
                ? GestureDetector(
                    child: icon,
                    onTap: () async {
                      if (widget._isCalendar) {
                        final bool success = await createCalendarEvent(null);
                        if (!success && context.mounted) await selfDestruct();
                        return;
                      }

                      widget._shareDest == null
                          ? await _openEdits(
                              widget.config,
                              appInfo: widget.appInfo,
                              pContext: context,
                              initConfig: _EventConfig(
                                tp: widget._tp,
                                size: widget._size,
                                isCalendar: widget._isCalendar,
                                shareDest: widget._shareDest,
                                useAppIcon: widget._useAppIcon,
                              ),
                              lane: widget.pos.lane,
                              index: widget.pos.index,
                            )
                          : await launchApp(widget._shareDest!);
                    },
                    onLongPress: () async => await canToggleMenu(widget.config, controller),
                  )
                : EzScrollBlocker(EzScrollView(
                    widget.config,
                    reverseHands: true,
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      EzTextField(
                        controller: eventCon,
                        constraints: BoxConstraints(
                          maxHeight: appIconSize(widget.config),
                          maxWidth: textWidth + widget.config.padding,
                        ),
                        errorConstraints: BoxConstraints(
                          maxWidth: (textWidth * 2) + widget.config.padding,
                        ),
                        hintText: widget._isCalendar
                            ? l10n(widget.config).evtNewEvent
                            : l10n(widget.config).evtNewTask,
                        onChanged: onChanged,
                        onFieldSubmitted: (String entry) async {
                          final bool success = widget._isCalendar
                              ? await createCalendarEvent(entry)
                              : await createTask(entry, widget._shareDest);

                          eventCon.clear();
                          removeOverlay();

                          if (!success && context.mounted) await selfDestruct();
                        },
                        validator: null,
                      ),
                      widget.config.rowMargin,
                      GestureDetector(
                        onTap: () async {
                          final bool success = widget._isCalendar
                              ? await createCalendarEvent(eventCon.text)
                              : await createTask(eventCon.text, widget._shareDest);

                          eventCon.clear();
                          removeOverlay();

                          if (!success && context.mounted) await selfDestruct();
                        },
                        onLongPress: () async => await canToggleMenu(widget.config, controller),
                        child: icon,
                      ),
                    ],
                  )),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _EventConfig(
                tp: widget._tp,
                size: widget._size,
                isCalendar: widget._isCalendar,
                shareDest: widget._shareDest,
                useAppIcon: widget._useAppIcon,
              ),
            ),
          ),
        _ => EditContainer(
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
              initConfig: _EventConfig(
                tp: widget._tp,
                size: widget._size,
                isCalendar: widget._isCalendar,
                shareDest: widget._shareDest,
                useAppIcon: widget._useAppIcon,
              ),
            ),
            child: GestureDetector(
              child: icon,
              onTap: () => toggleMenu(menuControl),
            ),
          ),
      },
    );
  }

  @override
  void dispose() {
    removeOverlay();
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
  required _EventConfig initConfig,
}) =>
    <Widget>[
      // Edit
      _EditEvent(
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
            await _openEdits(
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

      // Move
      if (state == TileState.groupEdit && numLanes > 1) ...<Widget>[
        moveDownLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
        moveUpLane(config, appInfo, numLanes: numLanes, lane: pos.lane, index: pos.index),
      ],

      // Remove
      removeItem(config, appInfo, lane: pos.lane, index: pos.index),
    ];

//* Add Widget *//

class AddEvent extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final int lane;
  final WWGGSize size;

  const AddEvent(
    this.config, {
    super.key,
    required this.appInfo,
    required this.pContext,
    required this.lane,
    required this.size,
  });

  void onTap() => appInfo.addWidget(
        config,
        type: WWGG.event,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _EventConfig(
            tp: nullTPS,
            size: size,
            isCalendar: true,
            shareDest: null,
            useAppIcon: null,
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => (size == WWGGSize.button)
      ? EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.edit_calendar))
      : GestureDetector(
          onTap: onTap,
          child: EzScrollView(
            config,
            reverseHands: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              EzTextField(
                constraints: BoxConstraints(
                  maxHeight: appIconSize(config),
                  maxWidth: ezTextSize(
                        '\t${l10n(config).evtNewEvent}\t',
                        context: context,
                        style: config.bodyStyle,
                      ).width +
                      config.padding,
                ),
                hintText: l10n(config).evtNewEvent,
                onTap: onTap,
                readOnly: true,
                validator: null,
              ),
              config.rowMargin,
              EzIconButton(config, icon: const Icon(Icons.edit_calendar), onPressed: onTap),
            ],
          ),
        );
}

String defaultEventEntry() => _eventEntry(
      tp: nullTPS,
      size: WWGGSize.tile,
      isCalendar: true,
      shareDest: null,
      useAppIcon: null,
    );

String _eventEntry({
  required String tp,
  required WWGGSize size,
  required bool isCalendar,
  required AppInfo? shareDest,
  required bool? useAppIcon,
}) =>
    <String>[
      tp,
      size.value,
      isCalendar.toString(),
      shareDest?.id ?? 'null',
      useAppIcon?.toString() ?? 'null'
    ].join(configSplit);

//* Edit Widget *//

class _EventConfig {
  final String tp;
  final WWGGSize size;
  final bool isCalendar;
  final AppInfo? shareDest;
  final bool? useAppIcon;

  _EventConfig({
    required this.tp,
    required this.size,
    required this.isCalendar,
    required this.shareDest,
    required this.useAppIcon,
  });
}

Future<void> _openEdits(
  EzCP config, {
  required AppInfoProvider appInfo,
  required BuildContext pContext,
  required _EventConfig initConfig,
  required int lane,
  required int index,
}) async {
  WWGGSize size = initConfig.size;
  bool isCalendar = initConfig.isCalendar;
  AppInfo shareDest = initConfig.shareDest ?? nullApp;
  bool? useAppIcon;

  await ezModal(
    config,
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (_, StateSetter setModal) => ezModalScroll(config, children: <Widget>[
        // Size
        EzFlipFlop(
          config,
          onLabel: l10n(config).gTile,
          offLabel: l10n(config).gButton,
          init: initConfig.size == WWGGSize.tile,
          onChanged: (bool tile) => setModal(() => size = tile ? WWGGSize.tile : WWGGSize.button),
        ),
        config.spacer,

        // Type
        EzFlipFlop(
          config,
          onLabel: l10n(config).evtCalendar,
          offLabel: l10n(config).evtTask,
          init: initConfig.isCalendar,
          onChanged: (bool choice) => setModal(() => isCalendar = choice),
        ),
        config.separator,

        // Share Dest //

        Text(
          l10n(config).evtShare,
          textAlign: TextAlign.center,
          style: config.bodyStyle,
        ),

        AppButton(
          config,
          name: shareDest.label,
          image: shareDest.icon,
          icon: null,
          iconSize: null,
          labelType: listLabels(config),
          buttonType: listBT(config),
          onPressed: () => pContext.pushNamed(
            appListPath,
            extra: ListConfig(
              listContent: <ListContent>{ListContent.banished},
              include: false,
              onSelected: (AppInfo choice) async {
                if (pContext.mounted) Navigator.of(pContext).pop();
                setModal(() {
                  shareDest = choice;
                  useAppIcon = (useAppIcon ?? true);
                });
              },
              title: EzTextButton(
                config,
                onPressed: doNothing,
                text: l10n(config).evtShareDest,
                textStyle: config.labelStyle,
              ),
            ),
          ),
          onLongPress: () => setModal(() {
            shareDest = nullApp;
            useAppIcon = null;
          }),
        ),

        // Conditional clear (reminder)
        EzAnimVis(
          config,
          mod: 0.667,
          forceFade: true,
          forceType: EzTransitionType.zoom,
          visible: (shareDest != nullApp),
          kid: EzCol(children: <Widget>[
            // Clear reminder
            config.margin,
            Text(
              l10n(config).evtClear,
              textAlign: TextAlign.center,
              style: config.labelStyle,
            ),
            config.spacer,

            // Use icon switch
            EzSwitchPair(
              config,
              key: ValueKey<bool?>(useAppIcon),
              value: useAppIcon ?? true,
              text: l10n(config).evtAppIcon,
              onChanged: (bool? choice) => setModal(() => useAppIcon = choice),
            ),
          ]),
        ),
        config.separator,
      ]),
    ),
  );

  await appInfo.updateWidget(
    config,
    WWGG.event,
    _eventEntry(
      tp: initConfig.tp,
      size: size,
      isCalendar: isCalendar,
      shareDest: shareDest == nullApp ? null : shareDest,
      useAppIcon: useAppIcon,
    ),
    lane: lane,
    index: index,
  );
}

class _EditEvent extends StatelessWidget {
  final EzCP config;
  final AppInfoProvider appInfo;
  final BuildContext pContext;
  final _EventConfig initConfig;
  final int lane;
  final int index;

  const _EditEvent(
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
        onPressed: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: initConfig,
          lane: lane,
          index: index,
        ),
      );
}
