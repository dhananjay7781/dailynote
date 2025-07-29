import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  static String formatDateForDatabase(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}