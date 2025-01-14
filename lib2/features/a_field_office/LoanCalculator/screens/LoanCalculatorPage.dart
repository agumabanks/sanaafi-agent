import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/LoanCalculatorController.dart';
 
class LoanCalculatorPage extends StatelessWidget {
  final LoanCalculatorController controller = Get.put(LoanCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Container(
        
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Loan Amount (UGX)',
              onChanged: (value) {
                controller.loanAmount.value = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Interest Rate (%)',
              onChanged: (value) {
                controller.interestRate.value = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: controller.calculateInstallments,
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Obx(() => _buildResultSection(
              label: 'Total Repayment:',
              value: controller.totalRepayment.value.toStringAsFixed(2),
            )),
            const SizedBox(height: 10),
            Obx(() => _buildResultSection(
              label: 'Daily Installment:',
              value: controller.dailyInstallment.value.toStringAsFixed(2),
            )),
                ],
              ),
            ),
           
          ],
        ),
      ),
    );
  }

  // Helper method for building text fields
  Widget _buildTextField({required String label, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Helper method for building result section
  Widget _buildResultSection({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
