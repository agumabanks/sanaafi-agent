import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/AddGuarantorController.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/addClientPhoto.dart';

class AddClientPhotosPage extends StatefulWidget {
  final int clientId;

  AddClientPhotosPage({required this.clientId});

  @override
  _AddClientPhotosPageState createState() => _AddClientPhotosPageState();
}

class _AddClientPhotosPageState extends State<AddClientPhotosPage> {
  late AddPhotoController controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddPhotoController());
  }

  Future<void> _pickImage(bool isGuarantorPhoto) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isGuarantorPhoto) {
          controller.setClientImage(File(pickedFile.path));
        } else {
          controller.setNationalIdImage(File(pickedFile.path));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Client Photos'),
      ),
      body: Form(
        key: controller.formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.photoController,
                      decoration: InputDecoration(labelText: 'Client Photo'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(true),
                  ),
                ],
              ),
              if (controller.clientImage != null)
                Image.file(controller.clientImage!, height: 150, width: 150),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.nationalIdPhotoController,
                      decoration: InputDecoration(labelText: 'National ID Photo'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(false),
                  ),
                ],
              ),
              if (controller.nationalIdImage != null)
                Image.file(controller.nationalIdImage!, height: 150, width: 150),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.saveImages(widget.clientId);
                  }
                },
                child: Text('Add Photos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class AddPhotoWidget extends StatefulWidget {
//   @override
//   _AddPhotoWidgetState createState() => _AddPhotoWidgetState();
// }

// class _AddPhotoWidgetState extends State<AddPhotoWidget> {
//   final ImagePicker _picker = ImagePicker();
//   File? _clientPhoto;
//   File? _nationalIdPhoto;

//   Future<void> _pickImage(bool isClientPhoto) async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         if (isClientPhoto) {
//           _clientPhoto = File(pickedFile.path);
//         } else {
//           _nationalIdPhoto = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: const InputDecoration(labelText: 'Client Photo'),
//                 readOnly: true,
//                 controller: TextEditingController(text: _clientPhoto != null ? 'Client Photo Selected' : ''),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.camera_alt),
//               onPressed: () => _pickImage(true),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 decoration: const InputDecoration(labelText: 'National ID Photo'),
//                 readOnly: true,
//                 controller: TextEditingController(text: _nationalIdPhoto != null ? 'National ID Photo Selected' : ''),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.camera_alt),
//               onPressed: () => _pickImage(false),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
