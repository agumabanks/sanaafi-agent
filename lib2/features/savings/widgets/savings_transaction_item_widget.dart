import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Replace with your actual transaction model import:
// import 'package:six_cash/features/savings/domain/models/savings_transaction_model.dart';
import '../domain/savings_account_model.dart';

class SavingsTransactionItemWidget extends StatelessWidget {
  final SavingsTransactionModel transaction;

  const SavingsTransactionItemWidget({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  // NumberFormat for UGX with commas every 3 digits & 1 decimal place
  static final NumberFormat _ugxFormat = NumberFormat.currency(
    locale: 'en_UG',    // or 'en_US', depending on your preference
    symbol: 'UGX ',     // The UGX currency symbol
    decimalDigits: 1,   // Only one decimal place
  );

  /// Formats a DateTime into a readable string, e.g. "07 Feb 2024 14:36"
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final DateFormat formatter = DateFormat('dd MMM yyyy HH:mm');
    return formatter.format(date);
  }

  /// Safely parses the transaction amount (String? or double?) 
  /// and formats it in UGX with commas and 1 decimal place.
  String _formatAmount(dynamic amount) {
    if (amount == null) return 'UGX 0.0';

    double parsedAmount;
    if (amount is double) {
      // If the model defines 'amount' as double? 
      parsedAmount = amount;
    } else if (amount is String) {
      // If the model defines 'amount' as String?
      parsedAmount = double.tryParse(amount) ?? 0.0;
    } else {
      // Fallback if somehow it's neither
      parsedAmount = 0.0;
    }
    return _ugxFormat.format(parsedAmount);
  }

  @override
  Widget build(BuildContext context) {
    // Distinguish deposit vs. withdrawal
    final bool isDeposit = transaction.type?.toLowerCase() == 'deposit';
    final Color iconColor = isDeposit ? Colors.green : Colors.red;
    final IconData iconData = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;

    return ListTile(
      leading: Icon(iconData, color: iconColor),
      title: Text(
        isDeposit ? 'Deposit' : 'Withdrawal',
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        transaction.description ?? '',
        style: const TextStyle(fontSize: 14),
      ),
      // Show amount and date on the trailing side
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Formatted amount
          Text(
            _formatAmount(transaction.amount),
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          // Formatted date
          Text(
            _formatDate(transaction.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
