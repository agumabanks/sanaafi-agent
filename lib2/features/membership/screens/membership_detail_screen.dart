// lib/features/membership/presentation/screens/membership_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
// import 'package:six_cash/features/membership/domain/models/membership_model.dart';

class MembershipDetailScreen extends StatelessWidget {
  const MembershipDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final membershipController = Get.find<MembershipController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Details'),
      ),
      body: GetBuilder<MembershipController>(builder: (ctrl) {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final membership = ctrl.selectedMembership;
        if (membership == null) {
          return const Center(child: Text('No membership selected.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Membership ID: ${membership.id}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Client: ${membership.client?.name ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Membership Type: ${membership.membershipType}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Shares: ${membership.shares}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Share Value: ${membership.shareValue}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Fees: ${membership.membershipFees}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Is Paid: ${membership.isPaid}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Is Shares Paid: ${membership.isSharesPaid}', style: const TextStyle(fontSize: 16)),
              const Divider(height: 20),

              const Text('Share Transactions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (membership.transactionsList.isEmpty)
                const Text('No transactions found.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: membership.transactionsList.length,
                  itemBuilder: (context, index) {
                    final tx = membership.transactionsList[index];
                    return ListTile(
                      title: Text('Type: ${tx.transactionType}'),
                      subtitle: Text('Amount: ${tx.amount}\nDesc: ${tx.description ?? ''}'),
                      trailing: Text(tx.createdAt),
                    );
                  },
                ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // "Create" share transaction
                  ElevatedButton.icon(
                    onPressed: () {
                      _showShareTransactionDialog(
                        context,
                        membershipId: membership.id,
                        transactionType: 'create',
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Shares'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showShareTransactionDialog(
                        context,
                        membershipId: membership.id,
                        transactionType: 'reverse',
                      );
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Reverse'),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  void _showShareTransactionDialog(
    BuildContext context, {
    required int membershipId,
    required String transactionType,
  }) {
    final membershipController = Get.find<MembershipController>();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(transactionType == 'create' ? 'Add Shares' : 'Reverse Shares'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amountStr = amountController.text.trim();
              final double? amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) {
                Get.snackbar('Error', 'Please enter a valid amount > 0');
                return;
              }

              membershipController.storeShareTransaction(
                membershipId: membershipId,
                transactionType: transactionType, // 'create' or 'reverse'
                amount: amount,
                description: descController.text.trim().isNotEmpty
                    ? descController.text.trim()
                    : null,
              );
              Get.back();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
