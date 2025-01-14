import 'package:get/get.dart';
import '../common/models/language_model.dart';
import '../common/models/on_boarding_model.dart';
import 'images.dart';

class AppConstants {
  static const String appName = 'Field Agent';
  // static const String baseUrl = 'https://kansanga.sanaa.co'; https://kansanga.sanaa.co/admin mbalala
  static const String baseUrl = 'https://app.sanaa.co';
  static const bool demo = false;
  static const double appVersion = 4.3;

  static const String getClients = '/api/v1/clients';
   static const String getAgentClients = '/api/v1/agentclients';

// Membership URIs
  static const String membershipsIndexUri = '/api/v1/memberships';
  static const String membershipsIndex2Uri = '/api/v1/memberships/index2';
  static const String membershipsStoreUri = '/api/v1/memberships';
  static const String membershipsShowUri = '/api/v1/memberships'; // + /{id}
  static const String membershipsUpdateUri = '/api/v1/memberships'; // + /{id}
  static const String membershipsDestroyUri = '/api/v1/memberships'; // + /{id}
  static const String membershipsShareHistoryUri = '/api/v1/memberships'; // + /{membershipId}/share-history
  static const String membershipsShareStoreUri = '/api/v1/memberships'; // + /{membershipId}/share-transactions
  static const String membershipsShareTransferUri = '/api/v1/memberships/transfer-shares';
  static const String membershipsReceiptPdfUri = '/api/v1/memberships'; // + /{membership}/transaction/{transaction}/pdf

  // membership reports
  static const String membershipsReportsIndexUri = '/api/memberships/reports';
  static const String membershipsReportsGenerateUri = '/api/memberships/reports/generate';
  static const String membershipsReportsExportUri = '/api/memberships/reports/export';


   // ====== Savings Endpoints ======
  // For listing and creating (index & store)
  static const String savingsIndexUri = '/api/v1/savings';        // GET -> index
  static const String savingsStoreUri = '/api/v1/savings';        // POST -> store

  // For show, update, delete: '/api/v1/savings/{id}'
  // You can append '/$id' at call time, e.g. `'$savingsShowUri/$id'`
  static const String savingsShowUri = '/api/v1/savings';         // GET    -> show
  static const String savingsUpdateUri = '/api/v1/savings';       // PUT    -> update
  static const String savingsDestroyUri = '/api/v1/savings';      // DELETE -> destroy

  // For deposit and withdraw: '/api/v1/savings/{id}/deposit' or '/withdraw'
  // You can append '/$id/deposit' or '/$id/withdraw' at call time
  static const String savingsDepositUri = '/api/v1/savings';      // POST -> deposit
  static const String savingsWithdrawUri = '/api/v1/savings';     // POST -> withdraw

  // Transaction receipts
  // '/api/v1/savings/{savings}/transaction/{transaction}/receipt-pdf'
  // '/api/v1/savings/{savings}/transaction/{transaction}/receipt-thermal'
  // Again, append the IDs in your service or repository layer
  static const String savingsReceiptPdfUri = '/api/v1/savings';   
  static const String savingsReceiptThermalUri = '/api/v1/savings';

  // Reports
  static const String savingsReportsIndexUri = '/api/v1/savings/reports';          
  static const String savingsReportsGenerateUri = '/api/v1/savings/reports/generate';
  static const String savingsReportsExportUri = '/api/v1/savings/reports/export';

  // ...

  // aadd client addClientLoan
    static const String addClients = '/api/v1/addclients';
    static const String addClientLoan = '/api/v1/create-loans';
    static const String getClientsProfile = '/api/v1/getClient';
    static const String getClientsLoans = '/api/v1/clientLoans';

    // getClientLoansHistory
    static const String getClientLoansHistory = '/api/v1/clientLoanspayHistory';


      static const String getcustomerDataUri = '/api/v1/getUserByPhone';
      static const String clientguarantorsList = '/api/v1/clientguarantorsList';



      // clientPhotos
       static const String clientPhotos = '/api/v1/clientphotos';
      
  static const String userLoansList = '/api/v1/loan-lists'; ///api/v1/loan-lists/24  getAgentLoanAmount
  static const String getAgentLoanAmount = '/api/v1/today-instal-sum';
// todayScheduledLoans
  static const String todayScheduledLoans = '/api/v1/todaysSchedule'; 

// pay loan
static const String payLoan = '/api/v1/loans/pay';

    
    static const String getClientQr = '/api/v1/getClientQr';
    static const String addClientGuarantor = '/api/v1/addClientGuarantor';




