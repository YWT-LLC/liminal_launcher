/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../export.dart';

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

  late final WidgetSize _size;
  late final bool _isCalendar;
  late final AppInfo? _shareDest;

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

    _size = WSConfig.safeLookup(data[0]);
    _isCalendar = bool.tryParse(data[1]) ?? true;
    _shareDest = appInfo.appMap[data[2]];
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
          title: const Text('Failed', textAlign: TextAlign.center),
          content: const Text(
            """Can't find a default calendar app.
What shall I do?

'Task' is just share underneath. You'll choose a default app to share with.
We recommend using a task app, but don't require.
Results may vary.""",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            EzAction(
              widget.config,
              text: 'Switch to tasks',
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.appInfo.updateWidget(
                  widget.config,
                  WidWidGetGet.event,
                  _eventEntry(widget._size, !widget._isCalendar, widget._shareDest),
                  lane: widget.pos.lane,
                  index: widget.pos.index,
                );
              },
              isDefaultAction: true,
            ),
            EzAction(widget.config, text: 'Nothing', onPressed: () => Navigator.of(context).pop()),
            EzAction(
              widget.config,
              text: 'Self-destruct',
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

    late final double textWidth = ezTextSize(
      'Create event',
      context: context,
      style: widget.config.bodyStyle,
    ).width;
    final IconData icon = widget._isCalendar ? Icons.edit_calendar : Icons.task_alt;

    return EzAnimSwitch(
      widget.config,
      mod: 0.667,
      forceFade: true,
      forceType: EzTransitionType.none,
      child: switch (state) {
        TileState.standard => MenuAnchor(
            builder: (_, MenuController controller, __) => (widget._size == WidgetSize.button)
                ? EzIconButton(
                    widget.config,
                    icon: Icon(icon),
                    onPressed: () async {
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
                                size: widget._size,
                                isCalendar: widget._isCalendar,
                                shareDest: widget._shareDest,
                              ),
                              lane: widget.pos.lane,
                              index: widget.pos.index,
                            )
                          : await launchApp(widget._shareDest!);
                    },
                    onLongPress: () => canToggleMenu(widget.config, controller),
                  )
                : EzRow(
                    widget.config,
                    children: <Widget>[
                      EzScrollBlocker(
                        EzTextField(
                          controller: eventCon,
                          constraints: BoxConstraints(
                            maxHeight: appIconSize(widget.config),
                            maxWidth: textWidth + widget.config.padding,
                          ),
                          errorConstraints: BoxConstraints(
                            maxWidth: (textWidth * 2) + widget.config.padding,
                          ),
                          hintText: widget._isCalendar ? 'New event' : 'New task',
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
                      ),
                      widget.config.rowMargin,
                      EzIconButton(
                        widget.config,
                        icon: Icon(icon),
                        onPressed: () async {
                          final bool success = widget._isCalendar
                              ? await createCalendarEvent(eventCon.text)
                              : await createTask(eventCon.text, widget._shareDest);

                          eventCon.clear();
                          removeOverlay();

                          if (!success && context.mounted) await selfDestruct();
                        },
                        onLongPress: () => canToggleMenu(widget.config, controller),
                      ),
                    ],
                  ),
            menuChildren: _menuChildren(
              widget.config,
              appInfo: widget.appInfo,
              context: context,
              state: state,
              numLanes: numLanes,
              pos: widget.pos,
              initConfig: _EventConfig(
                size: widget._size,
                isCalendar: widget._isCalendar,
                shareDest: widget._shareDest,
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
                size: widget._size,
                isCalendar: widget._isCalendar,
                shareDest: widget._shareDest,
              ),
            ),
            child: EzIconButton(
              widget.config,
              icon: Icon(icon),
              onPressed: () => toggleMenu(menuControl),
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
        label: 'Duplicate',
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
  final WidgetSize size;

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
        type: WidWidGetGet.event,
        editNew: () => _openEdits(
          config,
          appInfo: appInfo,
          pContext: pContext,
          initConfig: _EventConfig(
            size: size,
            isCalendar: true,
            shareDest: null,
          ),
          lane: lane,
          index: appInfo.homeLane(config, lane).length - 1,
        ),
        lane: lane,
      );

  @override
  Widget build(BuildContext context) => (size == WidgetSize.button)
      ? EzIconButton(config, onPressed: onTap, icon: const Icon(Icons.edit_calendar))
      : GestureDetector(
          onTap: onTap,
          child: EzRow(
            config,
            children: <Widget>[
              EzTextField(
                constraints: BoxConstraints(
                  maxHeight: appIconSize(config),
                  maxWidth:
                      ezTextSize('Create event', context: context, style: config.bodyStyle).width +
                          config.padding,
                ),
                hintText: 'New event',
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

String defaultEventEntry() => _eventEntry(WidgetSize.tile, true, null);

String _eventEntry(WidgetSize size, bool isCalendar, AppInfo? shareDest) => <String>[
      size.value,
      isCalendar.toString(),
      shareDest?.id ?? 'null',
    ].join(configSplit);

//* Edit Widget *//

class _EventConfig {
  final WidgetSize size;
  final bool isCalendar;
  final AppInfo? shareDest;

  _EventConfig({
    required this.size,
    required this.isCalendar,
    required this.shareDest,
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
  final EdgeInsets wrapPadding = EzInsets.wrap(config.spacing);

  WidgetSize size = initConfig.size;
  bool isCalendar = initConfig.isCalendar;
  AppInfo shareDest = initConfig.shareDest ?? nullApp;

  await ezModal(
    config,
    context: pContext,
    builder: (_) => StatefulBuilder(
      builder: (_, StateSetter setModal) => ezModalScroll(config, children: <Widget>[
        // Size  && Type //

        EzWrap(children: <Widget>[
          // Size
          Padding(
            padding: wrapPadding,
            child: SegmentedButton<WidgetSize>(
              segments: const <ButtonSegment<WidgetSize>>[
                ButtonSegment<WidgetSize>(
                  value: WidgetSize.button,
                  label: Text('Button', textAlign: TextAlign.center),
                ),
                ButtonSegment<WidgetSize>(
                  value: WidgetSize.tile,
                  label: Text('Tile', textAlign: TextAlign.center),
                ),
              ],
              selected: <WidgetSize>{size},
              showSelectedIcon: false,
              onSelectionChanged: (Set<WidgetSize> selected) =>
                  setModal(() => size = selected.first),
            ),
          ),

          // Type
          Padding(
            padding: wrapPadding,
            child: SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Calendar', textAlign: TextAlign.center),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Task', textAlign: TextAlign.center),
                ),
              ],
              selected: <bool>{isCalendar},
              showSelectedIcon: false,
              onSelectionChanged: (Set<bool> selected) =>
                  setModal(() => isCalendar = selected.first),
            ),
          ),
        ]),
        config.spacer,

        // Share Dest //

        Text(
          """'Task' is just share underneath. Choose a destination app below.
We recommend using a task app, but it's not required.
Results may vary.
""",
          textAlign: TextAlign.center,
          style: config.bodyStyle,
        ),

        AppButton(
          config,
          name: shareDest.label,
          image: shareDest.icon,
          icon: null,
          labelType: listLabels(config),
          buttonType: listBT(config),
          onPressed: () => pContext.pushNamed(
            appListPath,
            extra: ListConfig(
              listContent: <ListContent>{ListContent.banished},
              include: false,
              onSelected: (AppInfo choice) async {
                if (pContext.mounted) Navigator.of(pContext).pop();
                setModal(() => shareDest = choice);
              },
              title: EzTextButton(
                config,
                onPressed: doNothing,
                text: 'Selecting share destination',
                textStyle: config.labelStyle,
              ),
            ),
          ),
          onLongPress: () => setModal(() => shareDest = nullApp),
        ),
        config.margin,
        Text(
          'Long press to reset',
          textAlign: TextAlign.center,
          style: config.labelStyle,
        ),
        config.separator,
      ]),
    ),
  );

  await appInfo.updateWidget(
    config,
    WidWidGetGet.event,
    _eventEntry(size, isCalendar, shareDest == nullApp ? null : shareDest),
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
        label: 'Edit',
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
