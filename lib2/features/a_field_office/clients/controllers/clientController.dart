 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/models/signup_body_model.dart';
import '../../../../data/api/api_checker.dart';
import '../../../../data/api/api_client.dart';
import '../domain/PaidClientsToday .dart';
import '../domain/client.dart';
import '../domain/clientsLoansPage.dart';
import '../domain/clientsLoansPagePending.dart';
import '../domain/clientsLoansPageRunning.dart';
import '../domain/clientsLoansPaidClients.dart';
import '../domain/searchClientsLoansPage copy.dart';
import '../domain/unpaidCleantModel.dart'; 
import '../../../auth/domain/models/user_short_data_model.dart';
import '../../../camera_verification/controllers/camera_screen_controller.dart';
import '../../../../helper/custom_snackbar_helper.dart';
import '../../../../helper/route_helper.dart';

import '../../../auth/domain/reposotories/auth_repo.dart';
import '../../../splash/controllers/splash_controller.dart';
import '../../../verification/controllers/verification_controller.dart';

class ClientController extends GetxController implements GetxService {
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final ApiClient apiClient = Get.find<ApiClient>();

  // Biometric-related fields
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _biometric = true;
  bool _isBiometricSupported = false;
  List<BiometricType> _bioList = [];


  var isFetchingPaidTodayNextPage = false.obs;
  var clientsListPaidToday = <DatumPaid>[].obs;
  var currentPaidTodayPage = 1;
  var totalPaidTodayPages = 1;





  List<BiometricType> get bioList => _bioList;
  bool get isLoading => _isLoading;
  bool get isVerifying => _isVerifying;
  bool get biometric => _biometric;
  bool get isBiometricSupported => _isBiometricSupported;

  var isLoadingData = true.obs;
  var clientsList = <ClientsDatum>[].obs;
  var totalClients = 0.obs;

  var clientsListPending = <ClientsDatumPending>[].obs;
  var totalClientsPending = 0.obs;

  var isLoadingUnpaidClientsToday = true.obs;
  var unpaidClientsTodayList = <UPDatum>[].obs;
  var totalUnpaidClientsToday = 0.obs;

  var clientsListUnpaid = <UPDatum>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isFetchingNextPage = false.obs;

  var clientsListPaid = <ClientsDatumPaid>[].obs;
  var totalClientsPaid = 0.obs;
  
  String get phone => 'null';

  @override
  Future<void> onInit() async {
    super.onInit();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    if (savedCustomerDataJson != null) {
      Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      var addedBy = savedCustomerData['id'];
      _fetchAllClientData(addedBy);
    } else {
      _showErrorSnackbar('No customer data found.');
    }
  }

  void _fetchAllClientData(int addedBy) {
    fetchClientsWithRunningLoans(addedBy);
    fetchClientsWithPendingLoans(addedBy);
    fetchClientsWithPaidLoans(addedBy);
    fetchTotalClients(addedBy);
    fetchClientsWithUnpaidLoansToday();
    fetchClientsWhoPaidToday();
  }

  @override
  void onClose() {
    _resetClientData();
    super.onClose();
  }

