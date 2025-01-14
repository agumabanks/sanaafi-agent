import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For currency & date formatting

import '../controllers/savings_controller.dart';
import '../domain/savings_account_model.dart';
// import 'package:six_cash/features/savings/domain/models/savings_account_model.dart';
import '../widgets/savings_transaction_item_widget.dart';

class SavingsDetailScreen extends StatelessWidget {
  const SavingsDetailScreen({Key? key}) : super(key: key);

  // NumberFormat for UGX with commas every 3 digits, 1 decimal place
  static final NumberFormat _ugxFormat = NumberFormat.currency(
    locale: 'en_UG', // Uganda locale
    symbol: 'UGX ', // Currency symbol
    decimalDigits: 1, // Only 1 decimal place
  );

  @override
  Widget build(BuildContext context) {
    final SavingsController savingsController = Get.find<SavingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Account',
            onPressed: () {
              // TODO: Implement edit functionality if needed
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete),
          //   tooltip: 'Delete Account',
          //   onPressed: () {
          //     _confirmDelete(context, savingsController.selectedAccount?.id);
          //   },
          // ),
        ],
      ),
      // The main body uses GetBuilder to reflect changes in the SavingsController
      body: GetBuilder<SavingsController>(
        builder: (ctrl) {
          final SavingsAccountModel? account = ctrl.selectedAccount;
          if (ctrl.isLoading || account == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= Account Information Card =======
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        _iconRow(
                          icon: Icons.account_balance_wallet,
                          label: 'Account Number',
                          value: account.accountNumber ?? 'N/A',
                        ),
                        _iconRow(
                          icon: Icons.monetization_on,
                          label: 'Balance',
                          // Using UGX format
                          value: _formatUgxDouble(account.balance),
                        ),
                        _iconRow(
                          icon: Icons.percent,
                          label: 'Interest Rate',
                          value: '${account.interestRate ?? 0}%',
                        ),
                        _iconRow(
                          icon: Icons.date_range,
                          label: 'Created At',
                          value: _formatDate(account.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ======= Client Information Card =======
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(account.clientData?.name ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${account.clientData?.email ?? 'N/A'}'),
                              Text('Phone: ${account.clientData?.phone ?? 'N/A'}'),
                              Text('Address: ${account.clientData?.address ?? 'N/A'}'),
                              Text('NIN: ${account.clientData?.nin ?? 'N/A'}'),
                              Text('Business: ${account.clientData?.business ?? 'N/A'}'),
                              Text('Status: ${account.clientData?.status ?? 'N/A'}'),
                              const SizedBox(height: 8),
                              Text('Next of Kin: ${account.clientData?.nextOfKin ?? 'N/A'}'),
                              Text('Phone: ${account.clientData?.nextOfKinPhone ?? 'N/A'}'),
                              Text('Relationship: ${account.clientData?.nextOfKinRelationship ?? 'N/A'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ======= Transactions History Card =======
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(),
                        account.transactions == null || account.transactions!.isEmpty
                            ? const Center(child: Text('No transactions available.'))
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: account.transactions!.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final tx = account.transactions![index];
                                  return SavingsTransactionItemWidget(transaction: tx);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Extra space for the floating buttons
              ],
            ),
          );
        },
      ),

      // ======= Floating Action Buttons (Deposit & Withdraw) =======
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: GetBuilder<SavingsController>(
        builder: (ctrl) {
          final account = ctrl.selectedAccount;
          if (account == null) {
            return const SizedBox(); // No FABs if no account is selected
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Deposit FAB
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton.extended(
                  heroTag: 'deposit_fab',
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.add),
                  label: const Text('Deposit'),
                  onPressed: () {
                    _showTransactionDialog(
                      title: 'Deposit',
                      onConfirm: (amount, description) {
                        ctrl.deposit(
                          savingsId: account.id!,
                          amount: amount,
                          description: description,
                        );
                      },
                    );
                  },
                ),
              ),
              // Withdraw FAB
              FloatingActionButton.extended(
                heroTag: 'withdraw_fab',
                backgroundColor: Colors.red,
                icon: const Icon(Icons.remove),
                label: const Text('Withdraw'),
                onPressed: () {
                  _showTransactionDialog(
                    title: 'Withdraw',
                    onConfirm: (amount, description) {
                      ctrl.withdraw(
                        savingsId: account.id!,
                        amount: amount,
                        description: description,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// A reusable Row widget for key-value pairs with an icon
  Widget _iconRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

//   final NumberFormat _ugxFormat = NumberFormat.currency(
//   locale: 'en_UG',
//   symbol: 'UGX ',
//   decimalDigits: 1,
// );

String _formatUgxDouble(double? balanceVal) {
  // Default to 0.0 if null
  final double val = balanceVal ?? 0.0; 
  return _ugxFormat.format(val); 
  // e.g. "UGX 1,234.5"
}

  /// Format UGX currency with commas & 1 decimal place
  String _formatUgxString(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return 'UGX 0.0';
    final double val = double.tryParse(amountStr) ?? 0.0;

    // Using the NumberFormat from 'intl'
    final ugxFormat = NumberFormat.currency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 1,
    );
    return ugxFormat.format(val);
  }

  /// Helper method to format DateTime
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    // You can use the intl package for more advanced formatting
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return dateFormat.format(date);
  }

  /// Helper method to show a confirmation dialog before deleting an account
  void _confirmDelete(BuildContext context, int? savingsId) {
    if (savingsId == null) return;

    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this savings account?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        final SavingsController savingsController = Get.find<SavingsController>();
        savingsController.deleteSavings(savingsId);
        Get.back(); // Close the dialog
        Get.back(); // Navigate back to the list screen
      },
      buttonColor: Colors.red,
    );
  }

  /// Show a dialog for deposit/withdraw
  void _showTransactionDialog({
    required String title,
    required Function(double amount, String? description) onConfirm,
  }) {
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (UGX)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 10),
              // Description Input
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          // Confirm Button
          ElevatedButton(
            onPressed: () {
              final parsedAmount = double.tryParse(_amountController.text.trim());
              final String description = _descriptionController.text.trim();

              if (parsedAmount == null || parsedAmount <= 0) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid amount (greater than 0).',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
                return;
              }

              onConfirm(parsedAmount, description.isNotEmpty ? description : null);
              Get.back(); // Close the dialog
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
