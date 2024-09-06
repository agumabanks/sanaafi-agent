import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:six_cash/features/a_field_office/clients/domain/ClientguarantorsListModal.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
// import 'package:six_cash/features/auth/domain/repositories/auth_repo.dart';
import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';
import '../../../../data/api/api_client.dart';

class AddGuarantorController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ninController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController nationalIdPhotoController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController clientRelationshipController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  String? relationship;

  final AuthRepo authRepo = Get.find<AuthRepo>();

  List<Content> _guarantorList = [];
  List<Content> get guarantorList => _guarantorList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _guarantorImage;
  File? _nationalIdImage;

  File? get guarantorImage => _guarantorImage;
  File? get nationalIdImage => _nationalIdImage;

  @override
  void onInit() {
    super.onInit();
  }

  void setGuarantorImage(File image) {
    _guarantorImage = image;
    photoController.text = image.path;
    update();
  }

  void setNationalIdImage(File image) {
    _nationalIdImage = image;
    nationalIdPhotoController.text = image.path;
    update();
  }

  Future<void> fetchClientGuarantors(int clientId) async {
    try {
      _isLoading = true;
      update();

      Response response = await authRepo.clientguarantorsList(clientId);
      if (response.body['response_code'] == 'default_200') {
        ClientguarantorsList clientGuarantorsList = clientguarantorsListFromJson(response.bodyString!);
        _guarantorList = clientGuarantorsList.content ?? [];
      } else {
        showCustomSnackBarHelper('Failed to fetch guarantors', isError: true, duration: const Duration(minutes: 3));
      }
    } catch (e) {
      showCustomSnackBarHelper('An error occurred: $e', isError: true, duration: const Duration(minutes: 3));
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> addGuarantor(int clientId) async {
    _isLoading = true;
    update();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    var addedBy = savedCustomerData['id'];

    try {
      var body = {
        'name': nameController.text,
        'nin': ninController.text,
        'phone_number': phoneNumberController.text,
        'address': addressController.text,
        'job': occupationController.text,
        'client_relationship': relationship.toString(),
        'added_by': addedBy.toString(),
        'client_id': clientId.toString(),
      };

      List<MultipartBody> multipartBody = [];

      if (_guarantorImage != null) {
        multipartBody.add(MultipartBody(
          'photo',
          File(_guarantorImage!.path),
        ));
      }

      if (_nationalIdImage != null) {
        multipartBody.add(MultipartBody(
          'national_id_photo',
          File(_nationalIdImage!.path),
        ));
      }

      Response response = await authRepo.addClientGuarantor(body, multipartBody);
      if (response.statusCode == 200) {
        showCustomSnackBarHelper('Guarantor added successfully', isError: false, duration: const Duration(minutes: 3));
        resetGuarantorData();
        Get.to(ClientProfilePage(clientId: clientId));
      } else {
        showCustomSnackBarHelper('Failed to add guarantor', isError: true, duration: const Duration(minutes: 5));
      }
    } catch (e) {
      showCustomSnackBarHelper('An error occurred: $e', isError: true, duration: const Duration(minutes: 5));
    } finally {
      _isLoading = false;
      update();
    }
  }

  void resetGuarantorData() {
    nameController.clear();
    ninController.clear();
    phoneNumberController.clear();
    addressController.clear();
    jobController.clear();
    clientRelationshipController.clear();
    photoController.clear();
    relationship = '';
    nationalIdPhotoController.clear();
    occupationController.clear();
    _guarantorImage = null;
    _nationalIdImage = null;
    update();
  }

  @override
  void onClose() {
    nameController.dispose();
    ninController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    occupationController.dispose();
    photoController.dispose();
    nationalIdPhotoController.dispose();
    clientRelationshipController.dispose();
    super.onClose();
  }
}
