import 'package:intl/intl.dart';

class Utility {
  static String formatDateTime(DateTime dt) {
    final df = DateFormat('hh:mm a MMM/dd/yyyy');
    return df.format(dt.toLocal());
  }
}
