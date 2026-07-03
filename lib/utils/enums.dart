/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// App Location //

enum AppLocation { home, folder, list }

// App Sort //

enum AppSort { name, publisher, date, size }

const String esName = 'name';
const String esPublisher = 'publisher';
const String esDate = 'date';
const String esSize = 'size';

extension ASConfig on AppSort {
  String get value => switch (this) {
        AppSort.name => esName,
        AppSort.publisher => esPublisher,
        AppSort.date => esDate,
        AppSort.size => esSize,
      };

  static AppSort lookup(String value) => switch (value) {
        esPublisher => AppSort.publisher,
        esDate => AppSort.date,
        esSize => AppSort.size,
        esName || _ => AppSort.name,
      };
}

// App State //

enum AppState { standard, groupEdit, verbose }

// Button Type //

enum ButtonType { icon, eIcon, text, eText, textIcon, eTextIcon }

const Set<ButtonType> elevatedBTs = <ButtonType>{
  ButtonType.eIcon,
  ButtonType.eText,
  ButtonType.eTextIcon,
};

const Set<ButtonType> iconBTs = <ButtonType>{
  ButtonType.icon,
  ButtonType.eIcon,
  ButtonType.textIcon,
  ButtonType.eTextIcon,
};

const String esIcon = 'iconButton';
const String esEIcon = 'elevatedIconButton';
const String esText = 'textButton';
const String esEText = 'elevatedTextButton';
const String esTextIcon = 'textIconButton';
const String esETextIcon = 'elevatedTextIconButton';

extension BTConfig on ButtonType {
  String get value => switch (this) {
        ButtonType.icon => esIcon,
        ButtonType.eIcon => esEIcon,
        ButtonType.text => esText,
        ButtonType.eText => esEText,
        ButtonType.textIcon => esTextIcon,
        ButtonType.eTextIcon => esETextIcon,
      };

  static ButtonType build(LabelType label, {required bool icons, required bool elevated}) =>
      label == LabelType.none
          ? elevated
              ? ButtonType.eIcon
              : ButtonType.icon
          : icons
              ? elevated
                  ? ButtonType.eTextIcon
                  : ButtonType.textIcon
              : elevated
                  ? ButtonType.eText
                  : ButtonType.text;

  static ButtonType? lookup(String? value) => switch (value) {
        esIcon => ButtonType.icon,
        esEIcon => ButtonType.eIcon,
        esText => ButtonType.text,
        esEText => ButtonType.eText,
        esTextIcon => ButtonType.textIcon,
        esETextIcon => ButtonType.eTextIcon,
        _ => null,
      };

  static ButtonType safeLookup(String? value) => switch (value) {
        esIcon => ButtonType.icon,
        esEIcon => ButtonType.eIcon,
        esText => ButtonType.text,
        esEText => ButtonType.eText,
        esTextIcon => ButtonType.textIcon,
        esETextIcon => ButtonType.eTextIcon,
        _ => ButtonType.textIcon,
      };
}

// Date Type //

enum DateType { none, compact, short, medium, long }

const String esCompact = 'compact';
const String esShort = 'short';
const String esMedium = 'medium';
const String esLong = 'long';

extension DTConfig on DateType {
  String get value => switch (this) {
        DateType.none => esNone,
        DateType.compact => esCompact,
        DateType.short => esShort,
        DateType.medium => esMedium,
        DateType.long => esLong,
      };

  static String buildDate(BuildContext context, DateTime time, DateType type) => switch (type) {
        DateType.compact => MaterialLocalizations.of(context).formatCompactDate(time),
        DateType.short => MaterialLocalizations.of(context).formatShortDate(time),
        DateType.medium => MaterialLocalizations.of(context).formatMediumDate(time),
        DateType.long => MaterialLocalizations.of(context).formatFullDate(time),
        DateType.none || _ => '---',
      };

  static DateType lookup(String value) => switch (value) {
        esCompact => DateType.compact,
        esShort => DateType.short,
        esMedium => DateType.medium,
        esLong => DateType.long,
        esNone || _ => DateType.none,
      };
}

// Label Type //

enum LabelType { none, initials, full, wingding }

const String esInitials = 'initials';
const String esFull = 'full';
const String esWingding = 'wingding';

extension LTConfig on LabelType {
  String get value => switch (this) {
        LabelType.none => esNone,
        LabelType.initials => esInitials,
        LabelType.full => esFull,
        LabelType.wingding => esWingding,
      };

  static LabelType? lookup(String? value) => switch (value) {
        esNone => LabelType.none,
        esInitials => LabelType.initials,
        esFull => LabelType.full,
        esWingding => LabelType.wingding,
        _ => null,
      };

  static LabelType safeLookup(String? value) => switch (value) {
        esNone => LabelType.none,
        esInitials => LabelType.initials,
        esFull => LabelType.full,
        esWingding => LabelType.wingding,
        _ => LabelType.full,
      };
}

/// Get the result of [base] parsed with [type]
String buildLabel(String base, LabelType type) => switch (type) {
      LabelType.none => '',
      LabelType.initials =>
        base.split(' ').map((String word) => word.isNotEmpty ? word[0] : '').join().toUpperCase(),
      LabelType.full => base,
      LabelType.wingding => base.split('').map((String char) => wingdingMap[char] ?? char).join(),
    };

// List Alignment //

enum ListAlignment { center, start, end }

const String esCenter = 'center';
const String esStart = 'start';
const String esEnd = 'end';

extension LAConfig on ListAlignment {
  String get value => switch (this) {
        ListAlignment.center => esCenter,
        ListAlignment.start => esStart,
        ListAlignment.end => esEnd,
      };

