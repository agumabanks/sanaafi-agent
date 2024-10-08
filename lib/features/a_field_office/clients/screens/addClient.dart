import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/AddClientController.dart';
// import 'package:six_cash/features/a_field_office/clients/controllers/add_client_controller.dart';

class AddClientScreen extends StatelessWidget {
  final AddClientController addClientController = Get.put(AddClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Client'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: controller.nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.dobController,
                          decoration: const InputDecoration(labelText: 'Date of Birth'),
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.businessController,
                          decoration: const InputDecoration(labelText: 'Business'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.ninController,
                          decoration: const InputDecoration(labelText: 'NIN'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.creditBalanceController,
                          decoration: const InputDecoration(labelText: 'Credit Balance'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.savingsBalanceController,
                          decoration: const InputDecoration(labelText: 'Savings Balance'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.formKey.currentState!.validate()) {
                              controller.addClient();
                            }
                          },
                          child: const Text('Add Client'),
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
                    child: const Center(
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
