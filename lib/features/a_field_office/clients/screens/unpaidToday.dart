import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/viewClient.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UnPaidClients extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());
  final ScrollController _scrollController = ScrollController();

  UnPaidClients({Key? key}) : super(key: key) {
    // Fetch initial data
    controller.fetchClientsWithUnpaidLoansToday();

    // Listen for scroll events to implement infinite scroll
    _scrollController.addListener(_scrollListener);
  }

  // Listener for scroll events to fetch next page when reaching the bottom
  void _scrollListener() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      controller.fetchClientsWithUnpaidLoansToday(isNextPage: true);
    }
  }

  // Function to launch a call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      _showErrorSnackbar('Could not launch the phone call');
    }
  }

  // Helper method to show a snackbar with error messages
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UnPaid Loans Today"),
      ),
      body: Obx(() {
        if (controller.isLoadingData.value && controller.clientsListUnpaid.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.clientsListUnpaid.isEmpty) {
          return const Center(child: Text("No clients with unpaid loans found."));
        } else {
          return ListView.builder(
            controller: _scrollController,
            itemCount: controller.clientsListUnpaid.length + 1, // Extra item for the loader at the bottom
            itemBuilder: (context, index) {
              if (index < controller.clientsListUnpaid.length) {
                final client = controller.clientsListUnpaid[index];
                return _buildClientCard(context, client);
              } else {
                // Loader at the bottom for fetching the next page
                return _buildLoader();
              }
            },
          );
        }
      }),
    );
  }

  // Widget to build each client card
  Widget _buildClientCard(BuildContext context, client) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          client.name ?? "Unknown",
          style: rubikMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        subtitle: Text(
          "Credit Bal: ${client.creditBalance ?? 'N/A'} \nPhone: ${client.phone ?? 'N/A'}",
        ),
        trailing: IconButton(
          icon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
          onPressed: () {
            if (client.phone != null) {
              _makePhoneCall(client.phone!);
            } else {
              _showErrorSnackbar('Phone number is not available');
            }
          },
        ),
        onTap: () {
          // Navigate to view more details about the client, such as client profile page
          Get.to(ClientProfilePage(clientId: client.id!));
        },
      ),
    );
  }

  // Widget to show a loader at the bottom when fetching the next page
  Widget _buildLoader() {
    return controller.isFetchingNextPage.value
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox();
  }
}
