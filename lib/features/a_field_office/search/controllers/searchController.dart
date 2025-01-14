import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/data/api/api_client.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/features/a_field_office/loans/loans/domain/clientLoanspayHistory.dart';
import 'package:six_cash/features/a_field_office/loans/loans/domain/loan_offermodal.dart';
import 'package:six_cash/features/a_field_office/loans/loans/domain/userLoan.dart';
import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';
import 'package:uuid/uuid.dart';

import '../domain/search.dart';

class ClientLoanController extends GetxController implements GetxService {
  final formKey = GlobalKey<FormState>();
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController loanTermController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  final List<String> _dropListPercentages = ['5', '10', '15', '20', '25', '30', '40', '50', '60', '70', '80', '90', '100'];
  List<LoanOffer> _loanOffers = [];
  LoanOffer? _selectedLoanOffer;
  double _monthlyPayment = 0.0;
  double _dailyPayment = 0.0;
  double _totalPayment = 0.0;
  int _loanAmount = 0;
  int _loanTerm = 0;
  bool _agreeToTerms = true;
  bool _isLoading = false;

  
  String _dropDownSelectedValue = 'select Percentage'.tr;
  String  get dropDownSelectedValue => _dropDownSelectedValue;

 void dropDownChange(String value) {
    _dropDownSelectedValue = value;
    update();
  }
  
  List<String> get percentages => _dropListPercentages;
  List<UserLoan> _userLoans = [];
  List<UserLoan> get userLoans => _userLoans;
  List<LoanOffer> get loanOffers => _loanOffers;
  LoanOffer? get selectedLoanOffer => _selectedLoanOffer;
  double get monthlyPayment => _monthlyPayment;
  double get dailyPayment => _dailyPayment;
  double get totalPayment => _totalPayment;
  int get loanAmount => _loanAmount;
  int get loanTerm => _loanTerm;
  bool get agreeToTerms => _agreeToTerms;
  bool get isLoading => _isLoading;

  late ApiClient apiClient;

  var loans = <UserLoan>[].obs;
  var isLoadingLo = true.obs;
  var isLoading2 = true.obs;
  var loans2 = <UserLoan>[].obs;
  final AuthRepo authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    fetchLoanOffers();
    fetchUserLoans();
  }


  List<ClientContent> _clientLoansHistory = [];
  List<ClientContent> get clientLoansHistory => _clientLoansHistory;
  // List<ClientContent> content;


