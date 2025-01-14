import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormattedLoanAmount extends StatelessWidget {
  final dynamic amount;

  FormattedLoanAmount({required this.amount});

  String get formattedLoanAmount {
    final formatter = NumberFormat('#,##0');
    if (amount is String) {
      return formatter.format(double.tryParse(amount) ?? 0);
    } else if (amount is double || amount is int) {
      return formatter.format(amount);
    } else {
      return 'Invalid amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedLoanAmount,
      style: TextStyle(fontSize: 18),
    );
  }
}
