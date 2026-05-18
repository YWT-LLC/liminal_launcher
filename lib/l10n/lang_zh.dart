// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LangZh extends Lang {
  LangZh([String locale = 'zh']) : super(locale);

  @override
  String get hsCaw => 'Caw!';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class LangZhCn extends LangZh {
  LangZhCn() : super('zh_CN');

  @override
  String get hsCaw => 'Caw!';
}
