// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:six_cash/features/a_field_office/clients/screens/ClientsPage.dart';
// import 'package:six_cash/features/a_field_office/home/screens/fo-home.dart';
// import 'package:six_cash/features/auth/controllers/auth_controller.dart';
// import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';
// import 'package:six_cash/helper/custom_snackbar_helper.dart';
// import 'package:six_cash/helper/route_helper.dart';

// import '../../../../data/api/api_client.dart';

// class AddClientController extends GetxController {
//   final formKey = GlobalKey<FormState>();

//   // Text Editing Controllers
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController dobController = TextEditingController();
//   final TextEditingController businessController = TextEditingController();
//   final TextEditingController ninController = TextEditingController();
//   final TextEditingController recommendersController = TextEditingController();
//   final TextEditingController creditBalanceController = TextEditingController();
//   final TextEditingController savingsBalanceController = TextEditingController();

//   final AuthRepo authRepo = Get.find<AuthRepo>();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   // Convert to Title Case
//   String _toTitleCase(String text) {
//     return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
//   }

//   // Add a new client
//   Future<void> addClient() async {
//     if (!formKey.currentState!.validate()) return;

//     _setLoadingState(true);

//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? savedCustomerDataJson = prefs.getString('customerData');
//       if (savedCustomerDataJson == null) {
//         _showError('No customer data found.');
//         return;
//       }

//       Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
//       String userId = savedCustomerData['id'];

//       final Map<String, dynamic> clientData = {
//         'name': _toTitleCase(nameController.text.trim()),
//         'email': '${nameController.text.trim().replaceAll(' ', '')}@sanaa.co',
//         'phone': phoneController.text,
//         'address': addressController.text,
//         'dob': dobController.text,
//         'business': businessController.text,
//         'nin': ninController.text.toUpperCase(),
//         'recommenders': ["ffg"],
//         'credit_balance': double.tryParse(creditBalanceController.text) ?? 0,
//         'savings_balance': double.tryParse(savingsBalanceController.text) ?? 0,
//         'added_by': userId,
//       };

//       Response response = await authRepo.addClient(clientData);

//       if (response.body['response_code'] == 'default_200') {
//         _handleSuccess();
//       } else {
//         _showError('Failed to add client');
//       }
//     } catch (e) {
//       _showError('An error occurred: $e');
//     } finally {
//       _setLoadingState(false);
//     }
//   }

//   // Set loading state and update UI
//   void _setLoadingState(bool isLoading) {
//     _isLoading = isLoading;
//     update(); // Notify GetBuilder to update the UI
//   }

//   // Handle successful client addition
//   void _handleSuccess() async {
//     Get.find<AuthController>().getClients();
//     showCustomSnackBarHelper('Client added successfully', isError: false, duration: const Duration(minutes: 3));

//     await Future.delayed(const Duration(seconds: 3));
//     resetClientData();

//     if (Get.currentRoute != RouteHelper.navbar) {
//       Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
//     }

//     Get.find<AuthController>().update();  // Update UI after navigating
//   }

//   // Show error message
//   void _showError(String message) {
//     showCustomSnackBarHelper(message, isError: true, duration: const Duration(minutes: 5));
//   }

//   // Reset client data in form
//   void resetClientData() {
//     nameController.clear();
//     emailController.clear();
//     phoneController.clear();
//     addressController.clear();
//     dobController.clear();
//     businessController.clear();
//     ninController.clear();
//     recommendersController.clear();
//     creditBalanceController.clear();
//     savingsBalanceController.clear();
//   }

//   // Clean up controllers when closing
//   @override
//   void onClose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     dobController.dispose();
//     businessController.dispose();
//     ninController.dispose();
//     recommendersController.dispose();
//     creditBalanceController.dispose();
//     savingsBalanceController.dispose();
//     super.onClose();
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:six_cash/features/a_field_office/clients/screens/clients_page.dart';
// import 'package:six_cash/features/a_field_office/home/screens/fo_home.dart';
import '../../../auth/controllers/auth_controller.dart';
// import 'package:six_cash/features/auth/domain/repositories/auth_repo.dart';
import '../../../auth/domain/reposotories/auth_repo.dart';
import '../../../../helper/custom_snackbar_helper.dart';
import '../../../../helper/route_helper.dart';

import '../../../../data/api/api_client.dart';

class AddClientController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Editing Controllers
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

  // Convert to Title Case
  String _toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Add a new client
  Future<void> addClient() async {
    if (!formKey.currentState!.validate()) return;

    _setLoadingState(true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedCustomerDataJson = prefs.getString('customerData');
      if (savedCustomerDataJson == null) {
        _showError('No customer data found.');
        return;
      }

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? savedCustomerDataJ = pref.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJ!);
    var addedBy = savedCustomerData['id'];


      // Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      // String userId = savedCustomerData['id'];

      final Map<String, dynamic> clientData = {
        'name': _toTitleCase(nameController.text.trim()),
        'email': '${nameController.text.trim().replaceAll(' ', '')}@sanaa.co',
        'phone': phoneController.text,
        'address': addressController.text,
        'dob': dobController.text,
        'business': businessController.text,
        'nin': ninController.text.toUpperCase(),
        'recommenders': ["ffg"],
        'credit_balance': double.tryParse(creditBalanceController.text) ?? 0,
        'savings_balance': double.tryParse(savingsBalanceController.text) ?? 0,
        'added_by': addedBy,
      };

      Response response = await authRepo.addClient(clientData);

      if (response.body['response_code'] == 'default_200') {
        _handleSuccess();
      } else {
        _showError('Failed to add client');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Set loading state and update UI
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    update(); // Notify GetBuilder to update the UI
  }

  // Handle successful client addition
  void _handleSuccess() async {
    Get.find<AuthController>().getClients();
    showCustomSnackBarHelper('Client added successfully', isError: false, duration: const Duration(minutes: 3));

    await Future.delayed(const Duration(seconds: 3));
    resetClientData();

    if (Get.currentRoute != RouteHelper.navbar) {
      Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
    }

    Get.find<AuthController>().update();  // Update UI after navigating
  }

  // Show error message
  void _showError(String message) {
    showCustomSnackBarHelper(message, isError: true, duration: const Duration(minutes: 5));
  }

  // Reset client data in form
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

  // Clean up controllers when closing
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
