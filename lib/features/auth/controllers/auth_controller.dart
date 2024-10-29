
import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/features/a_field_office/clients/domain/client.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientProfile.dart';
import 'package:six_cash/features/a_field_office/clients/domain/clientShortData.dart';
import 'package:six_cash/features/a_field_office/home/domain/AgentTodaysLoans.dart';
// import 'package:six_cash/features/a_field_office/loans/domain/userLoan.dart';
import 'package:six_cash/features/a_field_office/loans/loans/domain/userLoan.dart';
import 'package:six_cash/features/camera_verification/controllers/qr_code_scanner_controller.dart';
import 'package:six_cash/features/setting/domain/models/profile_model.dart';
import 'package:six_cash/features/transaction_money/controllers/bootom_slider_controller.dart';
import 'package:six_cash/features/setting/controllers/profile_screen_controller.dart';
import 'package:six_cash/features/camera_verification/controllers/camera_screen_controller.dart';
import 'package:six_cash/features/splash/controllers/splash_controller.dart';
import 'package:six_cash/features/verification/controllers/verification_controller.dart';
import 'package:six_cash/data/api/api_checker.dart';
import 'package:six_cash/data/api/api_client.dart';
import 'package:six_cash/common/models/signup_body_model.dart';
import 'package:six_cash/common/models/response_model.dart';
import 'package:six_cash/features/auth/domain/models/user_short_data_model.dart';
import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';
import 'package:six_cash/helper/route_helper.dart';
import 'package:six_cash/util/app_constants.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';

import '../../a_field_office/clients/domain/clientQrCode.dart';
import 'dart:convert';  // For json encoding and decoding
import 'package:http/http.dart' as http;  // Import http package for making HTTP requests
import 'package:get/get.dart';
import 'package:flutter/material.dart';
class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
    _biometric = authRepo.isBiometricEnabled();
    checkBiometricSupport();
  }

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

  UserShortDataModel? userData;
  String? phoneNumberUser;
  List<UserLoan>? _userLoans;
  List<UserLoan>? get userLoans => _userLoans;

// fetch todays scheduled by the agent
List<DataContent> _agentTodaySche = [];
List<DataContent> get agentTodaySche => _agentTodaySche;





String? _clientInfo;



 String? _clientCode;

  String? get clientCode => _clientCode;

  Future<String?> getClientQrCode(int id) async {
     _isLoading = true;
    Response response = await authRepo.getclientData(id);
    if (response.statusCode == 200) {
      _clientCode = response.body['qr_code'];
      print('___________#code \n___________${_clientCode}');
      update(); // Notify GetX to rebuild the UI
       _isLoading = false;
      return _clientCode;
    } else {
      // Handle error
      print('Failed to load client QR code');
      _isLoading = false;
      return null;
    }
  }

void resetClient(){
  _clientCode = null;
  _isLoading = false;
  // _agentTodaySche = [];
  // _loanAmount = 0;
}



// get client QR code
Future<void> getClientQrCode2() async {
  Response response = await authRepo.getclientData(59);
  if (response.statusCode == 200) {
    // final clientQrCode = clientQrCodeFromJson(response.body);
    // _clientInfo = clientQrCode;

    print('\n \n this is the code\n \n \n ${response.body['qr_code']}');
  } else {
    // Handle error
    print('\n \n \n \n \n Failed to load client QR code');
  }
}

