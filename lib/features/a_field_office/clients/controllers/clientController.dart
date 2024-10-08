// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:local_auth/local_auth.dart';
// import 'package:phone_numbers_parser/phone_numbers_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:six_cash/common/models/signup_body_model.dart';
// import 'package:six_cash/data/api/api_checker.dart';
// import 'package:six_cash/data/api/api_client.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/client.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPage.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPagePending.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPaidClients.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/searchClientsLoansPage%20copy.dart';
// import 'package:six_cash/features/auth/domain/models/user_short_data_model.dart';
// import 'package:six_cash/features/camera_verification/controllers/camera_screen_controller.dart';
// import 'package:six_cash/helper/custom_snackbar_helper.dart';
// import 'package:six_cash/helper/route_helper.dart';

// import '../../../auth/domain/reposotories/auth_repo.dart';
// import '../../../splash/controllers/splash_controller.dart';
// import '../../../verification/controllers/verification_controller.dart';

// class ClientController extends GetxController implements GetxService {
//   final AuthRepo authRepo = Get.find<AuthRepo>();

//   // Biometric-related fields
//   bool _isLoading = false;
//   bool _isVerifying = false;
//   bool _biometric = true;
//   bool _isBiometricSupported = false;
//   List<BiometricType> _bioList = [];

//   List<BiometricType> get bioList => _bioList;
//   bool get isLoading => _isLoading;
//   bool get isVerifying => _isVerifying;
//   bool get biometric => _biometric;
//   bool get isBiometricSupported => _isBiometricSupported;

//   var isLoadingData = true.obs;
//   var clientsList = <ClientsDatum>[].obs;
//   var totalClients = 0.obs;

//   var clientsListPending = <ClientsDatumPending>[].obs;
//   var totalClientsPending = 0.obs;

//   var clientsListPaid = <ClientsDatumPaid>[].obs;
//   var totalClientsPaid = 0.obs;
  
//   String get phone => 'null';

//   @override
//   Future<void> onInit() async {
//     super.onInit();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedCustomerDataJson = prefs.getString('customerData');
//     Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
//     var addedBy = savedCustomerData['id'];

//     _fetchAllClientData(addedBy);
//   }

//   void _fetchAllClientData(int addedBy) {
//     fetchClientsWithRunningLoans(addedBy);
//     fetchClientsWithPendingLoans(addedBy);
//     fetchClientsWithPaidLoans(addedBy);
//   }

//   @override
//   void onClose() {
//     _resetClientData();
//     super.onClose();
//   }

//   void _resetClientData() {
//     clientsList.clear();
//     totalClients.value = 0;
//     clientsListPending.clear();
//     totalClientsPending.value = 0;
//     clientsListPaid.clear();
//     totalClientsPaid.value = 0;
//   }

//   // Fetch clients with running loans
//   Future<void> fetchClientsWithRunningLoans(int agentId) async {
//     await _fetchClientData(
//       agentId,
//       'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-running-loans',
//       (data) => clientsList.value = ClientsLoansPage.fromJson(data).data ?? [],
//       (data) => totalClients.value = ClientsLoansPage.fromJson(data).totalClients ?? 0,
//     );
//   }


//   var searchClientsList = <searchClientsDatum>[].obs; // Observable client list
//   var isSearchLoadingData = true.obs;  // Observable loading state
//   var totalSearchClients = 0.obs;  // Observable total clients

//   // Function to search clients
//   Future<void> searchClients(String query) async {
//   isSearchLoadingData(true);  // Set loading state to true
//   try {
//     final response = await http.get(
//       Uri.parse('http://maslink.sanaa.co/api/v1/clients/search?q=$query'),  // Search API
//     );

//     if (response.statusCode == 200) {
//       var jsonResponse = json.decode(response.body);
//       var data = jsonResponse['data'] as List;
//       searchClientsList.value = data.map((item) => searchClientsDatum.fromJson(item)).toList();  // Update the client list
//       totalSearchClients.value = jsonResponse['total'];  // Update the total number of clients
//     } else {
//       print('Error 2: Failed to load clients. Status Code: ${response.statusCode}');
//       print('Error 2: Response Body: ${response.body}');
//       Get.snackbar('Error 2', 'Failed to load clients');
//     }
//   } catch (e, stackTrace) {
//     print('Error 1: An error occurred: $e');
//     print('StackTrace: $stackTrace');
//     Get.snackbar('Error 1', 'An error occurred: $e');
//   } finally {
//     isSearchLoadingData(false);  // Set loading state to false
//   }
// }



//   // Fetch clients with pending loans
//   Future<void> fetchClientsWithPendingLoans(int agentId) async {
//     await _fetchClientData(
//       agentId,
//       'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-pending-loans',
//       (data) => clientsListPending.value = ClientsLoansPagePending.fromJson(data).data ?? [],
//       (data) => totalClientsPending.value = ClientsLoansPagePending.fromJson(data).totalClients ?? 0,
//     );
//   }

//   // Fetch clients with paid loans
//   Future<void> fetchClientsWithPaidLoans(int agentId) async {
//     await _fetchClientData(
//       agentId,
//       'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-paid-loans',
//       (data) => clientsListPaid.value = ClientsLoansPagePaid.fromJson(data).data ?? [],
//       (data) => totalClientsPaid.value = ClientsLoansPagePaid.fromJson(data).totalClients ?? 0,
//     );
//   }

