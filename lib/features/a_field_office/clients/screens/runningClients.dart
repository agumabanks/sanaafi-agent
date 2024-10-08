import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/addClient.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/controllers/auth_controller.dart';

class RunningClients2 extends StatefulWidget {
  @override
  _RunningClients2State createState() => _RunningClients2State();
}

class _RunningClients2State extends State<RunningClients2> {
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().getClients();
    Get.find<AuthController>().getCustomerData();
  }

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.put(ClientController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Clients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(AddClientScreen());
                  },
                  child: const Text('Add Client'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GetBuilder<AuthController>(
                builder: (authController) {
                  if (authController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (authController.clients.isEmpty) {
                    return const Center(child: Text('No clients found.'));
                  }
                  final clients = authController.clients;
                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            client.id.toString(),
                            style: rubikMedium.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Name: ${client.name}'),
                          trailing: Text("Credit Bal: ${client.creditBalance ?? 'N/A'} \nPhone: ${client.phone ?? 'N/A'}"),
                          onTap: () {
                            Get.to(ClientProfilePage(clientId: client.id!));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';  // Import this package
// import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
// import 'package:six_cash/util/dimensions.dart';
// import 'package:six_cash/util/styles.dart';

class RunningClients extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());

  // Helper method to make a phone call
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      Get.snackbar('Error', 'Phone number is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients with Running Loans"),
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.clientsListRunning.isEmpty) {
          return const Center(child: Text("No clients with running loans found."));
        } else {
          return ListView.builder(
            itemCount: controller.clientsListRunning.length,
            itemBuilder: (context, index) {
              final client = controller.clientsListRunning[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    '${client.name}',
                    style: rubikMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  subtitle: Text(
                    "Credit Bal: ${client.creditBalance ?? 'N/A'} \nPhone: ${client.phone ?? 'N/A'}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () => _makePhoneCall(client.phone), // Call button
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
    );
  }
}
