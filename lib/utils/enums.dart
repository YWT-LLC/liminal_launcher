/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

//* BTS *//

enum AppLocation { home, folder, list }

enum AppSort { name, publisher, date, size }

/// enum [String] 'name'
const String esName = 'name';

/// enum [String] 'publisher'
const String esPublisher = 'publisher';

/// enum [String] 'date'
const String esDate = 'date';

/// enum [String] 'size'
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

enum AppState { standard, singleEdit, groupEdit, verbose }

extension StateName on AppState {
  String get name => switch (this) {
        AppState.standard => 'standard',
        AppState.singleEdit => 'singleEdit',
        AppState.groupEdit => 'groupEdit',
        AppState.verbose => 'verbose',
      };
}

enum ListContent { home, hidden, banished }

enum WidWidGetGet { calendar, clock, search, timer, toggleMedia }

/// enum [String] 'calendar'
const String esCalendar = 'calendar';

/// enum [String] 'clock'
const String esClock = 'clock';

/// enum [String] 'search'
const String esSearch = 'search';

/// enum [String] 'timer'
const String esTimer = 'timer';

/// enum [String] 'toggleMedia'
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

/// enum [String] 'button'
const String esButton = 'button';

/// enum [String] 'tile'
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

//* Design settings (button) *//

// Label //

enum LabelType { none, initials, full, wingding }

/// enum [String] 'initials'
const String esInitials = 'initials';

/// enum [String] 'full'
const String esFull = 'full';

/// enum [String] wingding
const String esWingding = 'wingding';

extension LTConfig on LabelType {
  String get value => switch (this) {
        LabelType.none => esNone,
        LabelType.initials => esInitials,
        LabelType.full => esFull,
        LabelType.wingding => esWingding,
      };

  static LabelType lookup(String value) => switch (value) {
        esNone => LabelType.none,
        esInitials => LabelType.initials,
        esWingding => LabelType.wingding,
        esFull || _ => LabelType.full,
      };
}

const List<DropdownMenuEntry<LabelType>> labelEntries = <DropdownMenuEntry<LabelType>>[
  DropdownMenuEntry<LabelType>(value: LabelType.none, label: 'None'),
  DropdownMenuEntry<LabelType>(value: LabelType.initials, label: 'Initials'),
  DropdownMenuEntry<LabelType>(value: LabelType.full, label: 'Full name'),
  DropdownMenuEntry<LabelType>(value: LabelType.wingding, label: 'Wingding'),
];

/// Get the result of [base] parsed with [type]
String buildLabel(String base, LabelType type) => switch (type) {
      LabelType.none => '',
      LabelType.initials =>
        base.split(' ').map((String word) => word.isNotEmpty ? word[0] : '').join().toUpperCase(),
      LabelType.full => base,
      LabelType.wingding => base.split('').map((String char) => wingdingMap[char] ?? char).join(),
    };

// Type //

enum ButtonType { icon, eIcon, text, eText, textIcon, eTextIcon }

extension BTConfig on ButtonType {
  static ButtonType build(
    LabelType label, {
    required bool icons,
    required bool elevated,
  }) =>
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
}

//* Design (page) *//

// Date //

enum DateType { none, compact, short, medium, long }

/// enum [String] 'compact'
const String esCompact = 'compact';

/// enum [String] 'short'
const String esShort = 'short';

/// enum [String] 'medium'
const String esMedium = 'medium';

/// enum [String] 'long'
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

// Alignment //

enum ListAlignment { center, start, end }

/// enum [String] 'center'
const String esCenter = 'center';

/// enum [String] 'start'
const String esStart = 'start';

/// enum [String] 'end'
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

const Set<ListAlignment> topAlign = <ListAlignment>{
  ListAlignment.start,
  ListAlignment.center,
};

//* Widgets *//

enum Engine {
  archive,
  baidu,
  bing,
  ducks,
  ecosia,
  google,
  naver,
  qwant,
  wikipedia,
  wolframAlpha,
  yahoo,
  yandex,
  youTube,
}

const String _archive = 'archive';
const String _baidu = 'baidu';
const String _bing = 'bing';
const String _ducks = 'ducks';
const String _ecosia = 'ecosia';
const String _google = 'google';
const String _naver = 'naver';
const String _qwant = 'qwant';
const String _wikipedia = 'wikipedia';
const String _wolframAlpha = 'wolframAlpha';
const String _yahoo = 'yahoo';
const String _yandex = 'yandex';
const String _youTube = 'youTube';

extension Ignition on Engine {
  String get value => switch (this) {
        Engine.archive => _archive,
        Engine.baidu => _baidu,
        Engine.bing => _bing,
        Engine.ducks => _ducks,
        Engine.ecosia => _ecosia,
        Engine.google => _google,
        Engine.naver => _naver,
        Engine.qwant => _qwant,
        Engine.wikipedia => _wikipedia,
        Engine.wolframAlpha => _wolframAlpha,
        Engine.yahoo => _yahoo,
        Engine.yandex => _yandex,
        Engine.youTube => _youTube,
      };

  String get base => switch (this) {
        Engine.archive => 'archive.org',
        Engine.baidu => 'baidu.com',
        Engine.bing => 'bing.com',
        Engine.ducks => 'duckduckgo.com',
        Engine.ecosia => 'ecosia.org',
        Engine.google => 'google.com',
        Engine.naver => 'search.naver.com',
        Engine.qwant => 'qwant.com',
        Engine.wikipedia => 'wikipedia.org',
        Engine.wolframAlpha => 'wolframalpha.com',
        Engine.yahoo => 'search.yahoo.com',
        Engine.yandex => 'yandex.com',
        Engine.youTube => 'youtube.com',
      };

  String get path => switch (this) {
        Engine.archive => '/search',
        Engine.baidu => '/s',
        Engine.bing => '/search',
        Engine.ducks => '/',
        Engine.ecosia => '/search',
        Engine.google => '/search',
        Engine.naver => '/search.naver',
        Engine.qwant => '/',
        Engine.wikipedia => '/w/index.php',
        Engine.wolframAlpha => '/input',
        Engine.yahoo => '/search',
        Engine.yandex => '/search/',
        Engine.youTube => '/results',
      };

  String get query => switch (this) {
        Engine.archive => 'query',
        Engine.baidu => 'wd',
        Engine.bing => 'q',
        Engine.ducks => 'q',
        Engine.ecosia => 'q',
        Engine.google => 'q',
        Engine.naver => 'query',
        Engine.qwant => 'q',
        Engine.wikipedia => 'search',
        Engine.wolframAlpha => 'i',
        Engine.yahoo => 'p',
        Engine.yandex => 'text',
        Engine.youTube => 'search_query',
      };

  static Engine lookup(String value) => switch (value) {
        _archive => Engine.archive,
        _baidu => Engine.baidu,
        _bing => Engine.bing,
        _ecosia => Engine.ecosia,
        _google => Engine.google,
        _naver => Engine.naver,
        _qwant => Engine.qwant,
        _wikipedia => Engine.wikipedia,
        _wolframAlpha => Engine.wolframAlpha,
        _yahoo => Engine.yahoo,
        _yandex => Engine.yandex,
        _youTube => Engine.youTube,
        _ducks || _ => Engine.ducks,
      };
}

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