// pay loan
// https://kansanga.sanaa.co/api/v1/loans/pay?client_id=59&amount=1973
Future<void> payLoan10(int clientId, int amount) async {
  try {
    // Retrieve saved customer data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');

    if (savedCustomerDataJson != null) {
      // Decode the saved customer data
      Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      var addedBy = savedCustomerData['id'];

      // Make API call to pay loan
      Response response = await authRepo.payLoan(clientId, amount, addedBy );

      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        showCustomSnackBarHelper('Payment Successful',isError: false);
        Get.defaultDialog(
          title: 'Payment Successful',
          middleText: 'your Balance is ${ response.body['remaining_balance']}',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
            // Get.back(); // Close the dialog
            Get.find<QrCodeScannerController>().resetValues();
            Get.find<AuthController>().getUserData();
          },
          barrierDismissible: false, // Prevent closing the dialog by tapping outside
        );

        

      } else {
        // Handle failed payment
        print("Loan payment failed: ${response.body['message']}");
      }
    } else {
      print("No customer data found in SharedPreferences.");
    }
  } catch (e) {
    // Handle any other errors
    print("Error occurred while paying loan: $e");
  }
}

  bool _isLoading2 = false;

  // Getter for isLoading
  bool get isLoading2 => _isLoading2;

  Future<void> payLoan(int clientId, int amount) async {
    try {
      _isLoading2 = true;
      update(); // Trigger UI update

      // Retrieve saved customer data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedCustomerDataJson = prefs.getString('customerData');

      if (savedCustomerDataJson != null) {
        // Decode the saved customer data
        Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
        var addedBy = savedCustomerData['id'];

        // Make API call to pay loan
        Response response = await authRepo.payLoan(clientId, amount, addedBy);

        if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
          showCustomSnackBarHelper('Payment Successful', isError: false);
          Get.defaultDialog(
            title: 'Payment Successful',
            middleText: 'Your Balance is ${response.body['remaining_balance']}',
            textConfirm: 'OK',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
              Get.find<QrCodeScannerController>().resetValues();
              Get.find<AuthController>().getUserData();
            },
            barrierDismissible: false, // Prevent closing the dialog by tapping outside
          );
        } else {
          // Handle failed payment
          print("Loan payment failed: ${response.body['message']}");
        }
      } else {
        print("No customer data found in SharedPreferences.");
      }
    } catch (e) {
      // Handle any other errors
      print("Error occurred while paying loan: $e");
    } finally {
      _isLoading2 = false;
      update(); // Trigger UI update to remove the loading indicator
    }
  }

