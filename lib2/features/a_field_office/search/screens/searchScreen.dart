// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:six_cash/features/a_field_office/clients/controllers/clientController.dart'; // Import the ClientController

// class ClientSearchScreen extends StatelessWidget {
//   final ClientController clientController = Get.put(ClientController()); // Initialize the controller

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController searchController = TextEditingController();  // Controller for search input

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search Clients'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search by name or ID',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     if (searchController.text.isNotEmpty) {
//                       // Call the search function with the input value
//                       clientController.searchClients(searchController.text);
//                     }
//                   },
//                 ),
//               ),
//               onSubmitted: (value) {
//                 if (value.isNotEmpty) {
//                   clientController.searchClients(value);  // Trigger search on submission
//                 }
//               },
//             ),
//           ),
//           Expanded(
//             // Use GetX to reactively build the UI based on client list and loading state
//             child: GetX<ClientController>(
//               builder: (controller) {
//                 if (controller.isSearchLoadingData.value) {
//                   return Center(child: CircularProgressIndicator());  // Show loading indicator
//                 }

//                 if (controller.searchClientsList.isEmpty) {
//                   return Center(child: Text('No clients found.'));  // Show if no clients are found
//                 }

//                 // Display list of clients
//                 return ListView.builder(
//                   itemCount: controller.searchClientsList.length,
//                   itemBuilder: (context, index) {
//                     final client = controller.searchClientsList[index];
//                     return ListTile(
//                       title: Text('${client.name}'),
//                       subtitle: Text(client.phone ?? 'No email available'),
//                       trailing: Text(client.id.toString()),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../clients/controllers/clientController.dart';
import '../../clients/screens/viewClient.dart'; // Import the ClientController

class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({Key? key}) : super(key: key);

  @override
  _ClientSearchScreenState createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  late final ClientController clientController;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller. Use Get.find if it's already been put elsewhere.
    clientController = Get.put(ClientController());
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      clientController.searchClients(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Clients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isSearchLoadingData.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (clientController.searchClientsList.isEmpty) {
                return const Center(child: Text('No clients found.'));
              }

              return ListView.builder(
                itemCount: clientController.searchClientsList.length,
                itemBuilder: (context, index) {
                  final client = clientController.searchClientsList[index];
                  return ListTile(
                    title: Text('${client.name}'),
                    subtitle: Text(client.phone ?? 'No phone available'),
                    trailing: Text(client.id.toString()),
                    onTap: () {
                      // Handle client tap if necessary
                      Get.to(ClientProfilePage(clientId: client.id!)); 
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
