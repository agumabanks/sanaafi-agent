import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import '../features/a_field_office/clients/controllers/AddGuarantorController.dart';
import '../features/a_field_office/loans/loans/controllers/loanController.dart';
// import 'package:six_cash/features/a_field_office/loans/controllers/LoanController.dart';
// import 'package:six_cash/features/a_field_office/loans/controllers/loanController.dart';
import '../features/forget_pin/domain/reposotories/forget_pin_repo.dart';
import '../features/home/controllers/banner_controller.dart';
import '../features/auth/controllers/create_account_controller.dart';
import '../features/membership/controllers/membership_controller.dart';
import '../features/membership/domain/repos/membership_repo.dart';
import '../features/onboarding/controllers/on_boarding_controller.dart';
import '../features/savings/controllers/savings_controller.dart';
import '../features/savings/domain/savings_repo.dart';
import '../features/setting/controllers/edit_profile_controller.dart';
import '../features/setting/controllers/faq_controller.dart';
import '../features/forget_pin/controllers/forget_pin_controller.dart';
import '../features/transaction_money/controllers/bootom_slider_controller.dart';
import '../features/add_money/controllers/add_money_controller.dart';
import '../features/kyc_verification/controllers/kyc_verify_controller.dart';
import '../features/home/controllers/menu_controller.dart';
import '../features/notification/controllers/notification_controller.dart';
import '../features/camera_verification/controllers/qr_code_scanner_controller.dart';
import '../common/controllers/share_controller.dart';
import '../features/requested_money/controllers/requested_money_controller.dart';
import '../features/camera_verification/controllers/camera_screen_controller.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/language/controllers/language_controller.dart';
import '../features/language/controllers/localization_controller.dart';
import '../features/setting/controllers/profile_screen_controller.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/transaction_money/controllers/contact_controller.dart';
import '../features/transaction_money/controllers/transaction_controller.dart';
import '../features/splash/controllers/splash_controller.dart';
import '../features/setting/controllers/theme_controller.dart';
import '../features/history/controllers/transaction_history_controller.dart';
import '../features/transaction_money/domain/reposotories/contact_repo.dart';
import '../features/verification/controllers/verification_controller.dart';
import '../features/home/controllers/websitelink_controller.dart';
import '../data/api/api_client.dart';
import '../features/add_money/domain/reposotories/add_money_repo.dart';
import '../features/auth/domain/reposotories/auth_repo.dart';
import '../features/home/domain/reposotories/banner_repo.dart';
import '../features/setting/domain/reposotories/faq_repo.dart';
import '../features/notification/domain/reposotories/notification_repo.dart';
import '../features/setting/domain/reposotories/profile_repo.dart';
import '../features/transaction_money/domain/reposotories/transaction_repo.dart';
import '../features/history/domain/reposotories/transaction_history_repo.dart';
import '../features/home/domain/reposotories/websitelink_repo.dart';
import '../features/splash/domain/reposotories/splash_repo.dart';
import '../features/requested_money/domain/reposotories/requested_money_repo.dart';
import '../util/app_constants.dart';
import '../common/models/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
// import 'package:unique_identifier/unique_identifier.dart';

import '../features/kyc_verification/domain/reposotories/kyc_verify_repo.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

import 'package:device_uuid/device_uuid.dart';


Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  final BaseDeviceInfo deviceInfo =  await DeviceInfoPlugin().deviceInfo;
   String? uniqueId =   Uuid().toString() ;

  // final uuid = DeviceUuid().getUUID();
  // final deviceIdentifier = await DeviceIdentifier.id;
  // final _mobileDeviceIdentifier = MobileDeviceIdentifier().getDeviceId();


  Get.lazyPut(() => uniqueId);
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => deviceInfo);


  Get.lazyPut(() => ApiClient(
    appBaseUrl: AppConstants.baseUrl,
    sharedPreferences: Get.find(),
    uniqueId: Get.find(),
    deiceInfo: Get.find(),
  ));


// Typically in your main.dart or a dedicated bindings file:
Get.lazyPut(() => SavingsRepo(
  apiClient: Get.find(),
  sharedPreferences: Get.find(),
));
Get.lazyPut(() => SavingsController(savingsRepo: Get.find()));

  // Repository
   // Now create the membershipRepo and controller
  final membershipRepo = MembershipRepo(apiClient: Get.find());
  Get.put(membershipRepo, permanent: true);

  final membershipController = MembershipController(membershipRepo: Get.find());
  Get.put(membershipController, permanent: false);

  
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => TransactionRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(),sharedPreferences: Get.find()));
  Get.lazyPut(() => ProfileRepo(apiClient: Get.find()));
  Get.lazyPut(() => ProfileRepo(apiClient: Get.find()));
  Get.lazyPut(() => WebsiteLinkRepo(apiClient: Get.find()));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find()));
  Get.lazyPut(() => AddMoneyRepo(apiClient: Get.find()));
  Get.lazyPut(() => FaqRepo(apiClient: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find()));
  Get.lazyPut(() => RequestedMoneyRepo(apiClient: Get.find()));
  Get.lazyPut(() => TransactionHistoryRepo(apiClient: Get.find()));
  Get.lazyPut(() => KycVerifyRepo(apiClient: Get.find()));
  Get.lazyPut(() => ForgetPinRepo(apiClient: Get.find()));
  Get.lazyPut(() => ContactRepo(apiClient: Get.find(), sharedPreferences: Get.find()));

  // Controller
  // AddGuarantorController ClientLoanController
  Get.lazyPut(() => AddGuarantorController());
  Get.lazyPut(() => ClientLoanController());
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
   Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  Get.lazyPut(() => TransactionMoneyController(transactionRepo: Get.find(), authRepo: Get.find()));
  Get.lazyPut(() => AddMoneyController(addMoneyRepo:Get.find() ));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => ProfileController(profileRepo: Get.find()));
  Get.lazyPut(() => FaqController(faqrepo: Get.find()));
  Get.lazyPut(() => BottomSliderController());

  Get.lazyPut(() => MenuItemController());
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => CreateAccountController());
  Get.lazyPut(() => VerificationController());
  Get.lazyPut(() => CameraScreenController());
  Get.lazyPut(() => ForgetPinController(forgetPinRepo: Get.find()));
  Get.lazyPut(() => WebsiteLinkController(websiteLinkRepo: Get.find()));
  Get.lazyPut(() => QrCodeScannerController());
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => TransactionHistoryController(transactionHistoryRepo: Get.find()));
  Get.lazyPut(() => EditProfileController(authRepo: Get.find()));
  Get.lazyPut(() => RequestedMoneyController(requestedMoneyRepo: Get.find()));
  Get.lazyPut(() => ShareController());
  Get.lazyPut(() => KycVerifyController(kycVerifyRepo: Get.find()));
  Get.lazyPut(() => OnBoardingController());
  Get.lazyPut(() => ContactController(contactRepo: Get.find()));



  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = json;
  }
  return languages;
}