Future<void> fetchClientLoansHistory(int clientId) async {
  isLoadingLo(true);
  try {
    final response = await authRepo.getClientLoansHistory(clientId);

    if (response.statusCode == 200) {
      // Assuming you should only use one parsing method      "response_code": "default_200", ClientLoanspayHistory

      // final ClientLoanspayHistory clientLoanspayHistory = clientLoanspayHistoryFromJson(response.body);
      final ClientLoanspayHistory clientLoanspayHistory = ClientLoanspayHistory.fromJson(response.body);

      
      if (clientLoanspayHistory.responseCode == 'default_200') {
         _clientLoansHistory = clientLoanspayHistory.content;

        print('_________________________________________clientLoansHistory \n \n\n\n\n\n\n $_clientLoansHistory');
      
      } else {
        Get.snackbar('Error', 'Failed to load user loans. Message: ${clientLoanspayHistory.message}');
      }
    } else {
      print('Failed to load user loans. Status code: ${response.statusCode}');
      Get.snackbar('Error', 'Failed to load user loans. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load user loans. Error: $e');
    Get.snackbar('Error', 'Failed to load user loans. Error: $e');
  } finally {
    isLoadingLo(false);
    update();
  }
}







  Future<void> fetchLoanOffers() async {
    _isLoading = true;
    update();
    final url = 'https://bafubira.sanaa.co/api/v1/loan-plans';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _loanOffers = responseData.map((json) => LoanOffer.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load loan offers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load loan offers. Error: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> fetchUserLoans() async {
    final url = 'https://bafubira.sanaa.co/api/v1/loan-lists/1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> loanData = jsonDecode(response.body)['loans'];
        _userLoans = loanData.map((loan) => UserLoan.fromJson(loan)).toList();
      } else {
        // Get.snackbar('Error', 'Failed to load user loans. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user loans. Error: $e');
    } finally {
      update();
    }
  }

  void calculateLoan3(int amount, int term, double interestRate) {
    _loanAmount = amount;
    _loanTerm = term;
    double monthlyRate = interestRate / 12 / 100;
    _monthlyPayment = (amount * monthlyRate) / (1 - (1 / pow((1 + monthlyRate), term)));
    _totalPayment = _monthlyPayment * term;
    _dailyPayment = _totalPayment / (term * 30);
    update();
  }

void calculateLoan(int amount, int term, double interestRate) {
    _loanAmount = amount;
    _loanTerm = term;

    // Convert annual interest rate to daily rate
    double dailyRate = interestRate / 100 / 365;

    // Calculate total payment with interest
    _totalPayment = amount * (1 + dailyRate * term);

    // Calculate daily payment
    _dailyPayment = _totalPayment / term;

    // Monthly payment is not applicable for a 30-day term
    _monthlyPayment = _dailyPayment * 30;

    update();
}

  void resetPaymentValues() {
    _monthlyPayment = 0.0;
    _dailyPayment = 0.0;
    _totalPayment = 0.0;
    _loanAmount = 0;
    _loanTerm = 0;
    _agreeToTerms = false;
    update();
  }

  void selectLoanOffer(LoanOffer offer) {
    _selectedLoanOffer = offer;
    update();
  }

  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    update();
  }

 List<Content> _clientLoans = [];
  List<Content> get clientLoans => _clientLoans;

  // var isLoadingLo = false.obs;

   Future<void> fetchClientLoans(int clientId) async {
    isLoadingLo(true);
    try {
      final response = await authRepo.getClientLoans(clientId);

      if (response.statusCode == 200) {
        final ClientLoans clientLoansResponse = ClientLoans.fromJson(response.body);
        
        if (clientLoansResponse.responseCode == 'default_200' && clientLoansResponse.content != null) {
          _clientLoans = clientLoansResponse.content!;
         
        } else {
          
          Get.snackbar('Error', 'Failed to load user loans. Message: ${clientLoansResponse.message}');
          
        }
      } else {
        print('Failed to load user loans. Status code: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to load user loans. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load user loans. Error on try: $e');
      Get.snackbar('Error', 'Failed to load user loans. Error: $e');
    } finally {
      isLoadingLo(false);
      update();
    }
  }

  bool validateLoanApplication() {
    if (!_agreeToTerms) {
      Get.snackbar('Error', 'You must agree to the terms and conditions');
      return false;
    }
    // if (_loanAmount <= 0 || _loanTerm <= 0) {
    //   Get.snackbar('Error', 'Loan amount and term must be greater than zero');
    //   return false;
    // }
    return true;
  }

  String generateTransactionId() {
    var uuid = Uuid();
    return 'TRX${uuid.v4().substring(0, 8)}';
  }

Future<void> submitLoanApplication(int clientId) async {
  _isLoading = true;
  update(); // Notify the UI to show the loading indicator

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    var addedBy = savedCustomerData['id'];
    var interestRate = 20;

    _loanTerm = int.tryParse(loanTermController.text) ?? 0;
    var amt = int.tryParse(loanAmountController.text) ?? 0;

    // Convert annual interest rate to daily rate
    double dailyRate = interestRate / 100 / 365;

    // Calculate total payment with interest
    _totalPayment = amt * (1 + dailyRate * _loanTerm);

    // Calculate daily payment
    _dailyPayment = _totalPayment / _loanTerm;

    // Monthly payment is not applicable for a 30-day term
    _monthlyPayment = _dailyPayment * 30;

    double monthlyRate = interestRate / 12 / 100;
    _monthlyPayment = (amt * monthlyRate) / (1 - (1 / pow((1 + monthlyRate), _loanTerm)));


//  $validator = Validator::make($request->all(), [
//          
//         'client_id' => 'required|exists:clients,id',
//         'agent_id' => 'required|exists:users,id',
//         'trx' => 'nullable|string|max:40',
//          
//         'installment_interval' => 'required|integer|min:1',
//         'paid_amount' => 'nullable|numeric|min:0',
//         'next_installment_date' => 'nullable|date',
//         'user_details' => 'nullable|string',
//     ]);


    var body = {
      'user_id': addedBy.toString(),
      'amount': amt,
      'plan_id': 8,
      'per_installment': _dailyPayment,
      'trx': generateTransactionId(),
      'installment_interval': 30,
      'total_installment': 30,
      'given_installment': 0,
      'paid_amount': 0.00,
      'final_amount': _totalPayment.toStringAsFixed(2),
      'user_details': '',
      'next_installment_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'client_id': clientId,
    };

    Response response = await authRepo.addClientLoan(body);
    if (response.statusCode == 200) {
      showCustomSnackBarHelper('Loan added successfully', isError: false, duration: const Duration(minutes: 3));
      resetLoanData();
      _isLoading = false;
      update(); // Notify the UI to remove the loading indicator
      Get.off(ClientProfilePage(clientId: clientId));
    } else {
      _isLoading = false;
      update(); // Notify the UI to remove the loading indicator
      showCustomSnackBarHelper('Failed to add Loan', isError: true, duration: const Duration(minutes: 5));
    }
  } catch (e) {
    _isLoading = false;
    update(); // Notify the UI to remove the loading indicator
    showCustomSnackBarHelper('An error occurred: $e', isError: true, duration: const Duration(minutes: 5));
  }
}




Future<void> submitLoanApplicationold1(int clientId) async {
  _isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    var addedBy = savedCustomerData['id'];
    var interestRate = 20;

    _loanTerm = int.tryParse(loanTermController.text) ?? 0;
    var amt = int.tryParse(loanAmountController.text) ?? 0; 

      // Convert annual interest rate to daily rate
    double dailyRate = interestRate / 100 / 365;
    
     // Calculate total payment with interest
    _totalPayment = amt * (1 + dailyRate * _loanTerm);

    // Calculate daily payment
    _dailyPayment = _totalPayment / _loanTerm;

    // Monthly payment is not applicable for a 30-day term
    _monthlyPayment = _dailyPayment * 30;

    

    double monthlyRate = 20 / 12 / 100;
    _monthlyPayment = (amt * monthlyRate) / (1 - (1 / pow((1 + monthlyRate), _loanTerm)));
    // _totalPayment = _monthlyPayment * _loanTerm;
    // _dailyPayment = _totalPayment / (_loanTerm * 30); // Roughly  
    try {
      var body = {
        'user_id': addedBy.toString(),
        'amount': amt,
        'plan_id': 8,
        'per_installment': _dailyPayment,
        'trx': generateTransactionId(),
        'installment_interval': 30,
        'total_installment': 30,
        'given_installment': 0,
        'paid_amount': 0.00,
        'final_amount': _totalPayment.toStringAsFixed(2),
        'user_details': '',
        'next_installment_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'client_id': clientId,
    
      };

      


      // int clientId;
      Response response = await authRepo.addClientLoan(body);
      print('________________________________________________________________');
      print('________________________________________________________________');
      print('________________________________________________________________');
      print(response.body);
      print('________________________________________________________________');print('________________________________________________________________');
      if (response.statusCode == 200) {
        showCustomSnackBarHelper('Loan added successfully', isError: false, duration: const Duration(minutes: 3));
        // resetGuarantorData();
        resetLoanData() ;
        _isLoading = false;
        Get.off(ClientProfilePage(clientId: clientId));
      } else {
        _isLoading = false;
        showCustomSnackBarHelper('Failed to add Loan', isError: true, duration: const Duration(minutes: 5));
      }
    } catch (e) {
      _isLoading = false;
      showCustomSnackBarHelper('An error occurred: $e', isError: true, duration: const Duration(minutes: 5));
    }
  }
  void resetLoanData() {
    loanAmountController.clear();
    loanTermController.clear();
    rateController.clear();
    _dropDownSelectedValue = 'select Percentage'.tr;
    _selectedLoanOffer = null;
    resetPaymentValues();
    formKey.currentState?.reset();
  }

  Future<void> applyForLoan() async {
    // await submitLoanApplication();
  }
}
