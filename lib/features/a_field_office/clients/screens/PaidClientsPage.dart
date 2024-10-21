import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:url_launcher/url_launcher.dart';

class PaidClientsPage extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());
  final ScrollController _scrollController = ScrollController();

  PaidClientsPage() {
    // Listen to scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Reached the bottom, fetch the next page
        controller.fetchClientsWhoPaidToday(isNextPage: true);
      }
    });
  }

  // Function to launch a call
  void _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch the phone call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Clients Who Paid Today",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoadingData.value && controller.clientsListPaidToday.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.clientsListPaidToday.isEmpty) {
          return const Center(child: Text("No clients who paid today found."));
        } else {
          return ListView.builder(
            controller: _scrollController,
            itemCount: controller.clientsListPaidToday.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.clientsListPaidToday.length) {
                final client = controller.clientsListPaidToday[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      client.name ?? "Unknown",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Credit Balance: ${client.creditBalance ?? 'N/A'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          "Phone: ${client.phone ?? 'N/A'}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone, color: Colors.green[700]),
                      onPressed: () {
                        if (client.phone != null) {
                          _makePhoneCall(client.phone!);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Phone number is not available',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.7),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(10),
                            borderRadius: 8,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      // Navigate to view more details about the client, such as client profile page
                      Get.to(() => ClientProfilePage(clientId: client.id!));
                    },
                  ),
                );
              } else {
                return controller.isFetchingPaidTodayNextPage.value
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox();
              }
            },
          );
        }
      }),
    );
  }
}