  MainAxisAlignment get mainAxis => switch (this) {
        ListAlignment.center => MainAxisAlignment.center,
        ListAlignment.start => MainAxisAlignment.start,
        ListAlignment.end => MainAxisAlignment.end,
      };

  CrossAxisAlignment get crossAxis => switch (this) {
        ListAlignment.center => CrossAxisAlignment.center,
        ListAlignment.start => CrossAxisAlignment.start,
        ListAlignment.end => CrossAxisAlignment.end,
      };

  TextAlign get textAlign => switch (this) {
        ListAlignment.center => TextAlign.center,
        ListAlignment.start => TextAlign.start,
        ListAlignment.end => TextAlign.end,
      };

  static ListAlignment lookup(String value) => switch (value) {
        esStart => ListAlignment.start,
        esEnd => ListAlignment.end,
        esCenter || _ => ListAlignment.center,
      };

  static Alignment merge({required ListAlignment h, required ListAlignment v}) => switch (h) {
        ListAlignment.start => switch (v) {
            ListAlignment.start => Alignment.topLeft,
            ListAlignment.center => Alignment.centerLeft,
            ListAlignment.end => Alignment.bottomLeft,
          },
        ListAlignment.center => switch (v) {
            ListAlignment.start => Alignment.topCenter,
            ListAlignment.center => Alignment.center,
            ListAlignment.end => Alignment.bottomCenter,
          },
        ListAlignment.end => switch (v) {
            ListAlignment.start => Alignment.topRight,
            ListAlignment.center => Alignment.centerRight,
            ListAlignment.end => Alignment.bottomRight,
          },
      };
}

// List Content //

enum ListContent { hidden, banished }

// Tile Config //

enum TileConfig {
  app,
  folder,
  spacer,

  // Widgets
  calendar,
  clock,
  search,
  timer,
  toggleMedia,
}

/// Tile Config Config
extension TCC on TileConfig {
  static String appEntry(
          String name, IconData? icon, ButtonType? buttonType, LabelType? labelType) =>
      <String>[
        name,
        (icon == null ? esSystem : icon.codePoint.toString()),
        (buttonType == null ? esSystem : buttonType.value),
        (labelType == null ? esSystem : labelType.value),
      ].join(configSplit);

  static String folderEntry(IconData icon, ButtonType? buttonType, LabelType? labelType) =>
      <String>[
        icon.codePoint.toString(),
        (buttonType == null ? esSystem : buttonType.value),
        (labelType == null ? esSystem : labelType.value),
      ].join(configSplit);

  static String calendarEntry(WidgetSize size) => <String>[
        size.value,
      ].join(configSplit);

  static String clockEntry(EzButtonShape? shape, Color? background, bool time, TxtStile timeStyle,
          Color? timeColor, DateType date, TxtStile dateStyle, Color? dateColor) =>
      <String>[
        shape == null ? esSystem : shape.value,
        background == null ? esSystem : background.toARGB32().toString(),
        time.toString(),
        timeStyle.value,
        timeColor == null ? esSystem : timeColor.toARGB32().toString(),
        date.value,
        dateStyle.value,
        dateColor == null ? esSystem : dateColor.toARGB32().toString(),
      ].join(configSplit);

  static String searchEntry(WidgetSize size, Engine engine, Iterable<String> choices) =>
      <String>[size.value, engine.value, choices.join(engineSplit)].join(configSplit);

  static String timerEntry(WidgetSize size, String autoTime) => <String>[
        size.value,
        autoTime,
      ].join(configSplit);

  static String mediaEntry(WidgetSize size) => <String>[
        size.value,
      ].join(configSplit);
}

// Text Style //

enum TxtStile { display, headline, title, body, label }

const String _display = 'display';
const String _headline = 'headline';
const String _title = 'title';
const String _body = 'body';
const String _label = 'label';

extension TSConfig on TxtStile {
  String get value => switch (this) {
        TxtStile.display => _display,
        TxtStile.headline => _headline,
        TxtStile.title => _title,
        TxtStile.body => _body,
        TxtStile.label => _label,
      };

  TextStyle? style(EzCP config) => switch (this) {
        TxtStile.display => config.displayStyle,
        TxtStile.headline => config.headlineStyle,
        TxtStile.title => config.titleStyle,
        TxtStile.body => config.bodyStyle,
        TxtStile.label => config.labelStyle,
      };

  static TxtStile? lookup(String value) => switch (value) {
        _display => TxtStile.display,
        _headline => TxtStile.headline,
        _title => TxtStile.title,
        _body => TxtStile.body,
        _label => TxtStile.label,
        _ => null,
      };
}

// Widget-ception //

enum WidWidGetGet { calendar, clock, search, timer, toggleMedia }

const String esCalendar = 'calendar';
const String esClock = 'clock';
const String esSearch = 'search';
const String esTimer = 'timer';
const String esToggleMedia = 'toggleMedia';

extension WWGGConfig on WidWidGetGet {
  String get value => switch (this) {
        WidWidGetGet.calendar => esCalendar,
        WidWidGetGet.clock => esClock,
        WidWidGetGet.search => esSearch,
        WidWidGetGet.timer => esTimer,
        WidWidGetGet.toggleMedia => esToggleMedia,
      };
}

enum WidgetSize { system, button, tile }

const String esButton = 'button';
const String esTile = 'tile';

extension WSConfig on WidgetSize {
  String get value => switch (this) {
        WidgetSize.system => esSystem,
        WidgetSize.button => esButton,
        WidgetSize.tile => esTile,
      };

  static WidgetSize lookup(String? value) => switch (value) {
        esButton => WidgetSize.button,
        esTile => WidgetSize.tile,
        esSystem || _ => WidgetSize.system,
      };
}
