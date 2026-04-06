/* liminal_launcher
 * Copyright (c) 2026 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

import './export.dart';
import 'package:flutter/material.dart';

//* Shared consts *//

/// Tracks the position of the last ripple LongPress
/// Defaults to [Offset.zero]
Offset lastRipple = Offset.zero;

/// enum String 'full'
const String esFull = 'full';

/// enum String 'center'
const String esCenter = 'center';

/// enum String 'start'
const String esStart = 'start';

/// enum String 'end'
const String esEnd = 'end';

//* BTS settings *//

// AppListScreen Data //

enum ListData {
  listCheck,
  onSelected,
  refresh,
  autoRefresh,
  editable,
  icon,
}

extension ListDataConfig on ListData {
  String get key {
    switch (this) {
      case ListData.listCheck:
        return 'listCheck';
      case ListData.onSelected:
        return 'onSelected';
      case ListData.refresh:
        return 'refresh';
      case ListData.autoRefresh:
        return 'autoRefresh';
      case ListData.editable:
        return 'editable';
      case ListData.icon:
        return 'icon';
    }
  }
}

// AppList Sort //

enum AppSort { name, publisher, date, size }

/// enum String 'name'
const String esName = 'name';

/// enum String 'publisher'
const String esPublisher = 'publisher';

/// enum String 'date'
const String esDate = 'date';

/// enum String 'size'
const String esSize = 'size';

extension AppSortConfig on AppSort {
  String get configValue {
    switch (this) {
      case AppSort.name:
        return esName;
      case AppSort.publisher:
        return esPublisher;
      case AppSort.date:
        return esDate;
      case AppSort.size:
        return esSize;
    }
  }

  static AppSort fromValue(String value) {
    switch (value) {
      case esPublisher:
        return AppSort.publisher;
      case esDate:
        return AppSort.date;
      case esSize:
        return AppSort.size;
      default:
        return AppSort.name;
    }
  }
}

//* Design settings *//

// Date type //

enum DateType { none, compact, short, medium, long }

/// enum String 'compact'
const String esCompact = 'compact';

/// enum String 'short'
const String esShort = 'short';

/// enum String 'medium'
const String esMedium = 'medium';

/// enum String 'long'
const String esLong = 'long';

extension DateTypeConfig on DateType {
  String get configValue {
    switch (this) {
      case DateType.none:
        return esNone;
      case DateType.compact:
        return esCompact;
      case DateType.short:
        return esShort;
      case DateType.medium:
        return esMedium;
      case DateType.long:
        return esLong;
    }
  }

  static String buildDate(DateType type, BuildContext context, DateTime now) {
    switch (type) {
      case DateType.compact:
        return MaterialLocalizations.of(context).formatCompactDate(now);
      case DateType.short:
        return MaterialLocalizations.of(context).formatShortDate(now);
      case DateType.medium:
        return MaterialLocalizations.of(context).formatMediumDate(now);
      case DateType.long:
        return MaterialLocalizations.of(context).formatFullDate(now);
      default:
        return '---';
    }
  }

  static DateType fromValue(String value) {
    switch (value) {
      case esCompact:
        return DateType.compact;
      case esShort:
        return DateType.short;
      case esMedium:
        return DateType.medium;
      case esLong:
        return DateType.long;
      default:
        return DateType.none;
    }
  }
}

// App/Folder Label Type //

enum LabelType { none, initials, full, wingding }

/// enum String 'initials'
const String esInitials = 'initials';

extension LabelTypeConfig on LabelType {
  String get configValue {
    switch (this) {
      case LabelType.none:
        return esNone;
      case LabelType.initials:
        return esInitials;
      case LabelType.full:
        return esFull;
      case LabelType.wingding:
        return wingding;
    }
  }

  static LabelType fromValue(String value) {
    switch (value) {
      case esNone:
        return LabelType.none;
      case esInitials:
        return LabelType.initials;
      case wingding:
        return LabelType.wingding;
      default:
        return LabelType.full;
    }
  }
}

//* Layout settings *//

// App List Alignment //

enum ListAlignment { center, start, end }

extension ListAlignmentConfig on ListAlignment {
  String get configValue {
    switch (this) {
      case ListAlignment.center:
        return esCenter;
      case ListAlignment.start:
        return esStart;
      case ListAlignment.end:
        return esEnd;
    }
  }

  Alignment get alignment {
    switch (this) {
      case ListAlignment.center:
        return Alignment.center;
      case ListAlignment.start:
        return Alignment.centerLeft;
      case ListAlignment.end:
        return Alignment.centerRight;
    }
  }

  MainAxisAlignment get mainAxis {
    switch (this) {
      case ListAlignment.center:
        return MainAxisAlignment.center;
      case ListAlignment.start:
        return MainAxisAlignment.start;
      case ListAlignment.end:
        return MainAxisAlignment.end;
    }
  }

  CrossAxisAlignment get crossAxis {
    switch (this) {
      case ListAlignment.center:
        return CrossAxisAlignment.center;
      case ListAlignment.start:
        return CrossAxisAlignment.start;
      case ListAlignment.end:
        return CrossAxisAlignment.end;
    }
  }

  TextAlign get textAlign {
    switch (this) {
      case ListAlignment.center:
        return TextAlign.center;
      case ListAlignment.start:
        return TextAlign.start;
      case ListAlignment.end:
        return TextAlign.end;
    }
  }

  static ListAlignment fromValue(String value) {
    switch (value) {
      case esStart:
        return ListAlignment.start;
      case esEnd:
        return ListAlignment.end;
      default:
        return ListAlignment.center;
    }
  }
}