//   // Abstracted function for fetching client data
//   Future<void> _fetchClientData(
//     int agentId,
//     String url,
//     Function(Map<String, dynamic>) onDataSuccess,
//     Function(Map<String, dynamic>) onTotalSuccess,
//   ) async {
//     try {
//       isLoadingData(true);
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         var jsonData = json.decode(response.body);
//         onDataSuccess(jsonData);
//         onTotalSuccess(jsonData);
//       } else {
//         _showErrorSnackbar('Failed to load client data');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Something went wrong: $e');
//     } finally {
//       isLoadingData(false);
//     }
//   }

//   // Error Snackbar helper
//   void _showErrorSnackbar(String message) {
//     Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
//   }

//   // Phone number verification
//   Future<Response> checkPhone(String phone) async {
//     _setLoading(true);

//     Response response = await authRepo.checkPhoneNumber(phoneNumber: phone);
//     if (response.statusCode == 200) {
//       await _handlePhoneCheckSuccess(response, phone);
//     } else {
//       await _handlePhoneCheckError(response);
//     }

//     _setLoading(false);
//     return response;
//   }

//   Future<void> _handlePhoneCheckSuccess(Response response, String phone) async {
//     if (!Get.find<SplashController>().configModel!.phoneVerification!) {
//       // requestCameraPermission();
//     } else if (response.body['otp'] == "active") {
//       Get.find<VerificationController>().startTimer();
//       Get.toNamed(RouteHelper.getVerifyRoute());
//     } else {
//       showCustomSnackBarHelper(response.body['message']);
//     }
//   }

//   Future<void> _handlePhoneCheckError(Response response) async {
//     if (response.statusCode == 403 && response.body['user_type'] == 'customer') {
//       PhoneNumber phoneNumber = PhoneNumber.parse(phone);
//       String numberWithCountryCode = phoneNumber.international;
//       String? countryCode = phoneNumber.countryCode;
//       String? nationalNumber = numberWithCountryCode.replaceAll(countryCode, '');

//       authRepo.setBiometric(false);
//       Get.offNamed(RouteHelper.getLoginRoute(
//         countryCode: countryCode,
//         phoneNumber: nationalNumber,
//       ));
//     } else {
//       ApiChecker.checkApi(response);
//     }
//   }

//   // User Registration
//   Future<Response> registration(SignUpBodyModel signUpBody, List<MultipartBody> multipartBody) async {
//     _setLoading(true);

//     Map<String, String> customerInfo = _prepareCustomerInfo(signUpBody);
//     Response response = await authRepo.registration(customerInfo, multipartBody);

//     if (response.statusCode == 200) {
//       _handleSuccessfulRegistration(signUpBody);
//     } else {
//       ApiChecker.checkApi(response);
//     }

//     _setLoading(false);
//     return response;
//   }

//   Map<String, String> _prepareCustomerInfo(SignUpBodyModel signUpBody) {
//     final info = {
//       'f_name': signUpBody.fName ?? '',
//       'l_name': signUpBody.lName ?? '',
//       'phone': signUpBody.phone!,
//       'dial_country_code': signUpBody.dialCountryCode!,
//       'password': signUpBody.password!,
//       'gender': signUpBody.gender!,
//       'occupation': signUpBody.occupation ?? '',
//     };

//     if (signUpBody.otp != null) info['otp'] = signUpBody.otp!;
//     if (signUpBody.email!.isNotEmpty) info['email'] = signUpBody.email!;

//     return info;
//   }

//   void _handleSuccessfulRegistration(SignUpBodyModel signUpBody) {
//     Get.find<CameraScreenController>().removeImage();
//     Get.offAllNamed(RouteHelper.getWelcomeRoute(
//       countryCode: signUpBody.dialCountryCode,
//       phoneNumber: signUpBody.phone,
//       password: signUpBody.password,
//     ));
//   }

//   void _setLoading(bool isLoading) {
//     _isLoading = isLoading;
//     update(); // Notify listeners about the change
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/common/models/signup_body_model.dart';
import 'package:six_cash/data/api/api_checker.dart';
import 'package:six_cash/data/api/api_client.dart';
import 'package:six_cash/features/a_field_office/clients/domain/client.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPage.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPagePending.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPageRunning.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientsLoansPaidClients.dart';
import 'package:six_cash/features/a_field_office/clients/domain/searchClientsLoansPage%20copy.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clients_loans_page.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clients_loans_page_pending.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/clients_loans_page_paid.dart';
// import 'package:six_cash/features/a_field_office/clients/domain/search_clients_loans_page.dart';
import 'package:six_cash/features/auth/domain/models/user_short_data_model.dart';
import 'package:six_cash/features/camera_verification/controllers/camera_screen_controller.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';
import 'package:six_cash/helper/route_helper.dart';

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
        Uri.parse('http://maslink.sanaa.co/api/v1/agents/$agentId/clients/total'),
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
       url:'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-running-loans',
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
        Uri.parse('http://maslink.sanaa.co/api/v1/clients/search?q=$query'),  // Search API
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

  // Fetch clients with pending loans
  Future<void> fetchClientsWithPendingLoans(int agentId) async {
    await _fetchClientData(
       agentId: agentId,
      url:'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-pending-loans',
      onDataSuccess:(data) => clientsListPending.value = ClientsLoansPagePending.fromJson(data).data ?? [],
       onTotalSuccess:(data) => totalClientsPending.value = ClientsLoansPagePending.fromJson(data).totalClients ?? 0,
    );
  }

  // Fetch clients with paid loans
  Future<void> fetchClientsWithPaidLoans(int agentId) async {
    await _fetchClientData(
      agentId: agentId,
      url:'http://maslink.sanaa.co/api/v1/agents/$agentId/clients-with-paid-loans',
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
