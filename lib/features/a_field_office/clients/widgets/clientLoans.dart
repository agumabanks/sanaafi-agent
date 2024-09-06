import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/loans/loans/controllers/loanController.dart';

class ClientLoansPage extends StatelessWidget {
  // final ClientLoanController _controller = Get.put(ClientLoanController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientLoanController>(builder: (_controller) {
        if (_controller.isLoadingLo.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (_controller.clientLoans.isEmpty) {
          return const Center(child: Text('No loans found.'));
        } else {
          return ListView.builder(
            itemCount: _controller.clientLoans.length,
            itemBuilder: (context, index) {
              final loan = _controller.clientLoans[index];
              return ListTile(
                title: Text('Amount: ${loan.amount}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount Paid: ${loan.paidAmount}'),
                    Text('Status: ${loan.status}'),
                    Text('hello')
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}