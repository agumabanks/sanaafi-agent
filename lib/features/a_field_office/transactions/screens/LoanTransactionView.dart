import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:six_cash/features/a_field_office/transactions/controllers/transactionController.dart';

class LoanTransactionView extends StatelessWidget {
  final LoanTransactionController controller = Get.put(LoanTransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Transactions'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.loanTransactions.isEmpty) {
          return Center(child: Text('No loan transactions available'));
        }

        return ListView.builder(
          itemCount: controller.loanTransactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.loanTransactions[index];
            return ListTile(
              leading: Icon(
                transaction.isReversed! ? Icons.undo : Icons.check,
                color: transaction.isReversed! ? Colors.red : Colors.green,
              ),
              title: Text('${transaction.clientName}'),
              subtitle: Text(
                // 'Payment Date: ${transaction.paymentDate != null ? transaction.paymentDate!.toIso8601String() : 'N/A'}',
                // Format the date to 'yyyy-MM-dd'
                  'Payment Date: ${transaction.paymentDate != null ? DateFormat('yyyy-MM-dd').format(transaction.paymentDate!) : 'N/A'}',
              ),
              trailing: Text(
                'Amount: UGX ${transaction.amountPaid ?? 'N/A'}',
                style: TextStyle(
                  color: transaction.isReversed! ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
