import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/addClient.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/styles.dart';

class PendingClients extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients with Pending Loans"),
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.clientsListPending.isEmpty) {
          return const Center(child: Text("No clients with pending loans found"));
        } else {
          return ListView.builder(
            itemCount: controller.clientsListPending.length,
            itemBuilder: (context, index) {
              final client = controller.clientsListPending[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    client.name ?? "Unknown",
                    style: rubikMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  subtitle: Text(
                    "Credit Balance: ${client.creditBalance ?? 'N/A'} \nPhone: ${client.phone ?? 'N/A'}",
                  ),
                  onTap: () {
                    Get.to(ClientProfilePage(clientId: client.id!)); // Navigate to client details
                  },
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(AddClientScreen()), // Navigate to add client screen
        child: const Icon(Icons.add),
        tooltip: 'Add New Client',
      ),
    );
  }
}
