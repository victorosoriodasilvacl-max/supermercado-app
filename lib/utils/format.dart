import 'package:intl/intl.dart';

final _clp = NumberFormat.currency(
  locale: 'es_CL',
  symbol: '\$',
  decimalDigits: 0,
);

String formatCLP(num value) => _clp.format(value);