Future<void> getTodayScheduledLoans() async {
  try {
    // Retrieve saved customer data from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');

    if (savedCustomerDataJson != null) {
      // Decode the saved customer data
      Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      var addedBy = savedCustomerData['id'];

      // Make API call to fetch today's scheduled loans
      Response response = await authRepo.todayScheduledLoans(addedBy);

      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        // Parse the response into AgentTodaysLoans model
        final AgentTodaysLoans agentTodaysLoans = AgentTodaysLoans.fromJson(response.body);

        // Update the _agentTodaySche list with the fetched data
        _agentTodaySche = agentTodaysLoans.dataContent ?? [];
        print("______________agentTodaySche_______________\n____________${_agentTodaySche.length}____loans____________________");

      } else {
        // Handle unexpected API response
        ApiChecker.checkApi(response);
      }
    } else {
      // Handle missing or invalid customer data
      print("Error: No customer data found in SharedPreferences.");
    }
  } catch (e) {
    // Handle exceptions
    print("Exception: $e");
  } finally {
    // If you have any loading indicator, you can stop it here
    update(); // Update the UI by calling GetX's update method
  }
}





  Future<void> getUserLoans({bool isReload = false}) async {
    if (_userLoans == null || isReload) {
      
      Response response = await authRepo.userLoansList('1');


      if (response.body['response_code'] == 'default_200' && response.body['content'] != null) {
        _userLoans = userLoanFromJsonList(response.body['content']);
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

   // Method to reset user loans
  void resetUserLoans() {
    _userLoans = null;
    update();  
  }
  // var customer = {}.obs;
  var customer = <String, dynamic>{}.obs;

  var isLoadingCustomer = true.obs;

 


Future<void> getUserByPhone(String phone) async {
  try {
    isLoadingCustomer(true);
    print("_____________\n____Requesting customer by phone:__________\n__________\n__________\n__________\n");

    // Define the URL for the POST request
    final url = Uri.parse('https://kansanga.sanaa.co/api/v1/getUserByPhone');

    // Make the POST request, sending the phone number in the body
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
      }),
    );

    // Check if the response was successful
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      customer.value = responseData['customer'];
      
      // Print customer data for debugging
      print("_____________\n____Customer retrieved:__________\n____${customer.value}______\n__________\n__________\n");
      
      // Save customer data to shared preferences
      await saveCustomerData(customer.value);
    } else {
      // Handle the case where the server returns a non-200 status code
      Get.snackbar("Error", "User not found");
      print('Error: Failed to load customer. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  } catch (e) {
    // Handle any errors that occur during the request
    Get.snackbar("Error", e.toString());
    print('Error occurred: $e');
  } finally {
    // Set loading state to false
    isLoadingCustomer(false);
  }
}




  Future<Response> login({String? code, String? phone, String? password}) async {
    _isLoading = true;
    update();

    Response response = await authRepo.login(phone: phone, password: password, dialCode: code);

    if (response.statusCode == 200 && response.body['response_code'] == 'auth_login_200' && response.body['content'] != null) {
       authRepo.saveUserToken(response.body['content']).then((value) async {
         await authRepo.updateToken();
       });
      if(Get.currentRoute != RouteHelper.navbar) {
        Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
        // getCustomerData();
        getUserByPhone('+256$phone');
      }
    }
    else{
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return response;
  }



// Function to save customer data in SharedPreferences
  Future<void> saveCustomerData(Map<String, dynamic> customerData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerDataJson = jsonEncode(customerData);
    await prefs.setString('customerData', customerDataJson);

    // Retrieve and verify saved customer data
    String? savedCustomerDataJson = prefs.getString('customerData');
    if (savedCustomerDataJson != null) {
      Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
      var userId = savedCustomerData['id'];

      if (kDebugMode) {
        print('________________________________________________________________');
        print('Saved customer data: $savedCustomerData');
        print('________________________________________________________________');
        print('User ID: $userId');
        print('________________________________________________________________');
      }
    }
  }


Future<void> getCustomerData() async {
  try {
    _isLoading = true;
    update();

    userData = Get.find<AuthController>().getUserData();
    phoneNumberUser = userData!.phone!;

    Response response = await authRepo.getCustomerData(phoneNumber: "%2B256${phoneNumberUser}");

           print('_____________\n_____________\n_____________print ${response.body['customer']}  \n_____________\n_____________\n_____________phone: %2B256${phoneNumberUser}\n_____________\n');

    if (response.statusCode == 200) {
      if (response.body['user_type'] == 'customer') {
       
           print('_____________\n_____________\n_____________print ${response.body['customer']} \n_____________\n_____________\n');

      } else {
        // Handle the case for agents or other user types
         var customerData = response.body['customer'];
             print('_____________\n_____________\n_____________print ${response.body['customer']} \n_____________\n_____________\n');


        // Save customer data in shared preferences as a JSON string
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String customerDataJson = jsonEncode(customerData);
        await prefs.setString('customerData', customerDataJson);

        // Retrieve and print the customer data to verify it is saved
        String? savedCustomerDataJson = prefs.getString('customerData');
        Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
        var userId = savedCustomerData['id'];
        if (kDebugMode) {
          print('________________________________________________________________');
          print('________________________________________________________________'); print('________________________________________________________________');
          print('Saved customer data: $savedCustomerData');
                print('________________________________________________________________'); 
                print('_______________________________${userId}_________________________________');
                 print('________________________________________________________________');

       
        }  // return userId;
      }
    } else {
      // Handle non-200 status codes
      if (kDebugMode) {
        print('Error: ${response.statusCode}');
      }
    }
  } catch (e) {
    // Handle exceptions
    if (kDebugMode) {
      print('Exception: $e');
    }
  } finally {
    _isLoading = false;
    update();
  }
}




double _loanAmount = 0;
double get loanAmount => _loanAmount;

double _loanAmountCollected = 0;
double get loanAmountCollected => _loanAmountCollected;


 String get formattedLoanAmount {
    final formatter = NumberFormat('#,##0');
    return formatter.format(_loanAmount);
  }

  String get formattedLoanAmountCollected {
    final formatter = NumberFormat('#,##0');
    return formatter.format(_loanAmountCollected);
  }
  // var _isLoading = false.obs;
  // bool get isLoading => _isLoading.value;

  Future<void> getAgentLoanAmount() async {
    _isLoading = true;

    // Retrieve the agent ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');

    // Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
    //   var addedBy = savedCustomerData['id'];

   
    if (savedCustomerDataJson != null) {
          // Decode the saved customer data
          Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
          var addedBy = savedCustomerData['id'];

        try {
          // Make the API call to fetch the loan amount for the agent
            Response response = await authRepo.getAgentLoanAmount(addedBy);

            

            // var responseBody = jsonDecode(response.body);
            print('___________##___________${response.body['total_amount'] }');

            _loanAmount = double.parse(response.body['total_amount'].toString());
            _loanAmountCollected = double.parse(response.body['collected'].toString());
      

            print(response.body);

            if (response.statusCode == 200) {
              var responseBody = jsonDecode(response.body);

            
            } else {
              // Handle non-200 status codes
              if (kDebugMode) {
                print('Error: ${response.statusCode}');
              }
            }
          } catch (e) {
            // Handle exceptions
            if (kDebugMode) {
              print('Exception: $e');
            }
          } finally {
            _isLoading = false;
            update();
          }
        } 

        // Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson);
        // var agentId = savedCustomerData['id'];

    
  }


ClientProfile? _clientProfile;
  ClientProfile? get clientProfile => _clientProfile;
// get client profile
// final clientProfile = clientProfileFromJson(jsonString);
 Future<void> getClientProfile(int id) async {
  _isLoading = true;
  update();

  Response response = await authRepo.getClientProfile(id);

  if (response.body['response_code'] == 'default_200' && response.body['content'] != null) {
    if (kDebugMode) {
      print('____________________________________');
      print('____________________________________');
      print('______client data_________${response.body['content']}_____________________');
      print('____________________________________');
      print('____________________________________');
      print('____________________________________');
    }

    // Parsing content correctly
    _clientProfile = ClientProfile.fromJson({"content": response.body['content']});
  } else {
    ApiChecker.checkApi(response);
  }

  _isLoading = false;
  update();
}



 List<Clients> _clientList = [];
 List<Clients> get clients => _clientList;
 

 Future<void> getClients() async {
      _isLoading = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
      update();
 
        Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
        var userId = savedCustomerData['id'];
      Response response = await authRepo.getClients(userId);

      if (response.body['response_code'] == 'default_200' && response.body['content'] != null) {
        print('____________________________________');
        print('____________________________________');
        print('_______________${response.body['content']}_____________________');
        print('____________________________________');
        print('____________________________________');
        print('____________________________________');
        
        // Parsing content correctly
        _clientList = clientsFromJson(json.encode(response.body));
        
      } else {
        ApiChecker.checkApi(response);
      }

      _isLoading = false;
      update();
  }





    Future<void> _callSetting() async {
      final LocalAuthentication bioAuth = LocalAuthentication();
      _bioList = await bioAuth.getAvailableBiometrics();
      if(_bioList.isEmpty){
        try{
          AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
        }catch(e){
          debugPrint('error ===> $e');
        }
      }
    }

    Future<void> updatePin(String pin) async {
      await authRepo.writeSecureData(AppConstants.biometricPin, pin);
    }

    bool setBiometric(bool isActive) {
      _callSetting().then((value) {
        _callSetting();
      });

      final String? pin = Get.find<BottomSliderController>().pin;
      Get.find<ProfileController>().pinVerify(getPin: pin, isUpdateTwoFactor: false).then((response) async {
        if(response.statusCode == 200 && response.body != null) {
          _biometric = isActive;
          authRepo.setBiometric(isActive && _bioList.isNotEmpty);
          try{
            await authRepo.writeSecureData(AppConstants.biometricPin, pin);
          }catch(error) {
            debugPrint('error ===> $error');
          }
          Get.back(closeOverlays: true);
          update();
        }
      });

    return _biometric;
  }


  Future<String> biometricPin() async {
      return await  authRepo.readSecureData(AppConstants.biometricPin);
  }

  Future<void> removeBiometricPin() async {
    return await  authRepo.deleteSecureData(AppConstants.biometricPin);
  }

  void checkBiometricWithPin() async {
    if(_biometric && (await biometricPin() == ''))  {
      authRepo.setBiometric(false).then((value) => _biometric = authRepo.isBiometricEnabled());
    }
  }

  Future<void> authenticateWithBiometric(bool autoLogin, String? pin) async {
    final LocalAuthentication bioAuth = LocalAuthentication();
    _bioList = await bioAuth.getAvailableBiometrics();
    if((await bioAuth.canCheckBiometrics || await bioAuth.isDeviceSupported()) && authRepo.isBiometricEnabled()) {
      final List<BiometricType> availableBiometrics = await bioAuth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty && (!autoLogin || await biometricPin() != '')) {
        try {
          final bool didAuthenticate = await bioAuth.authenticate(
            localizedReason: autoLogin ? 'please_authenticate_to_login'.tr : 'please_authenticate_to_easy_access_for_next_time'.tr,
            options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
          );
          if(didAuthenticate) {
            if(autoLogin) {
              login(code: getUserData()?.countryCode, phone: getUserData()?.phone, password: await biometricPin());
            }else{
              authRepo.writeSecureData(AppConstants.biometricPin, pin);
            }
          }else{
            if(pin != null) {
              authRepo.setBiometric(false);
            }
          }
        } catch(e) {
          bioAuth.stopAuthentication();
        }
      }
    }
  }

  void checkBiometricSupport() async {
    final LocalAuthentication bioAuth = LocalAuthentication();
    _isBiometricSupported = await bioAuth.canCheckBiometrics || await bioAuth.isDeviceSupported();
  }

  Future<Response> checkPhone(String phone) async{
      _isLoading = true;
      update();
      Response response = await authRepo.checkPhoneNumber(phoneNumber: phone);

      if(response.statusCode == 200){
        if(!Get.find<SplashController>().configModel!.phoneVerification!) {
          requestCameraPermission(fromEditProfile: false);
        }else if(response.body['otp'] == "active"){
         Get.find<VerificationController>().startTimer();
         Get.toNamed(RouteHelper.getVerifyRoute());
        }else{
          
        }

      }
      else if(response.statusCode == 403 && response.body['user_type'] == 'customer'){

        PhoneNumber phoneNumber = PhoneNumber.parse(phone);
        String numberWithCountryCode = phoneNumber.international;

        String? countryCode = phoneNumber.countryCode;
        String? nationalNumber = numberWithCountryCode.replaceAll(countryCode, '');

        authRepo.setBiometric(false);
        Get.offNamed(RouteHelper.getLoginRoute(countryCode: countryCode,phoneNumber: nationalNumber));

      }
      else{
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
      return response;
    }


  Future<void> requestCameraPermission({required bool fromEditProfile}) async {
    var serviceStatus = await Permission.camera.status;

    if(serviceStatus.isGranted && GetPlatform.isAndroid){
      Get.offNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
    }else{
      if(GetPlatform.isIOS){
        Get.offNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
      }else{
        final status = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          Get.offNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
        } else if (status == PermissionStatus.denied) {
          Get.find<CameraScreenController>().showDeniedDialog(fromEditProfile: fromEditProfile);
        } else if (status == PermissionStatus.permanentlyDenied) {
          Get.find<CameraScreenController>().showPermanentlyDeniedDialog(fromEditProfile: fromEditProfile);
        }
      }

    }
  }

    //Phone Number verification
  Future<ResponseModel> phoneVerify(String phoneNumber,String otp) async{
    _isLoading = true;
    update();
    Response response = await authRepo.verifyPhoneNumber(phoneNumber: phoneNumber, otp: otp);

    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body["message"]);
      Get.find<VerificationController>().cancelTimer();
      showCustomSnackBarHelper(responseModel.message, isError: false);
      requestCameraPermission(fromEditProfile: false);
    }
    else{
      responseModel = ResponseModel(false, response.body['errors'][0]['message']);
      showCustomSnackBarHelper(
          responseModel.message,
          isError: true);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  // registration ..
  Future<Response> registration(SignUpBodyModel signUpBody,List<MultipartBody> multipartBody) async{
      _isLoading = true;
      update();

      Map<String, String> allCustomerInfo = {
        'f_name': signUpBody.fName ?? '',
        'l_name': signUpBody.lName ?? '',
        'phone': signUpBody.phone!,
        'dial_country_code': signUpBody.dialCountryCode!,
        'password': signUpBody.password!,
        'gender': signUpBody.gender!,
        'occupation': signUpBody.occupation ?? '',
      };
      if(signUpBody.otp != null) {
        allCustomerInfo.addAll({'otp': signUpBody.otp!});
      }
      if(signUpBody.email != '') {
        allCustomerInfo.addAll({'email': signUpBody.email!});
      }

      Response response = await authRepo.registration(allCustomerInfo, multipartBody);

      if (response.statusCode == 200) {
        Get.find<CameraScreenController>().removeImage();

        await setUserData(UserShortDataModel(
          countryCode: signUpBody.dialCountryCode,
          phone: signUpBody.phone,
          name: '${signUpBody.fName} ${signUpBody.lName}'
        ));

        Get.offAllNamed(RouteHelper.getWelcomeRoute(
          countryCode: signUpBody.dialCountryCode,phoneNumber: signUpBody.phone,
          password: signUpBody.password,
        ));

      } else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
      return response;
  }


  Future removeUser() async {

    _isLoading = true;
    update();
    Get.back();
    Response response = await authRepo.deleteUser();

    if (response.statusCode == 200) {
      Get.find<SplashController>().removeSharedData();
      showCustomSnackBarHelper('your_account_remove_successfully'.tr);
      Get.offAllNamed(RouteHelper.getSplashRoute());
    }else{
      Get.back();
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }


  Future<Response> checkOtp()async{
      _isLoading = true;
      update();
      Response  response = await authRepo.checkOtpApi();
      if(response.statusCode == 200){
        _isLoading = false;
      }else{
        _isLoading = false;
        ApiChecker.checkApi(response);
      }
      update();
      return response;
  }

  Future<Response> verifyOtp(String otp)async{
    _isVerifying = true;
    update();
    Response  response = await authRepo.verifyOtpApi(otp: otp);
    if(response.statusCode == 200){
      _isVerifying = false;
      Get.back();
    }else{
      Get.back();
      ApiChecker.checkApi(response);
      _isVerifying = false;
    }
    _isVerifying = false;
    update();
    return response;
  }


  Future<Response> logout() async {
    _isLoading = true;
    update();
    Response response = await authRepo.logout();
    if (response.statusCode == 200) {

      Get.offAllNamed(RouteHelper.getSplashRoute());
      _isLoading = false;
    }
    else{
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<ResponseModel?> otpForForgetPass(String phoneNumber) async{
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassOtp(phoneNumber: phoneNumber);
    ResponseModel? responseModel;

    if(response.statusCode == 200){
      _isLoading = false;
      Get.toNamed(RouteHelper.getVerifyRoute(phoneNumber: phoneNumber));
    }
    else{
      _isLoading = false;
      ApiChecker.checkApi(response);

    }
    update();
    return responseModel;
  }

  Future<Response> verificationForForgetPass(String? phoneNumber, String otp) async{
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassVerification(phoneNumber: phoneNumber,otp: otp);

    if(response.statusCode == 200){
      _isLoading = false;
      Get.offNamed(RouteHelper.getFResetPassRoute(phoneNumber: phoneNumber, otp: otp));
    }
    else{
      _isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }


  String? getAuthToken() {
    return authRepo.getUserToken();
  }


  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  void removeCustomerToken() {
    authRepo.removeCustomerToken();
  }



  Future setUserData(UserShortDataModel userData) async {
    await authRepo.setUserData(userData);
  }
  UserShortDataModel? getUserData(){
    UserShortDataModel? userData;
    if(authRepo.getUserData() != '') {
      userData = UserShortDataModel.fromJson(jsonDecode(authRepo.getUserData()));
    }
    return userData;
  }

  void removeUserData()=>  authRepo.removeUserData();
}
