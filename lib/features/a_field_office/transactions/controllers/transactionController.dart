import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:six_cash/features/a_field_office/transactions/domain/LoanTransaction.dart';

class LoanTransactionController extends GetxController {
  var loanTransactions = <Datum>[].obs; // Observable list
  var isLoading = true.obs; // Loading indicator

  @override
  void onInit() {
    super.onInit();
    fetchLoanTransactions();
  }

  Future<void> fetchLoanTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedCustomerDataJson = prefs.getString('customerData');
      if (savedCustomerDataJson == null) {
        Get.snackbar("Error", "No customer data found");
        return;
      }
      Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      var agentId = savedCustomerData['id'];

      isLoading(true);
      final response = await http.get(Uri.parse('http://maslink.sanaa.co/api/v1/agent/$agentId/loan-transactions'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          var data = jsonResponse['data'] as List;
          loanTransactions.value = data.map((json) => Datum.fromJson(json)).toList();
        } else {
          Get.snackbar("Error", jsonResponse['message']);
        }
      } else {
        Get.snackbar("Error", "Failed to fetch data");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }
  }
}
