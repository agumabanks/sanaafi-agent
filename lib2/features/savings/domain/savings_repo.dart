// lib/features/savings/domain/repositories/savings_repo.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/api_client.dart';
import '../../../util/app_constants.dart';

class SavingsRepo extends GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  SavingsRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  /// 1) List (paginated) -> GET /api/v1/savings
  Future<Response> getAllSavings({int page = 1}) {
    final uri = '${AppConstants.savingsIndexUri}?page=$page';
    return apiClient.getData(uri);
  }

  /// 2) Store -> POST /api/v1/savings
  Future<Response> createSavings(Map<String, dynamic> body) {
    return apiClient.postData(AppConstants.savingsStoreUri, body);
  }

  /// 3) Show -> GET /api/v1/savings/{id}
  Future<Response> getSavingsById(int id) {
    final uri = '${AppConstants.savingsShowUri}/$id';
    return apiClient.getData(uri);
  }

  /// 4) Update -> PUT /api/v1/savings/{id}
  Future<Response> updateSavings(int id, Map<String, dynamic> body) {
    final uri = '${AppConstants.savingsUpdateUri}/$id';
    return apiClient.putData(uri, body);
  }

  /// 5) Destroy -> DELETE /api/v1/savings/{id}
  Future<Response> deleteSavings(int id) {
    final uri = '${AppConstants.savingsDestroyUri}/$id';
    return apiClient.deleteData(uri);
  }

  /// 6) Deposit -> POST /api/v1/savings/{id}/deposit
  Future<Response> deposit(int id, Map<String, dynamic> body) {
    final uri = '${AppConstants.savingsDepositUri}/$id/deposit';
    return apiClient.postData(uri, body);
  }

  /// 7) Withdraw -> POST /api/v1/savings/{id}/withdraw
  Future<Response> withdraw(int id, Map<String, dynamic> body) {
    final uri = '${AppConstants.savingsWithdrawUri}/$id/withdraw';
    return apiClient.postData(uri, body);
  }

  // If you need printing receipts, generating reports, etc., replicate them:
  // Future<Response> printTransactionReceiptPdf(int savingsId, int transactionId) => ...
  // Future<Response> generateReports(...) => ...
}
