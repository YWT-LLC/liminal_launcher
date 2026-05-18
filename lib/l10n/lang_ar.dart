// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LangAr extends Lang {
  LangAr([String locale = 'ar']) : super(locale);

  @override
  String get hsCaw => 'Caw!';
}

/// The translations for Arabic, as used in Egypt (`ar_EG`).
class LangArEg extends LangAr {
  LangArEg() : super('ar_EG');

  @override
  String get hsCaw => 'Caw!';
}
