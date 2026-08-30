import 'package:intl/intl.dart';

/// Money Management uses the Bangladeshi Taka (৳) throughout the Figma file.
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currency = NumberFormat.decimalPattern('en_US');

  static String currency(num amount, {bool showSign = false}) {
    final sign = amount < 0 ? '-' : (showSign ? '+' : '');
    final formatted = _currency.format(amount.abs());
    return '$sign৳$formatted';
  }

  static String currencyCompact(num amount) {
    return NumberFormat.compactCurrency(symbol: '৳').format(amount);
  }

  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

  static String monthDay(DateTime date) => DateFormat('d MMM').format(date);

  static String weekday(DateTime date) => DateFormat('E').format(date);

  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('d MMM').format(date);
  }
}
