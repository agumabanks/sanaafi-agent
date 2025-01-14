import 'package:get/get.dart';

class LoanCalculatorController extends GetxController {
  // Variables for loan details
  var loanAmount = 0.0.obs;
  var interestRate = 0.0.obs;

  // Variables for results
  var totalRepayment = 0.0.obs;
  var dailyInstallment = 0.0.obs;

  // Function to calculate installments
  void calculateInstallments() {
    // Calculate the total repayment based on the loan amount and interest rate
    double totalAmount = loanAmount.value + (loanAmount.value * (interestRate.value / 100));
    totalRepayment.value = totalAmount;

    // Calculate the daily installment assuming a 30-day repayment period
    double dailyPayment = totalAmount / 30;
    dailyInstallment.value = dailyPayment;
  }
}
