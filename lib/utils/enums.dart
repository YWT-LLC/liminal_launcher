/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import 'package:flutter/material.dart';

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

const String _name = 'name';
const String _publisher = 'publisher';
const String _date = 'date';
const String _size = 'size';

extension AppSortConfig on AppSort {
  String get configValue {
    switch (this) {
      case AppSort.name:
        return _name;
      case AppSort.publisher:
        return _publisher;
      case AppSort.date:
        return _date;
      case AppSort.size:
        return _size;
    }
  }

  static AppSort fromValue(String value) {
    switch (value) {
      case _publisher:
        return AppSort.publisher;
      case _date:
        return AppSort.date;
      case _size:
        return AppSort.size;
      default:
        return AppSort.name;
    }
  }
}

//* Layout settings *//

// App List Alignment //

enum ListAlignment { center, start, end }

const String _center = 'center';
const String _start = 'start';
const String _end = 'end';

extension ListAlignmentConfig on ListAlignment {
  String get configValue {
    switch (this) {
      case ListAlignment.center:
        return _center;
      case ListAlignment.start:
        return _start;
      case ListAlignment.end:
        return _end;
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
      case _start:
        return ListAlignment.start;
      case _end:
        return ListAlignment.end;
      default:
        return ListAlignment.center;
    }
  }
}

//* Design settings *//

// App/Folder Label Type //

enum LabelType { none, initials, full, wingding }

const String _none = 'none';
const String _initials = 'initials';
const String _full = 'full';

extension LabelTypeConfig on LabelType {
  String get configValue {
    switch (this) {
      case LabelType.none:
        return _none;
      case LabelType.initials:
        return _initials;
      case LabelType.full:
        return _full;
      case LabelType.wingding:
        return wingding;
    }
  }

  static LabelType fromValue(String value) {
    switch (value) {
      case _none:
        return LabelType.none;
      case _initials:
        return LabelType.initials;
      case wingding:
        return LabelType.wingding;
      default:
        return LabelType.full;
    }
  }
}
