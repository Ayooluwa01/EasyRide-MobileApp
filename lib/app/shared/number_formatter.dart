import 'package:intl/intl.dart';

String formatFare(num value) {
  final formatter = NumberFormat('#,##0', 'en_NG');
  return '₦${formatter.format(value)}';
}
