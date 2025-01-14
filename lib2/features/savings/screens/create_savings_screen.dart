// lib/features/savings/presentation/screens/create_savings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/savings_controller.dart';

class CreateSavingsScreen extends StatefulWidget {
  const CreateSavingsScreen({Key? key}) : super(key: key);

  @override
  State<CreateSavingsScreen> createState() => _CreateSavingsScreenState();
}

class _CreateSavingsScreenState extends State<CreateSavingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _agentIdController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _acctTypeIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final savingsController = Get.find<SavingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Savings Account'),
      ),
      body: GetBuilder<SavingsController>(
        builder: (controller) {
          return AbsorbPointer(
            absorbing: controller.isLoading, // Prevent interaction if loading
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  // Client ID
                  TextFormField(
                    controller: _clientIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Client ID',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Client ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Client ID must be an integer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Agent ID
                  TextFormField(
                    controller: _agentIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Agent ID (optional)',
                      prefixIcon: Icon(Icons.people_alt),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Agent ID must be an integer';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Initial Deposit
                  TextFormField(
                    controller: _depositController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Initial Deposit',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid amount format';
                      }
                      if (double.parse(value) < 0) {
                        return 'Deposit cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account Type ID
                  TextFormField(
                    controller: _acctTypeIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account Type ID',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Account Type ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Account Type ID must be an integer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final clientId = int.parse(_clientIdController.text.trim());
                        final agentId = _agentIdController.text.isNotEmpty
                            ? int.parse(_agentIdController.text.trim())
                            : null;
                        final initialDeposit = double.parse(_depositController.text.trim());
                        final acctTypeId = int.parse(_acctTypeIdController.text.trim());

                        await savingsController.createSavings(
                          clientId: clientId,
                          agentId: agentId,
                          initialDeposit: initialDeposit,
                          accountTypeId: acctTypeId,
                        );
                        
                        // If you want to go back or show something:
                        if (!controller.isLoading) {
                          Get.back(); // Return to previous screen
                        }
                      }
                    },
                    icon: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.check),
                    label: const Text('CREATE'),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _agentIdController.dispose();
    _depositController.dispose();
    _acctTypeIdController.dispose();
    super.dispose();
  }
}
