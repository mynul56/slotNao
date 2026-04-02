import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toDisplayDate() => DateFormat('dd MMM yyyy').format(this);
  String toDisplayTime() => DateFormat('hh:mm a').format(this);
  String toDisplayDateTime() => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  String toApiDate() => DateFormat('yyyy-MM-dd').format(this);
  String toApiDateTime() => toIso8601String();
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
}

extension StringExtensions on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidBangladeshPhone {
    return RegExp(r'^(?:\+8801|01)[3-9]\d{8}$').hasMatch(this);
  }

  bool get isValidPassword => length >= 8;

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(' ')
        .map((word) => word.isEmpty ? '' : word.capitalized)
        .join(' ');
  }

  String toBdCurrency() {
    final amount = double.tryParse(this) ?? 0.0;
    return '৳${NumberFormat('#,##0.00', 'en_BD').format(amount)}';
  }
}

extension IntExtensions on int {
  String get asBdCurrency => '৳${NumberFormat('#,##0', 'en_BD').format(this)}';
  String get asMinutes {
    if (this < 60) return '${this}min';
    final h = this ~/ 60;
    final m = this % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}
