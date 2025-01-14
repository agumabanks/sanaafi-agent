// // lib/features/savings/controllers/savings_controller.dart
// lib/features/savings/controllers/savings_controller.dart

import 'package:get/get.dart';
import '../../../data/api/api_checker.dart';
// import 'package:six_cash/features/savings/domain/models/savings_account_model.dart';
// import 'package:six_cash/features/savings/domain/repositories/savings_repo.dart';
import 'package:flutter/foundation.dart';
import '../domain/savings_account_model.dart';
import '../domain/savings_repo.dart';

class SavingsController extends GetxController implements GetxService {
  final SavingsRepo savingsRepo;
  SavingsController({required this.savingsRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List of savings accounts for index screen
  List<SavingsAccountModel> _savingsList = [];
  List<SavingsAccountModel> get savingsList => _savingsList;

  // Single account details (with transactions)
  SavingsAccountModel? _selectedAccount;
  SavingsAccountModel? get selectedAccount => _selectedAccount;

  /// 1) Fetch all savings
  Future<void> fetchAllSavings({int page = 1}) async {
    _isLoading = true;
    update();

    final response = await savingsRepo.getAllSavings(page: page);
    if (response.statusCode == 200) {
      List<dynamic> data = response.body['data'] ?? [];
      _savingsList = data
          .map((json) => SavingsAccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 2) Create a new savings account
  Future<void> createSavings({
    required int clientId,
    int? agentId,
    required double initialDeposit,
    required int accountTypeId,
  }) async {
    _isLoading = true;
    update();

    final body = {
      'client_id': clientId,
      'agent_id': agentId,
      'initial_deposit': initialDeposit,
      'account_type_id': accountTypeId,
    };

    final response = await savingsRepo.createSavings(body);
    if (response.isOk) {
      debugPrint('Savings account created successfully.');
      // Optionally refresh the list:
      await fetchAllSavings();
      // Show a success message using GetX Snackbar or any other method
      Get.snackbar('Success', 'Savings account created successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 3) Show a single savings account by ID
  Future<void> fetchSavingsById(int id, ) async {
    _isLoading = true;
    update();

    final response = await savingsRepo.getSavingsById(id);
    if (response.isOk && response.body != null) {
      _selectedAccount = SavingsAccountModel.fromJson(response.body as Map<String, dynamic>);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 4) Update an existing savings
  Future<void> updateSavings({
    required int savingsId,
    required int clientId,
    int? agentId,
    required int accountTypeId,
  }) async {
    _isLoading = true;
    update();

    final body = {
      'client_id': clientId,
      'agent_id': agentId,
      'account_type_id': accountTypeId,
    };

    final response = await savingsRepo.updateSavings(savingsId, body);
    if (response.isOk) {
      debugPrint('Savings account updated.');
      // Optionally refresh the selected account details
      await fetchSavingsById(savingsId);
      Get.snackbar('Success', 'Savings account updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 5) Delete an existing savings
  Future<void> deleteSavings(int id) async {
    _isLoading = true;
    update();

    final response = await savingsRepo.deleteSavings(id);
    if (response.isOk) {
      // remove from local list
      _savingsList.removeWhere((acc) => acc.id == id);
      debugPrint('Savings account deleted.');
      Get.snackbar('Success', 'Savings account deleted successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 6) Deposit to a savings account
  Future<void> deposit({
    required int savingsId,
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    update();

    final body = {
      'amount': amount,
      'description': description ?? 'Deposit',
    };

    final response = await savingsRepo.deposit(savingsId, body);
    if (response.isOk) {
      debugPrint('Deposit successful');
      Get.snackbar('Success', 'Deposit successful.',
          snackPosition: SnackPosition.BOTTOM);
      // Refresh the selected account details to update balance and transactions
      await fetchSavingsById(savingsId);
      // Optionally, refresh the list
      await fetchAllSavings();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 7) Withdraw from a savings account
  Future<void> withdraw({
    required int savingsId,
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    update();

    final body = {
      'amount': amount,
      'description': description ?? 'Withdrawal',
    };

    final response = await savingsRepo.withdraw(savingsId, body);
    if (response.isOk) {
      debugPrint('Withdrawal successful');
      Get.snackbar('Success', 'Withdrawal successful.',
          snackPosition: SnackPosition.BOTTOM);
      // Refresh the selected account details to update balance and transactions
      await fetchSavingsById(savingsId);
      // Optionally, refresh the list
      await fetchAllSavings();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  /// 8) Print Transaction Receipt PDF
  Future<void> printTransactionReceiptPdf(int savingsId, int transactionId) async {
    _isLoading = true;
    update();

    // final response = await savingsRepo.printTransactionReceiptPdf(savingsId, transactionId);
    // if (response.isOk) {
    //   // Handle the PDF data, e.g., open in a PDF viewer or download
    //   // This requires additional implementation based on your requirements
    //   debugPrint('PDF Receipt fetched successfully.');
    //   // Example: Open PDF in browser
    //   // Get.to(() => PdfViewerScreen(pdfUrl: response.body['url']));
    // } else {
    //   ApiChecker.checkApi(response);
    // }

    _isLoading = false;
    update();
  }

  /// 9) Generate Reports
  Future<void> generateReports(Map<String, dynamic> body) async {
    _isLoading = true;
    update();

    // final response = await savingsRepo.generateReports(body);
    // if (response.isOk) {
    //   debugPrint('Reports generated successfully.');
    //   // Handle the report data as needed
    // } else {
    //   ApiChecker.checkApi(response);
    // }

    _isLoading = false;
    update();
  }

  /// 10) Export Reports
  Future<void> exportReports(Map<String, dynamic> body) async {
    _isLoading = true;
    update();

    // final response = await savingsRepo.exportReports(body);
    // if (response.isOk) {
    //   debugPrint('Reports exported successfully.');
    //   // Handle the exported data, e.g., download file
    // } else {
    //   ApiChecker.checkApi(response);
    // }

    _isLoading = false;
    update();
  }

  /// Reset selected account
  void resetSelectedAccount() {
    _selectedAccount = null;
    update();
  }
}

// import 'package:get/get.dart';
// import 'package:six_cash/data/api/api_checker.dart';
// // import 'package:six_cash/features/savings/domain/repositories/savings_repo.dart';
// // import 'package:six_cash/features/savings/domain/models/savings_account_model.dart';
// // import 'package:six_cash/features/savings/domain/models/savings_transaction_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:six_cash/features/savings/domain/savings_model.dart';
// import 'package:six_cash/features/savings/domain/savings_repo.dart';

// class SavingsController extends GetxController implements GetxService {
//   final SavingsRepo savingsRepo;
//   SavingsController({required this.savingsRepo});

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   // List of savings accounts for index screen
//   List<SavingsAccountModel> _savingsList = [];
//   List<SavingsAccountModel> get savingsList => _savingsList;

//   // Single account details (with transactions)
//   SavingsAccountModel? _selectedAccount;
//   SavingsAccountModel? get selectedAccount => _selectedAccount;

//   /// 1) Fetch all savings
//   Future<void> fetchAllSavings({int page = 1}) async {
//     _isLoading = true;
//     update();

//     final response = await savingsRepo.getAllSavings(page: page);
//     if (response.statusCode == 200) {
//       List data = response.body['data'] ?? [];
//       _savingsList = data.map((json) => SavingsAccountModel.fromJson(json)).toList().cast<SavingsAccountModel>();
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 2) Create a new savings account
//   Future<void> createSavings({
//     required int clientId,
//     int? agentId,
//     required double initialDeposit,
//     required int accountTypeId,
//   }) async {
//     _isLoading = true;
//     update();

//     final body = {
//       'client_id': clientId,
//       'agent_id': agentId,
//       'initial_deposit': initialDeposit,
//       'account_type_id': accountTypeId,
//     };

//     final response = await savingsRepo.createSavings(body);
//     if (response.isOk) {
//       debugPrint('Savings account created successfully.');
//       // Optionally refresh the list:
//       // fetchAllSavings();
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 3) Show a single savings account by ID
//   Future<void> fetchSavingsById(int id) async {
//     _isLoading = true;
//     update();

//     final response = await savingsRepo.getSavingsById(id);
//     if (response.isOk && response.body != null) {
//       // Parse the JSON into a SavingsAccountModel (including transactions if present)
//       _selectedAccount = SavingsAccountModel.fromJson(response.body);
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 4) Update an existing savings
//   Future<void> updateSavings({
//     required int savingsId,
//     required int clientId,
//     int? agentId,
//     required int accountTypeId,
//   }) async {
//     _isLoading = true;
//     update();

//     final body = {
//       'client_id': clientId,
//       'agent_id': agentId,
//       'account_type_id': accountTypeId,
//     };

//     final response = await savingsRepo.updateSavings(savingsId, body);
//     if (response.isOk) {
//       debugPrint('Savings account updated.');
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 5) Delete an existing savings
//   Future<void> deleteSavings(int savingsId) async {
//     _isLoading = true;
//     update();

//     final response = await savingsRepo.deleteSavings(savingsId);
//     if (response.isOk) {
//       // remove from local list
//       _savingsList.removeWhere((acc) => acc.id == savingsId);
//       debugPrint('Savings account deleted.');
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 6) Deposit to a savings account
//   Future<void> deposit({
//     required int savingsId,
//     required double amount,
//     String? description,
//   }) async {
//     _isLoading = true;
//     update();

//     final body = {
//       'amount': amount,
//       'description': description ?? 'Deposit',
//     };

//     final response = await savingsRepo.deposit(savingsId, body);
//     if (response.isOk) {
//       debugPrint('Deposit successful');
//       // If we are viewing that account, refresh or update the local balance
//       if (_selectedAccount != null && _selectedAccount!.id == savingsId) {
//         await fetchSavingsById(savingsId);
//       }
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   /// 7) Withdraw from a savings account
//   Future<void> withdraw({
//     required int savingsId,
//     required double amount,
//     String? description,
//   }) async {
//     _isLoading = true;
//     update();

//     final body = {
//       'amount': amount,
//       'description': description ?? 'Withdrawal',
//     };

//     final response = await savingsRepo.withdraw(savingsId, body);
//     if (response.isOk) {
//       debugPrint('Withdrawal successful');
//       if (_selectedAccount != null && _selectedAccount!.id == savingsId) {
//         await fetchSavingsById(savingsId);
//       }
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _isLoading = false;
//     update();
//   }

//   void clearSelectedAccount() {
//     _selectedAccount = null;
//   }
// }
