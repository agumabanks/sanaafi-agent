import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../controllers/AddGuarantorController.dart';
import '../controllers/clientController.dart';
import 'PaidClientsPage.dart';
import 'addClient.dart';
import 'allClients.dart';
import 'paidClients.dart';
import 'pendingClients.dart';
import 'runningClients.dart';
import 'unpaidToday.dart';
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

class ClientsPage extends StatefulWidget {
  const ClientsPage({Key? key}) : super(key: key);

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  // Sample data to display counts for each loan type
  final Map<String, int> loanData = {
    'Running Loans': 5,
    'Pending Loans': 3,
    'Paid Loans': 8,
    'All Clients': 16,
  };
  // final int agentId;

  // Inject the AgentController
  final ClientController agentController = Get.put(ClientController());

  // AgentClientsView({required this.agentId});

  @override
  Widget build(BuildContext context) {
    //  agentController.fetchTotalClients(agentId);

    return Scaffold(
       appBar: AppBar(
        // AppBar title will update dynamically with total clients
        title: Obx(() {
          return Text(
            'Clients: ${agentController.totalClients.value}',
          );
        }),
      ),floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 5, right: 5),
          child: GetBuilder<AuthController>(builder: (controller) {
              return FloatingActionButton(
                onPressed: () {
                   Get.to(ClientSearchScreen());
                },
                elevation: 0, backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: SizedBox(child: Icon(Icons.search,color: ColorResources.blackColor,size: 28,),),
              );
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

 //   all clients

            GestureDetector(
                 onTap: () {
        // Handle navigation to detailed view of the selected category
                    Get.to(AllClientsPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 70, width: Get.width,
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "All Clients",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Text(
                                  '',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
         

            // Pending client
            GestureDetector(
                 onTap: () {
                     Get.to(PendingClients());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 70, width: Get.width,
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pending Loans",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Text(
                                  '',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
       


      //  Running Clients
          GestureDetector(
                    onTap: () {
            // Handle navigation to detailed view of the selected category
                        Get.to(RunningClients());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 70, width: Get.width,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Running Loans",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),


        //  Unpaid Clients
          GestureDetector(
                    onTap: () {
            // Handle navigation to detailed view of the selected category
                        Get.to(UnPaidClients());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 70, width: Get.width,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Unpaid Loans Today",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),  
//  Unpaid Clients
          GestureDetector(
                    onTap: () {
            // Handle navigation to detailed view of the selected category
                        Get.to(PaidClientsPage());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 70, width: Get.width,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Paid Loans Today",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),  

          //  Paid Clients
          GestureDetector(
                    onTap: () {
            // Handle navigation to detailed view of the selected category
                        Get.to(PaidClients());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 70, width: Get.width,
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Completed loans",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
          


      ]
        ),
      ),
    );
  }

  // Widget to build each row in the column
  Widget _buildLoanRow(String title, int count) {
    return GestureDetector(
      onTap: () {
        // Handle navigation to detailed view of the selected category
        Get.to(AllClientsPage());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


