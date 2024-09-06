import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/common/widgets/custom_drop_down_button_widget.dart';
import 'package:six_cash/features/a_field_office/loans/loans/controllers/loanController.dart';
import 'package:six_cash/helper/route_helper.dart';

class LoanApplicationPage extends StatefulWidget {
  final int clientId;
  LoanApplicationPage({required this.clientId});

  @override
  _LoanApplicationPageState createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  final ClientLoanController controller = Get.put(ClientLoanController());

  @override
  void initState() {
    super.initState();
    controller.fetchLoanOffers();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientLoanController>(
      builder: (clientController) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Loan Application'),
            leading: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(); // Handles the back button
                },
              ),
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  // Handle home button press
                  // Get.offAll(HomePage());
                  Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true); // Replace with your home page navigation
                },
              ),
            ],
  ),
          ),
          body: Stack(
            children: [
              Form(
                key: clientController.formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Loading Indicator during fetch
                      if (clientController.isLoading)
                        Center(child: CircularProgressIndicator())
                      // No loan offers available
                      else if (clientController.percentages == null)
                        const Center(child: Text('No Loan Offers found.'))
                      // Loan application form
                      else ...[
                        TextFormField(
                          controller: clientController.loanAmountController,
                          decoration: InputDecoration(labelText: 'Loan Amount'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a loan amount';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: clientController.loanTermController,
                          decoration:
                              InputDecoration(labelText: 'Loan Term (Days)'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a loan term';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Monthly Payment: ${clientController.monthlyPayment.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Total Payment: ${clientController.totalPayment.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            clientController.submitLoanApplication(widget.clientId);
                          },
                          child: Text('Submit Application'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Overlay loading indicator when submitting
              if (clientController.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