  void _resetClientData() {
    clientsList.clear();
    totalClients.value = 0;
    clientsListPending.clear();
    totalClientsPending.value = 0;
    clientsListPaid.clear();
    totalClientsPaid.value = 0;
    unpaidClientsTodayList.clear();
    clientsListPaidToday.clear();
  }

Future<void> fetchClientsWhoPaidToday({bool isNextPage = false}) async {
    if (isNextPage) {
      if (isFetchingPaidTodayNextPage.value || currentPaidTodayPage >= totalPaidTodayPages) return;
      isFetchingPaidTodayNextPage(true);
      currentPaidTodayPage++;
    } else {
      isLoadingData(true);
      currentPaidTodayPage = 1;
      clientsListPaidToday.clear();
    }

    final response = await http.get(
      Uri.parse('https://app.sanaa.co/api/v1/getClientsWhoPaidToday?per_page=20&page=$currentPaidTodayPage'),
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var clientsData = ClientsWithpaidLoan.fromJson(jsonData);
      if (isNextPage) {
        clientsListPaidToday.addAll(clientsData.data!);
      } else {
        clientsListPaidToday.value = clientsData.data!;
      }
      totalPaidTodayPages = clientsData.lastPage ?? 1;
    } else {
      Get.snackbar(
        'Error',
        'Failed to load clients who paid today',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }

    isLoadingData(false);
    isFetchingPaidTodayNextPage(false);
  }

// Fetch clients who haven't paid today
Future<void> fetchClientsWithUnpaidLoansToday({bool isNextPage = false}) async {
    if (isNextPage) {
      // If it's the next page and we are already fetching, return early
      if (isFetchingNextPage.value) return;

      // Increment page number
      currentPage.value += 1;

      // If we have already fetched all pages, return early
      if (currentPage.value > totalPages.value) return;

      isFetchingNextPage(true);
    } else {
      // Reset for the initial fetch
      isLoadingData(true);
      currentPage.value = 1;
      clientsListUnpaid.clear();
    }

    try {
      final response = await http.get(
        Uri.parse('https://app.sanaa.co/api/v1/unpaidclients?page=${currentPage.value}&per_page=20'),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var dataModel = ClientsWithUnpaidLoan.fromJson(jsonResponse);

        if (dataModel.data != null) {
          clientsListUnpaid.addAll(dataModel.data!);
          totalPages.value = dataModel.lastPage ?? 1;
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch unpaid clients. Status Code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingData(false);
      isFetchingNextPage(false);
    }
  }













// ClientsLoansPageRunning
  var clientsListRunning = <ClientsDatumRunning>[].obs;
  var totalClientsRunning = 0.obs;

  var totalAClients = 0.obs; // Observable for total clients
  var isLoadingClients = true.obs; // Observable for loading state

  // Method to fetch total clients from the API
  Future<void> fetchTotalClients(int agentId) async {
    isLoadingClients(true); // Set loading to true
    try {
      final response = await http.get(
        Uri.parse('https://app.sanaa.co/api/v1/agents/$agentId/clients/total'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          totalClients.value = data['total_clients'];
        } else {
          Get.snackbar('Error', 'Failed to fetch total clients');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch data from server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoadingClients(false); // Set loading to false
    }
  }

  // Fetch clients with running loans
  Future<void> fetchClientsWithRunningLoans(int agentId) async {
    await _fetchClientData(
      agentId:agentId,
       url:'https://app.sanaa.co/api/v1/agents/$agentId/clients-with-running-loans',
      onDataSuccess:(data) => clientsListRunning.value = ClientsLoansPageRunning.fromJson(data).data ?? [],
       onTotalSuccess:(data) => totalClientsRunning.value = ClientsLoansPageRunning.fromJson(data).totalClients ?? 0,
    );
  }

  var searchClientsList = <searchClientsDatum>[].obs; // Observable client list
  var isSearchLoadingData = true.obs;  // Observable loading state
  var totalSearchClients = 0.obs;  // Observable total clients

  // Function to search clients
  Future<void> searchClients(String query) async {
    isSearchLoadingData(true);  // Set loading state to true
    try {
      final response = await http.get(
        Uri.parse('https://app.sanaa.co/api/v1/clients/search?q=$query'),  // Search API
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var data = jsonResponse['data'] as List;
        searchClientsList.value = data.map((item) => searchClientsDatum.fromJson(item)).toList();  // Update the client list
        totalSearchClients.value = jsonResponse['total'];  // Update the total number of clients
      } else {
        print('Error 2: Failed to load clients. Status Code: ${response.statusCode}');
        print('Error 2: Response Body: ${response.body}');
        Get.snackbar(
          'Error 2',
          'Failed to load clients',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      print('Error 1: An error occurred: $e');
      print('StackTrace: $stackTrace');
      Get.snackbar(
        'Error 1',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSearchLoadingData(false);  // Set loading state to false
    }
  }

  
  // Fetch clients with unpaid loans
  Future<void> fetchClientsWithUnPaidLoans(int agentId) async {
    await _fetchClientData(
      agentId: agentId,
      url:'https://app.sanaa.co/api/v1/agents/$agentId/clients-with-paid-loans',
      onDataSuccess:(data) => clientsListPaid.value = ClientsLoansPagePaid.fromJson(data).data ?? [],
      onTotalSuccess:  (data) => totalClientsPaid.value = ClientsLoansPagePaid.fromJson(data).totalClients ?? 0, 
      
    );
  }

  // Fetch clients with pending loans
  Future<void> fetchClientsWithPendingLoans(int agentId) async {
    await _fetchClientData(
       agentId: agentId,
      url:'https://app.sanaa.co/api/v1/agents/$agentId/clients-with-pending-loans',
      onDataSuccess:(data) => clientsListPending.value = ClientsLoansPagePending.fromJson(data).data ?? [],
       onTotalSuccess:(data) => totalClientsPending.value = ClientsLoansPagePending.fromJson(data).totalClients ?? 0,
    );
  }

  // Fetch clients with paid loans
  Future<void> fetchClientsWithPaidLoans(int agentId) async {
    await _fetchClientData(
      agentId: agentId,
      url:'https://app.sanaa.co/api/v1/agents/$agentId/clients-with-paid-loans',
      onDataSuccess:(data) => clientsListPaid.value = ClientsLoansPagePaid.fromJson(data).data ?? [],
    onTotalSuccess:  (data) => totalClientsPaid.value = ClientsLoansPagePaid.fromJson(data).totalClients ?? 0, 
      
    );
  }

  // Abstracted function for fetching client data
  Future<void> _fetchClientData({
    required int agentId,
    required String url,
    required Function(Map<String, dynamic>) onDataSuccess,
    required Function(Map<String, dynamic>) onTotalSuccess,
  }) async {
    try {
      isLoadingData(true);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        onDataSuccess(jsonData);
        onTotalSuccess(jsonData);
      } else {
        _showErrorSnackbar('Failed to load client data');
      }
    } catch (e) {
      _showErrorSnackbar('Something went wrong: $e');
    } finally {
      isLoadingData(false);
    }
  }

  // Error Snackbar helper
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Phone number verification
  Future<Response> checkPhone(String phone) async {
    _setLoading(true);

    try {
      final response = await authRepo.checkPhoneNumber(phoneNumber: phone);
      if (response.statusCode == 200) {
        await _handlePhoneCheckSuccess(response as http.Response, phone);
      } else {
        await _handlePhoneCheckError(response as http.Response, phone);
      }
      return response;
    } catch (e) {
      print('Error in checkPhone: $e');
      _showErrorSnackbar('An error occurred: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handlePhoneCheckSuccess(http.Response response, String phone) async {
    try {
      final responseBody = json.decode(response.body);
      if (!Get.find<SplashController>().configModel!.phoneVerification!) {
        // requestCameraPermission();
      } else if (responseBody['otp'] == "active") {
        Get.find<VerificationController>().startTimer();
        Get.toNamed(RouteHelper.getVerifyRoute());
      } else {
        showCustomSnackBarHelper(responseBody['message']);
      }
    } catch (e) {
      print('Error in _handlePhoneCheckSuccess: $e');
      _showErrorSnackbar('Failed to process phone verification: $e');
    }
  }

  Future<void> _handlePhoneCheckError(http.Response response, String phone) async {
    try {
      final responseBody = json.decode(response.body);
      if (response.statusCode == 403 && responseBody['user_type'] == 'customer') {
        PhoneNumber phoneNumber = PhoneNumber.parse(phone);
        String numberWithCountryCode = phoneNumber.international;
        String? countryCode = phoneNumber.countryCode;
        String? nationalNumber = numberWithCountryCode.replaceAll(countryCode, '');

        authRepo.setBiometric(false);
        Get.offNamed(RouteHelper.getLoginRoute(
          countryCode: countryCode,
          phoneNumber: nationalNumber,
        ));
      } else {
        ApiChecker.checkApi(response as Response);
      }
    } catch (e) {
      print('Error in _handlePhoneCheckError: $e');
      _showErrorSnackbar('Failed to handle phone check error: $e');
    }
  }

  // User Registration
  Future<Response> registration(SignUpBodyModel signUpBody, List<MultipartBody> multipartBody) async {
    _setLoading(true);

    try {
      Map<String, String> customerInfo = _prepareCustomerInfo(signUpBody);
      final response = await authRepo.registration(customerInfo, multipartBody);

      if (response.statusCode == 200) {
        _handleSuccessfulRegistration(signUpBody);
      } else {
        ApiChecker.checkApi(response);
      }

      return response;
    } catch (e) {
      print('Error in registration: $e');
      _showErrorSnackbar('Registration failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Map<String, String> _prepareCustomerInfo(SignUpBodyModel signUpBody) {
    final info = {
      'f_name': signUpBody.fName ?? '',
      'l_name': signUpBody.lName ?? '',
      'phone': signUpBody.phone!,
      'dial_country_code': signUpBody.dialCountryCode!,
      'password': signUpBody.password!,
      'gender': signUpBody.gender!,
      'occupation': signUpBody.occupation ?? '',
    };

    if (signUpBody.otp != null) info['otp'] = signUpBody.otp!;
    if (signUpBody.email!.isNotEmpty) info['email'] = signUpBody.email!;

    return info;
  }

  void _handleSuccessfulRegistration(SignUpBodyModel signUpBody) {
    try {
      Get.find<CameraScreenController>().removeImage();
      Get.offAllNamed(RouteHelper.getWelcomeRoute(
        countryCode: signUpBody.dialCountryCode,
        phoneNumber: signUpBody.phone,
        password: signUpBody.password,
      ));
    } catch (e) {
      print('Error in _handleSuccessfulRegistration: $e');
      _showErrorSnackbar('Registration succeeded but failed to navigate: $e');
    }
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    update(); // Notify listeners about the change
  }
}
