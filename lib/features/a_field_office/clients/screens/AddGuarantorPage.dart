import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/AddGuarantorController.dart';

class AddGuarantorPage extends StatefulWidget {
  final int clientId;

  const AddGuarantorPage({required this.clientId});

  @override
  _AddGuarantorPageState createState() => _AddGuarantorPageState();
}

class _AddGuarantorPageState extends State<AddGuarantorPage> {
  late AddGuarantorController controller;
  late int userId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCustomerDataJson = prefs.getString('customerData');
    Map<String, dynamic> savedCustomerData = jsonDecode(savedCustomerDataJson!);
    userId = savedCustomerData['id'];

    if (!Get.isRegistered<AddGuarantorController>()) {
      controller = Get.put(AddGuarantorController());
    } else {
      controller = Get.find<AddGuarantorController>();
    }

    setState(() {});
  }

  Future<void> _pickImage(bool isGuarantorPhoto) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImagePickerOption(
              icon: Icons.camera_alt,
              label: 'Take a photo',
              source: ImageSource.camera,
              isGuarantorPhoto: isGuarantorPhoto),
          _buildImagePickerOption(
              icon: Icons.photo,
              label: 'Choose from gallery',
              source: ImageSource.gallery,
              isGuarantorPhoto: isGuarantorPhoto),
        ],
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required ImageSource source,
    required bool isGuarantorPhoto,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label),
      onTap: () async {
        try {
          final XFile? pickedFile = await _picker.pickImage(source: source);
          Navigator.pop(context);
          _setImage(pickedFile, isGuarantorPhoto);
        } catch (e) {
          Navigator.pop(context);
          print('Image picker error: $e');
        }
      },
    );
  }

  void _setImage(XFile? pickedFile, bool isGuarantorPhoto) {
    if (pickedFile != null) {
      if (isGuarantorPhoto) {
        controller.setGuarantorImage(File(pickedFile.path));
      } else {
        controller.setNationalIdImage(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Guarantor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: GetBuilder<AddGuarantorController>(
        builder: (controller) {
          return Stack(
            children: [
              Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(controller.nameController, 'Name', TextInputType.text),
                      _buildTextField(controller.ninController, 'NIN', TextInputType.text),
                      _buildTextField(controller.phoneNumberController, 'Phone Number', TextInputType.phone),
                      _buildTextField(controller.addressController, 'Address', TextInputType.text),
                      _buildDropdownField(),
                      _buildTextField(controller.occupationController, 'Occupation', TextInputType.text),
                      _buildImageField('Guarantor Photo', true),
                      _buildImageField('National ID Photo', false),
                      SizedBox(height: 30),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading)
                Center(
                  child: Image.asset(
                    'assets/image/sanaa.gif', // Make sure this path matches the location of your GIF
                    width: 150,  // Adjust width as needed
                    height: 150, // Adjust height as needed
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: controller.relationship,
        decoration: InputDecoration(
          labelText: 'Relationship',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items: ['Family', 'Friend', 'Colleague', 'Other']
            .map((String category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            controller.relationship = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a relationship';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageField(String label, bool isGuarantorPhoto) {
    return GestureDetector(
      onTap: () => _pickImage(isGuarantorPhoto),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.grey.shade600),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                isGuarantorPhoto ? controller.photoController.text : controller.nationalIdPhotoController.text,
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (controller.formKey.currentState!.validate()) {
            controller.addGuarantor(widget.clientId);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Add Guarantor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
