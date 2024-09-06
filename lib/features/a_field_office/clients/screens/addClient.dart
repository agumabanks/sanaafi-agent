import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/AddClientController.dart';

class AddClientScreen extends StatelessWidget {
  final AddClientController addClientController = Get.put(AddClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Client'),
      ),
      body: GetBuilder<AddClientController>(
        builder: (controller) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: controller.phoneController,
                          decoration: InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: controller.addressController,
                          decoration: InputDecoration(labelText: 'Address'),
                        ),
                        TextFormField(
                          controller: controller.dobController,
                          decoration: InputDecoration(labelText: 'Date of Birth'),
                          keyboardType: TextInputType.datetime,
                        ),
                        TextFormField(
                          controller: controller.businessController,
                          decoration: InputDecoration(labelText: 'Business'),
                        ),
                        TextFormField(
                          controller: controller.ninController,
                          decoration: InputDecoration(labelText: 'NIN'),
                        ),
                        TextFormField(
                          controller: controller.creditBalanceController,
                          decoration: InputDecoration(labelText: 'Credit Balance'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: controller.savingsBalanceController,
                          decoration: InputDecoration(labelText: 'Savings Balance'),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.formKey.currentState!.validate()) {
                              controller.addClient();
                            }
                          },
                          child: Text('Add Client'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
