import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:six_cash/common/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/data/api/api_client.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/helper/custom_snackbar_helper.dart';
import 'package:six_cash/features/auth/domain/reposotories/auth_repo.dart';

class AddPhotoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController photoController = TextEditingController();
  final TextEditingController nationalIdPhotoController = TextEditingController();

  final AuthRepo authRepo = Get.find<AuthRepo>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _clientImage;
  File? _nationalIdImage;

  File? get clientImage => _clientImage;
  File? get nationalIdImage => _nationalIdImage;
  
  int? _clientId;
  int? get clientId => _clientId;

  @override
  void onInit() {
    super.onInit();
  }

  void setClientImage(File image) {
    _clientImage = image;
    photoController.text = image.path;
    update();
  }

  void setNationalIdImage(File image) {
    _nationalIdImage = image;
    nationalIdPhotoController.text = image.path;
    update();
  }

  Future<void> saveImages(int clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    var addedBy = savedCustomerData['id'];

    try {
      var body = {
        
        'client_id': clientId.toString(),
      };

      List<MultipartBody> multipartBody = [];

      if (_clientImage != null) {
        multipartBody.add(MultipartBody(
          'photo',
          File(_clientImage!.path),
        ));
      }

      if (_nationalIdImage != null) {
        multipartBody.add(MultipartBody(
          'national_id_photo',
          File(_nationalIdImage!.path),
        ));
      }

      Response response = await authRepo.uploadClientImages(body, multipartBody);

      if (response.statusCode == 200) {
        showCustomSnackBarHelper('Images uploaded successfully', isError: false, duration: const Duration(minutes: 3));
       Get.to(ClientProfilePage(clientId: clientId));
        resetData();
      } else {
        showCustomSnackBarHelper('Failed to upload images', isError: true, duration: const Duration(minutes: 5));
      }
    } catch (e) {
      showCustomSnackBarHelper('An error occurred: $e', isError: true, duration: const Duration(minutes: 5));
    }
  }

  void resetData() {
    photoController.clear();
    nationalIdPhotoController.clear();
    _clientImage = null;
   
  }
  }