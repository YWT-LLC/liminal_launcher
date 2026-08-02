/* liminal_launcher
 * Copyright (c) 2026 YWT (Empathetech LLC). All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:open_ui/open_ui.dart';
import 'package:flutter/material.dart';

// App Location //

enum AppLocation { home, folder, list }

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

  /// Defaults to [ButtonType.textIcon]
  static ButtonType safeLookup(String? value) => switch (value) {
        esIcon => ButtonType.icon,
        esEIcon => ButtonType.eIcon,
        esText => ButtonType.text,
        esEText => ButtonType.eText,
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

  String name(EzCP config) => switch (this) {
        DateType.none => config.ezL10n.dsNone,
        DateType.compact => l10n(config).edtCompact,
        DateType.short => l10n(config).edtShort,
        DateType.medium => l10n(config).edtMedium,
        DateType.long => l10n(config).edtLong,
      };

  static String buildDate(BuildContext context, DateTime time, DateType type) => switch (type) {
        DateType.compact => MaterialLocalizations.of(context).formatCompactDate(time),
        DateType.short => MaterialLocalizations.of(context).formatShortDate(time),
        DateType.medium => MaterialLocalizations.of(context).formatMediumDate(time),
        DateType.long => MaterialLocalizations.of(context).formatFullDate(time),
        _ => '---',
      };

  static DateType? lookup(String? value) => switch (value) {
        esNone => DateType.none,
        esCompact => DateType.compact,
        esShort => DateType.short,
        esMedium => DateType.medium,
        esLong => DateType.long,
        _ => null,
      };

  /// Defaults to [DateType.none]
  static DateType safeLookup(String? value) => switch (value) {
        esCompact => DateType.compact,
        esShort => DateType.short,
        esMedium => DateType.medium,
        esLong => DateType.long,
        _ => DateType.none,
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

  String name(EzCP config) => switch (this) {
        LabelType.none => config.ezL10n.dsNone,
        LabelType.initials => l10n(config).eltInitials,
        LabelType.full => l10n(config).eltFull,
        LabelType.wingding => l10n(config).eltWingding,
      };

  static LabelType? lookup(String? value) => switch (value) {
        esNone => LabelType.none,
        esInitials => LabelType.initials,
        esFull => LabelType.full,
        esWingding => LabelType.wingding,
        _ => null,
      };

  /// Defaults to [LabelType.full]
  static LabelType safeLookup(String? value) => switch (value) {
        esNone => LabelType.none,
        esInitials => LabelType.initials,
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

  String name(EzCP config) => switch (this) {
        ListAlignment.center => l10n(config).elaCenter,
        ListAlignment.start => l10n(config).elaStart,
        ListAlignment.end => l10n(config).elaEnd,
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

  static ListAlignment? lookup(String? value) => switch (value) {
        esStart => ListAlignment.start,
        esEnd => ListAlignment.end,
        esCenter => ListAlignment.center,
        _ => null,
      };

  static ListAlignment buildLookup(String laneEntry, Axis axis, EzCP config) {
    final List<String> parts = laneEntry.split(configSplit);

    return axis == Axis.horizontal
        ? LAConfig.lookup(parts[0]) ?? horizontalAlign(config)
        : LAConfig.lookup(parts[1]) ?? verticalAlign(config);
  }

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

// List Sort //

enum ListSort { name, publisher, date, size }

const String esName = 'name';
const String esPublisher = 'publisher';
const String esDate = 'date';
const String esSize = 'size';

extension LSConfig on ListSort {
  String get value => switch (this) {
        ListSort.name => esName,
        ListSort.publisher => esPublisher,
        ListSort.date => esDate,
        ListSort.size => esSize,
      };

  String name(EzCP config) => switch (this) {
        ListSort.name => l10n(config).elsName,
        ListSort.publisher => l10n(config).elsPublisher,
        ListSort.date => l10n(config).elsDate,
        ListSort.size => l10n(config).elsSize,
      };

  static List<ListSort> verbOrder(ListSort verbStart) => switch (verbStart) {
        ListSort.name => <ListSort>[
            ListSort.name,
            ListSort.publisher,
            ListSort.date,
            ListSort.size,
          ],
        ListSort.publisher => <ListSort>[
            ListSort.publisher,
            ListSort.date,
            ListSort.size,
            ListSort.name,
          ],
        ListSort.date => <ListSort>[
            ListSort.date,
            ListSort.size,
            ListSort.name,
            ListSort.publisher,
          ],
        ListSort.size => <ListSort>[
            ListSort.size,
            ListSort.name,
            ListSort.publisher,
            ListSort.date,
          ],
      };

  static ListSort? lookup(String? value) => switch (value) {
        esName => ListSort.name,
        esPublisher => ListSort.publisher,
        esDate => ListSort.date,
        esSize => ListSort.size,
        _ => null,
      };

  /// Defaults to [ListSort.name]
  static ListSort safeLookup(String? value) => switch (value) {
        esPublisher => ListSort.publisher,
        esDate => ListSort.date,
        esSize => ListSort.size,
        _ => ListSort.name,
      };
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

  String name(EzCP config) => switch (this) {
        TxtStile.display => config.ezL10n.tsDisplay,
        TxtStile.headline => config.ezL10n.tsHeadline,
        TxtStile.title => config.ezL10n.tsTitle,
        TxtStile.body => config.ezL10n.tsBody,
        TxtStile.label => config.ezL10n.tsLabel,
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

// Tile state //

enum TileState { standard, groupEdit, verbose }

// Widget-ception //

enum WidWidGetGet { clock, event, search, timer, toggleMedia, themeMode }

const String esClock = 'clock';
const String esEvent = 'event';
const String esSearch = 'search';
const String esTimer = 'timer';
const String esToggleMedia = 'toggleMedia';
const String esThemeMode = 'themeMode';

extension WWGGConfig on WidWidGetGet {
  String get value => switch (this) {
        WidWidGetGet.clock => esClock,
        WidWidGetGet.event => esEvent,
        WidWidGetGet.search => esSearch,
        WidWidGetGet.timer => esTimer,
        WidWidGetGet.toggleMedia => esToggleMedia,
        WidWidGetGet.themeMode => esThemeMode,
      };
}

enum WidgetSize { button, tile }

const String esButton = 'button';
const String esTile = 'tile';

extension WSConfig on WidgetSize {
  String get value => switch (this) {
        WidgetSize.button => esButton,
        WidgetSize.tile => esTile,
      };

  static WidgetSize? lookup(String? value) => switch (value) {
        esButton => WidgetSize.button,
        esTile => WidgetSize.tile,
        _ => null,
      };

  /// Defaults to [WidgetSize.tile]
  static WidgetSize safeLookup(String? value) => switch (value) {
        esButton => WidgetSize.button,
        _ => WidgetSize.tile,
      };
}
