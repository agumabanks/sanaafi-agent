// lib/features/membership/controllers/membership_controller.dart

import 'package:get/get.dart';
import '../../../data/api/api_checker.dart';
import '../domain/membership_model.dart';
// import 'package:six_cash/features/membership/domain/models/membership_model.dart';
import '../domain/repos/membership_repo.dart';
import 'package:flutter/foundation.dart';

class MembershipController extends GetxController implements GetxService {
  final MembershipRepo membershipRepo;

  MembershipController({required this.membershipRepo});

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List of memberships
  List<MembershipModel> _membershipList = [];
  List<MembershipModel> get membershipList => _membershipList;

  // Single membership details
  MembershipModel? _selectedMembership;
  MembershipModel? get selectedMembership => _selectedMembership;

  //--------------------------------------------------------------------------
  // 1) Fetch all memberships
  //--------------------------------------------------------------------------
  Future<void> fetchAllMemberships() async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.getAllMemberships();
    if (response.statusCode == 200 && response.body != null) {
      List data = response.body['data'] ?? [];
      _membershipList = data.map((e) => MembershipModel.fromJson(e)).toList().cast<MembershipModel>();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  // 1b) Alternative index2
  Future<void> fetchAllMembershipsIndex2() async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.getAllMembershipsIndex2();
    if (response.statusCode == 200 && response.body != null) {
      List data = response.body['data'] ?? [];
      _membershipList = data.map((e) => MembershipModel.fromJson(e)).toList().cast<MembershipModel>();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 2) Create membership
  //--------------------------------------------------------------------------
  Future<void> createMembership({
    required int userId,
    required String membershipType,
    required bool isPaid,
    required int shares,
    required double shareValue,
    required double membershipFees,
    required int clientId,
    required bool isSharesPaid,
  }) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'user_id': userId,
      'membership_type': membershipType,
      'is_paid': isPaid,
      'shares': shares,
      'share_value': shareValue,
      'membership_fees': membershipFees,
      'client_id': clientId,
      'is_shares_paid': isSharesPaid
    };

    Response response = await membershipRepo.createMembership(body);

    if (response.statusCode == 201 && response.body != null) {
      debugPrint('Membership created: ${response.body}');
      // Optionally refresh the membership list
      fetchAllMemberships();
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 3) Get membership by ID
  //--------------------------------------------------------------------------
  Future<void> getMembershipById(int id) async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.getMembershipById(id);
    if (response.statusCode == 200 && response.body != null) {
      _selectedMembership = MembershipModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 4) Update membership
  //--------------------------------------------------------------------------
  Future<void> updateMembership({
    required int membershipId,
    required int userId,
    required String membershipType,
    required bool isPaid,
  }) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'user_id': userId,
      'membership_type': membershipType,
      'is_paid': isPaid,
    };

    Response response = await membershipRepo.updateMembership(membershipId, body);
    if (response.isOk && response.body != null) {
      debugPrint('Membership updated: ${response.body}');
      // Optionally re-fetch details
      getMembershipById(membershipId);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 5) Delete membership
  //--------------------------------------------------------------------------
  Future<void> deleteMembership(int id) async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.deleteMembership(id);
    if (response.isOk && response.body != null) {
      // Remove from local list
      _membershipList.removeWhere((m) => m.id == id);
      debugPrint('Membership deleted: ${response.body}');
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 6) Get Share History
  //--------------------------------------------------------------------------
  Future<void> getShareHistory(int membershipId) async {
    // Example usage: you might fetch the share history and store it somewhere
    _isLoading = true;
    update();

    Response response = await membershipRepo.getShareHistory(membershipId);
    if (response.isOk && response.body != null) {
      debugPrint('Share history: ${response.body}');
      // Possibly parse it if you want
      // You can store it in a local list
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 7) Store share transaction (deposit or reverse)
  //--------------------------------------------------------------------------
  Future<void> storeShareTransaction({
    required int membershipId,
    required String transactionType, // create or reverse
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'transaction_type': transactionType,
      'amount': amount,
      'description': description,
    };

    Response response = await membershipRepo.storeShareTransaction(membershipId, body);
    if (response.isOk && response.body != null) {
      debugPrint('Share transaction stored: ${response.body}');
      // Optionally refresh membership detail
      getMembershipById(membershipId);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 8) Transfer shares
  //--------------------------------------------------------------------------
  Future<void> transferShares({
    required int fromMembershipId,
    required int toMembershipId,
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'from_membership_id': fromMembershipId,
      'to_membership_id': toMembershipId,
      'amount': amount,
      'description': description,
    };

    Response response = await membershipRepo.transferShares(body);
    if (response.isOk && response.body != null) {
      debugPrint('Transfer shares success: ${response.body}');
      // Possibly refresh membership detail for both fromMembershipId, toMembershipId
      getMembershipById(fromMembershipId);
      getMembershipById(toMembershipId);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  // 9) Print PDF receipt
  //--------------------------------------------------------------------------
  Future<void> printTransactionReceiptPdf(int membershipId, int transactionId) async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.printTransactionReceiptPdf(membershipId, transactionId);
    if (response.isOk && response.body != null) {
      debugPrint('PDF fetched: ${response.body}');
      // Typically you'd get raw PDF data, or a file link
      // Could handle it accordingly
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  //--------------------------------------------------------------------------
  //  Reports (basic examples)
  //--------------------------------------------------------------------------
  Future<void> membershipsReportsIndex() async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.membershipsReportsIndex();
    if (response.isOk && response.body != null) {
      debugPrint('ReportsIndex data: ${response.body}');
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> membershipsReportsGenerate(Map<String, dynamic> body) async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.membershipsReportsGenerate(body);
    if (response.isOk && response.body != null) {
      debugPrint('Reports generated: ${response.body}');
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> membershipsReportsExport(Map<String, dynamic> body) async {
    _isLoading = true;
    update();

    Response response = await membershipRepo.membershipsReportsExport(body);
    if (response.isOk && response.body != null) {
      debugPrint('Reports exported: ${response.body}');
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  // If you need the second sets of reports2, define them similarly

  //--------------------------------------------------------------------------
  // Reset selected membership
  //--------------------------------------------------------------------------
  void resetSelectedMembership() {
    _selectedMembership = null;
    update();
  }
}
