import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/features/a_field_office/clients/screens/ClientsPage.dart';
import 'package:six_cash/features/a_field_office/home/screens/fo-home.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';
import 'package:six_cash/helper/route_helper.dart';
import '../../../../data/api/api_client.dart';

class AddClientController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController businessController = TextEditingController();
  final TextEditingController ninController = TextEditingController();
  final TextEditingController recommendersController = TextEditingController();
  final TextEditingController creditBalanceController = TextEditingController();
  final TextEditingController savingsBalanceController = TextEditingController();

  final AuthRepo authRepo = Get.find<AuthRepo>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String toTitleCase(String text) {
    return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  Future<void> addClient() async {
    _isLoading = true;
    update(); // Notify GetBuilder to update the UI

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    var userId = savedCustomerData['id'];


//  $validator = Validator::make($request->all(), [
//         'user_id' => 'required|exists:users,id',
//         'client_id' => 'required|exists:clients,id',
//         'agent_id' => 'required|exists:users,id',
//         'trx' => 'nullable|string|max:40',
//         'amount' => 'required|numeric|min:0',
//         'installment_interval' => 'required|integer|min:1',
//         'paid_amount' => 'nullable|numeric|min:0',
//         'next_installment_date' => 'nullable|date',
//         'user_details' => 'nullable|string',
//     ]);
    final Map<String, dynamic> clientData = {
      'name': toTitleCase(nameController.text.trim()),
      'email': '${nameController.text.trim().replaceAll(' ', '')}@sanaa.co',
      'phone': phoneController.text,
      'address': addressController.text,
      'dob': dobController.text,
      'business': businessController.text,
      'nin': ninController.text.toUpperCase(),
      'recommenders': ["ffg"],
      'credit_balance': double.tryParse(creditBalanceController.text) ?? 0,
      'savings_balance': double.tryParse(savingsBalanceController.text) ?? 0,
      'added_by': userId,
    };

    Response response = await authRepo.addClient(clientData);

    if (response.body['response_code'] == 'default_200') {
      Get.find<AuthController>().getClients();

      showCustomSnackBarHelper('Client added successfully', isError: false, duration: const Duration(minutes: 3));

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 3));

        resetClientData();
        _isLoading = false;
        update(); // Notify GetBuilder to update the UI

        if (Get.currentRoute != RouteHelper.navbar) {
          Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
        }
        Get.find<AuthController>().update();  // Call update here to ensure UI is refreshed
      });
    } else {
      _isLoading = false;
      update(); // Notify GetBuilder to update the UI

      showCustomSnackBarHelper('Failed to add client', isError: true, duration: const Duration(minutes: 5));
    }
  }

  void resetClientData() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    dobController.clear();
    businessController.clear();
    ninController.clear();
    recommendersController.clear();
    creditBalanceController.clear();
    savingsBalanceController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    businessController.dispose();
    ninController.dispose();
    recommendersController.dispose();
    creditBalanceController.dispose();
    savingsBalanceController.dispose();
    super.onClose();
  }
}
