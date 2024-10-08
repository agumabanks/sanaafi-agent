import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/styles.dart';

class PaidClients extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients with Paid Loans"),
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.clientsListPaid.isEmpty) {
          return const Center(child: Text("No clients with paid loans found."));
        } else {
          return ListView.builder(
            itemCount: controller.clientsListPaid.length,
            itemBuilder: (context, index) {
              final client = controller.clientsListPaid[index];
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
                    "Credit Bal: ${client.creditBalance ?? 'N/A'} \nPhone: ${client.phone ?? 'N/A'}",
                  ),
                  onTap: () {
                    // Navigate to view more details about the client, such as client profile page
                    Get.to(ClientProfilePage(clientId: client.id!));
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }
}
