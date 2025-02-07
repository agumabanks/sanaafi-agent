
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../controllers/AddGuarantorController.dart';
import '../controllers/clientController.dart';
import 'addClient.dart';
import 'viewClient.dart';
import '../../search/screens/searchScreen.dart';
// import 'package:six_cash/features/a_field_office/loans/controllers/LoanController.dart';
import '../../../auth/domain/reposotories/auth_repo.dart';
import '../../../../util/color_resources.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import '../../../auth/controllers/auth_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';




class AllClientsPage extends StatefulWidget {
  @override
  State<AllClientsPage> createState() => _AllClientsPageState();
}

class _AllClientsPageState extends State<AllClientsPage> {
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().getClients();
    Get.find<AuthController>().getCustomerData();
    // Get.find<ClientLoanController>().fetchLoanOffers(); 
    
  }

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.put(ClientController());
     final formatter = NumberFormat('#,##0');
    return  Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 8, 2, 2),
                    child: Text(
                      'All Clients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.to(ClientSearchScreen());
                        },
                        child: Text('Search'),
                      ),
                       
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
        child: Container(
      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      // color: Colors.white, // Set the background color to white
      child: GetBuilder<AuthController>(
        builder: (authController) {
          if (authController.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (authController.clients.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }
      
          final clients = authController.clients;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                                                                        '${client.name}',
                                                                        style: rubikMedium.copyWith(
                                                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                          fontSize: Dimensions.fontSizeLarge,
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      ),
                      subtitle: Text('Tel: ${client.phone}'),
                      trailing: Text('Credit Balance \n${formatter.format(client.creditBalance)}'),
                      onTap: () {
                        // Navigate to the client profile page
                        Get.to(ClientProfilePage(clientId: client.id!)); 
                        // Get.find<AddGuarantorController>().fetchClientGuarantors(client.id!);
                        
                      },
                    ),
                    const Divider(thickness: 1),
                  ],
                );
            },
          );
        },
      ),
        ),
      ),
      
            ],
          ),
        ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 10),
          child: GetBuilder<AuthController>(builder: (controller) {
              return FloatingActionButton(
                onPressed: () {
                   Get.to(AddClientScreen());
                },
                elevation: 0, backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: SizedBox(child: Icon(Icons.add,color: ColorResources.blackColor,size: 28,),),
              );
            },
          )),
          
          );
    
  }

  Widget viewClients() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://example.com/photo.jpg'),
                ),
                SizedBox(width: 16),
                Text('John Doe'),
                SizedBox(width: 16),
                Text('123-456-7890'),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Add your logic here
                  },
                  child: Text('View'),
                ),
              ],
            ),
            // Add more rows of client data here
          ],
        ),
      ),
    );
  }

  Widget newAccounts() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name'),
                SizedBox(width: 16),
                Text('Phone'),
                SizedBox(width: 16),
                Text('Amount'),
              ],
            ),
            // Add more rows of account data here
          ],
        ),
      ),
    );
  }
}
