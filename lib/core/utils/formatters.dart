import 'package:intl/intl.dart';

/// أدوات تنسيق التواريخ
class DateFormatter {
  /// تنسيق التاريخ بصيغة عربية (مثل: ١٥ يناير ٢٠٢٤)
  static String formatArabic(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'ar');
    return formatter.format(date);
  }

  /// تنسيق التاريخ بصيغة قصيرة (مثل: 15/01/2024)
  static String formatShort(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  /// تنسيق الوقت (مثل: 03:30 م)
  static String formatTime(DateTime date) {
    // نستخدم hh لضمان وجود الصفر في الساعات (01-12)
    final formatter = DateFormat('hh:mm a', 'ar');
    return formatter.format(date);
  }

  /// تنسيق التاريخ والوقت (مثل: 15 يناير 2024، 3:30 م)
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy، h:mm a', 'ar');
    return formatter.format(date);
  }

  /// تنسيق نسبي (مثل: منذ ساعتين، منذ 3 أيام)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 30) {
      return 'الآن';
    } else if (difference.inSeconds < 60) {
      return 'منذ ثوانٍ';
    } else if (difference.inMinutes < 60) {
      if (difference.inMinutes == 1) return 'منذ دقيقة';
      if (difference.inMinutes == 2) return 'منذ دقيقتين';
      return 'منذ ${difference.inMinutes} ${_pluralize(difference.inMinutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
    } else if (difference.inHours < 24) {
      if (difference.inHours == 1) return 'منذ ساعة';
      if (difference.inHours == 2) return 'منذ ساعتين';
      return 'منذ ${difference.inHours} ${_pluralize(difference.inHours, 'ساعة', 'ساعتين', 'ساعات')}';
    } else if (difference.inDays < 7) {
      if (difference.inDays == 1) return 'منذ يوم';
      if (difference.inDays == 2) return 'منذ يومين';
      return 'منذ ${difference.inDays} ${_pluralize(difference.inDays, 'يوم', 'يومين', 'أيام')}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${_pluralize(weeks, 'أسبوع', 'أسبوعين', 'أسابيع')}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${_pluralize(months, 'شهر', 'شهرين', 'أشهر')}';
    }
  }

  /// تنسيق مخصص لتوقعات الطقس الساعية
  static String formatHourlyLabel(DateTime time, bool isFirst, {bool isNextDayCross = false}) {
    if (isFirst) return 'الآن';
    if (isNextDayCross) return 'غداً';
    
    // تنسيق 12 ساعة بالعربية (10 ص، 02 م)
    final h = time.hour;
    if (h == 0) return '12 ص';
    if (h < 12) return '$h ص';
    if (h == 12) return '12 م';
    return '${h - 12} م';
  }

  /// مساعد للجمع العربي
  static String _pluralize(
    int count,
    String singular,
    String dual,
    String plural,
  ) {
    if (count == 1) return singular;
    if (count == 2) return dual;
    return plural;
  }

  /// تحويل من ISO String
  static DateTime? parseIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// تحويل إلى ISO String
  static String toIso(DateTime date) {
    return date.toIso8601String();
  }
}

/// أدوات تنسيق الأسعار
class PriceFormatter {
  /// تنسيق السعر بالريال السعودي (مثل: 150.00 ر.س)
  static String format(double price, {bool showCurrency = true}) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    final formatted = formatter.format(price);
    return showCurrency ? '$formatted ر.س' : formatted;
  }

  /// تنسيق السعر من String
  static String formatString(String price, {bool showCurrency = true}) {
    final priceValue = double.tryParse(price) ?? 0.0;
    return format(priceValue, showCurrency: showCurrency);
  }

  /// تنسيق مختصر للأسعار الكبيرة (مثل: 1.5k، 2.3M)
  static String formatCompact(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}

/// أدوات تنسيق الأرقام
class NumberFormatter {
  /// تنسيق الأرقام بالفواصل (مثل: 1,234,567)
  static String format(int number) {
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  /// تنسيق النسبة المئوية (مثل: 75%)
  static String formatPercentage(double percentage, {int decimals = 0}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  /// تنسيق التقييم (مثل: 4.5/5)
  static String formatRating(double rating, {double max = 5.0}) {
    return '${rating.toStringAsFixed(1)}/$max';
  }
}
