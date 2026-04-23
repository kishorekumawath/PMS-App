import 'package:intl/intl.dart';

class DateFormatter {
  static final _display = DateFormat('dd MMM yyyy');
  static final _displayShort = DateFormat('dd MMM');

  static String format(DateTime date) => _display.format(date);
  static String formatShort(DateTime date) => _displayShort.format(date);

  static String? formatNullable(DateTime? date) =>
      date == null ? null : _display.format(date);
}