  static const String customerPhoneCheckUri = '/api/v1/customer/auth/check-phone';
  static const String customerPhoneVerifyUri = '/api/v1/customer/auth/verify-phone';
  static const String customerRegistrationUri = '/api/v1/customer/auth/register';
  static const String customerUpdateProfile = '/api/v1/customer/update-profile';
  static const String customerLoginUri = '/api/v1/customer/auth/login';
  static const String customerLogoutUri = '/api/v1/customer/logout';
  static const String customerForgetPassOtpUri = '/api/v1/customer/auth/forgot-password';
  static const String customerForgetPassVerification = '/api/v1/customer/auth/verify-token';
  static const String customerForgetPassReset = '/api/v1/customer/auth/reset-password';
  static const String customerLinkedWebsite= '/api/v1/customer/linked-website';
  static const String customerBanner= '/api/v1/customer/get-banner';
  static const String customerTransactionHistory= '/api/v1/customer/transaction-history';
  static const String customerPurposeUrl = '/api/v1/customer/get-purpose';
  static const String configUri = '/api/v1/config';
  static const String imageConfigUrlApiNeed = '/storage/app/public/purpose/';
  static const String customerProfileInfo = '/api/v1/customer/get-customer';
  static const String customerCheckOtp = '/api/v1/customer/check-otp';
  static const String customerVerifyOtp = '/api/v1/customer/verify-otp';
  static const String customerChangePin = '/api/v1/customer/change-pin';
  static const String customerUpdateTwoFactor = '/api/v1/customer/update-two-factor';
  static const String customerSendMoney = '/api/v1/customer/send-money';
  static const String customerRequestMoney = '/api/v1/customer/request-money';
  static const String customerCashOut = '/api/v1/customer/cash-out';
  static const String customerPinVerify = '/api/v1/customer/verify-pin';
  static const String customerAddMoney = '/api/v1/customer/add-money';
  static const String faqUri = '/api/v1/faq';
  static const String notificationUri = '/api/v1/customer/get-notification';
  static const String transactionHistoryUri = '/api/v1/customer/transaction-history';
  static const String requestedMoneyUri = '/api/v1/customer/get-requested-money';
  static const String acceptedRequestedMoneyUri = '/api/v1/customer/request-money/approve';
  static const String deniedRequestedMoneyUri = '/api/v1/customer/request-money/deny';
  static const String tokenUri = '/api/v1/customer/update-fcm-token';
  static const String checkCustomerUri = '/api/v1/check-customer';
  static const String checkAgentUri = '/api/v1/check-agent';
  static const String wonRequestedMoney = '/api/v1/customer/get-own-requested-money';
  static const String customerRemove = '/api/v1/customer/remove-account';
  static const String updateKycInformation = '/api/v1/customer/update-kyc-information';
  static const String withdrawMethodList = '/api/v1/customer/withdrawal-methods';
  static const String withdrawRequest = '/api/v1/customer/withdraw';
  static const String getWithdrawalRequest = '/api/v1/customer/withdrawal-requests';


  // Shared Key
  static const String theme = 'theme';
  static const String token = 'token';
  static const String customerCountryCode = 'customer_country_code';//not in project
  static const String languageCode = 'language_code';
  static const String topic = 'notify';

  static const String sendMoneySuggestList = 'send_money_suggest';
  static const String requestMoneySuggestList = 'request_money_suggest';
  static const String recentAgentList = 'recent_agent_list';

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String denied = 'denied';
  static const String cashIn = 'cash_in';
  static const String cashOut = 'cash_out';
  static const String sendMoney = 'send_money';
  static const String receivedMoney = 'received_money';
  static const String adminCharge = 'admin_charge';
  static const String addMoney = 'add_money';
  static const String withdraw = 'withdraw';
  static const String payment = 'payment';

  static const String biometricAuth = 'biometric_auth';
  static const String biometricPin = 'biometric';
  static const String contactPermission = '';
  static const String userData = 'user';



  //topic
  static const String all = 'all';
  static const String users = 'customers';

  // App Theme
  static const String theme1 = 'theme_1';
  static const String theme2 = 'theme_2';
  static const String theme3 = 'theme_3';

  //input balance digit length
  static const int balanceInputLen = 10;

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.saudi, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),

  ];

  static  List<OnboardModel> onboardList = [
    OnboardModel(
      Images.onboardImage1,
      Images.onboardBackground1,
      'on_boarding_title_1'.tr,
      '${'send_money_from'.tr} $appName ${'easily_at_anytime'.tr}',
    ),

    OnboardModel(
      Images.onboardImage2, Images.onboardBackground2,
      'on_boarding_title_2'.tr,
      'withdraw_money_is_even_more'.tr,
    ),
    OnboardModel(
      Images.onboardImage3,
      Images.onboardBackground3,
      'on_boarding_title_3'.tr,
      '${'request_for_money_using'.tr} $appName ${'account_to_any_friend'.tr}',
    ),
  ];
}