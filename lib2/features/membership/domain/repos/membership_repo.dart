// lib/features/membership/domain/repos/membership_repo.dart

import 'package:get/get.dart';
import '../../../../data/api/api_client.dart';
import '../../../../util/app_constants.dart'; 

class MembershipRepo extends GetxService {
  final ApiClient apiClient;

  MembershipRepo({required this.apiClient});

  // 1) GET /api/memberships
  Future<Response> getAllMemberships() async {
    return apiClient.getData(AppConstants.membershipsIndexUri);
  }

  // 1b) GET /api/memberships/index2
  Future<Response> getAllMembershipsIndex2() async {
    return apiClient.getData(AppConstants.membershipsIndex2Uri);
  }

  // 2) POST /api/memberships
  Future<Response> createMembership(Map<String, dynamic> body) async {
    return apiClient.postData(AppConstants.membershipsStoreUri, body);
  }

  // 3) GET /api/memberships/{id}
  Future<Response> getMembershipById(int id) {
    final String uri = '${AppConstants.membershipsShowUri}/$id';
    return apiClient.getData(uri);
  }

  // 4) PUT /api/memberships/{id}
  Future<Response> updateMembership(int id, Map<String, dynamic> body) {
    final String uri = '${AppConstants.membershipsUpdateUri}/$id';
    return apiClient.putData(uri, body);
  }

  // 5) DELETE /api/memberships/{id}
  Future<Response> deleteMembership(int id) {
    final String uri = '${AppConstants.membershipsDestroyUri}/$id';
    return apiClient.deleteData(uri);
  }

  // 6) GET /api/memberships/{membershipId}/share-history
  Future<Response> getShareHistory(int membershipId) {
    final String uri = '${AppConstants.membershipsShareHistoryUri}/$membershipId/share-history';
    return apiClient.getData(uri);
  }

  // 7) POST /api/memberships/{membershipId}/share-transactions
  Future<Response> storeShareTransaction(int membershipId, Map<String, dynamic> body) {
    final String uri = '${AppConstants.membershipsShareStoreUri}/$membershipId/share-transactions';
    return apiClient.postData(uri, body);
  }

  // 8) POST /api/memberships/transfer-shares
  Future<Response> transferShares(Map<String, dynamic> body) {
    return apiClient.postData(AppConstants.membershipsShareTransferUri, body);
  }

  // 9) GET /api/memberships/{membership}/transaction/{transaction}/pdf
  Future<Response> printTransactionReceiptPdf(int membershipId, int transactionId) {
    final String uri = '${AppConstants.membershipsReceiptPdfUri}/$membershipId/transaction/$transactionId/pdf';
    return apiClient.getData(uri);
  }

  // Additional routes for "index2", "create" endpoints exist, but might not be used by Flutter.

  // Reports
  // GET: /api/memberships/reports
  Future<Response> membershipsReportsIndex() {
    return apiClient.getData(AppConstants.membershipsReportsIndexUri);
  }

  // POST: /api/memberships/reports/generate
  Future<Response> membershipsReportsGenerate(Map<String, dynamic> body) {
    return apiClient.postData(AppConstants.membershipsReportsGenerateUri, body);
  }

  // POST: /api/memberships/reports/export
  Future<Response> membershipsReportsExport(Map<String, dynamic> body) {
    return apiClient.postData(AppConstants.membershipsReportsExportUri, body);
  }

  // Another set: /api/memberships/reports2
  // etc.
}
