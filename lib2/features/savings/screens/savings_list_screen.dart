// lib/features/savings/presentation/screens/savings_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/savings_controller.dart';
import 'savings_detail_screen.dart';

class SavingsListScreen extends StatefulWidget {
  const SavingsListScreen({Key? key}) : super(key: key);

  @override
  State<SavingsListScreen> createState() => _SavingsListScreenState();
}

class _SavingsListScreenState extends State<SavingsListScreen> {
  final savingsController = Get.find<SavingsController>();

  @override
  void initState() {
    super.initState();
    savingsController.fetchAllSavings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Accounts'),
      ),
      body: GetBuilder<SavingsController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.savingsList.isEmpty) {
            return const Center(child: Text('No Savings Accounts Found'));
          }

          return ListView.builder(
            itemCount: ctrl.savingsList.length,
            itemBuilder: (context, index) {
              final account = ctrl.savingsList[index];
              final clientName = account.clientData?.name ?? 'Unknown Client';
              final acctNumber = account.accountNumber;
              final balance = account.balance;

              return ListTile(
                title: Text('$clientName'), // e.g. "KIGGUNDU STEPHEN"
                subtitle: Text('Acct: $acctNumber\nBalance: $balance'),
                onTap: () async {
                  // 1) fetch the details for that account
                  await ctrl.fetchSavingsById(account.id);
                  // 2) navigate to detail screen
                  Get.to(() => const SavingsDetailScreen());
                },
              );
            },
          );

        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Example: quickly create a test savings or
      //     // navigate to a "CreateSavingsScreen" with forms
      //     savingsController.createSavings(
      //       clientId: 476,
      //       agentId: 53,
      //       initialDeposit: 50000,
      //       accountTypeId: 1,
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
