import 'dart:async';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/features/a_field_office/LoanCalculator/screens/LoanCalculatorPage.dart';
import 'package:six_cash/features/a_field_office/clients/screens/addClient.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
import 'package:six_cash/features/camera_verification/screens/camera_screen.dart';
import 'package:six_cash/features/home/widgets/bottomsheet_content_widget.dart';
import 'package:six_cash/features/home/widgets/persistent_header_widget.dart';
import 'package:six_cash/util/dimensions.dart';

import '../../../../util/images.dart';


class OFHomePage extends StatefulWidget {
  @override
  State<OFHomePage> createState() => _OFHomePageState();
}

class _OFHomePageState extends State<OFHomePage> {
  Timer? _timer; // Timer for periodic data refresh

  @override
  void initState() {
    super.initState();
    _reloadData(context); // Initial data load

    // Initialize periodic data refresh every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 20), (Timer t) => _reloadData(context));
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  Future<void> _reloadData(BuildContext context) async {
    final AuthController authController = Get.find<AuthController>();
    await authController.getAgentLoanAmount();
    await authController.getTodayScheduledLoans();
    await authController.getClients();
  }

  //   Timer? _timer; // Timer for periodic data refresh

  // void initState() {
  //   super.initState();
  //   _reloadData( context);
  //       _timer = Timer.periodic(Duration(seconds: 30), (Timer t) => _reloadData(context));

  // }
  
  // Future<void> _reloadData(BuildContext context) async {
    
  //   Get.find<AuthController>().getAgentLoanAmount();
  //   Get.find<AuthController>().getTodayScheduledLoans();
  //      Get.find<AuthController>().getClients();

    
  // }
  @override
  Widget build(BuildContext context) {
    // final OFHomeController homeController = Get.find();
 final AuthController authController = Get.find<AuthController>();
    authController.getAgentLoanAmount();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanaa Field App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
        actions: [
          // getTodayScheduledLoans()
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined, size: 26,),
            onPressed: () {
              // Add your onPressed logic here
              print('____________________________reset values \n resetting');
              Get.find<AuthController>().resetClient();
              Get.find<AuthController>().getAgentLoanAmount();
              Get.find<AuthController>().getTodayScheduledLoans();
            },
          ),
        PopupMenuButton<int>(
              icon: const Icon(Icons.add),
              onSelected: (value) {
                // Handle the button actions based on the value
                switch (value) {
                  case 0:
                    // Add New Document logic
                    Get.to(AddClientScreen());
                    break;
                  case 1:
                    // Add Photo logic
                    print('Add Photo');
                    break;
                  case 2:
                    // Add National ID logic
                    print('Add National ID');
                    break;
                  // case 3:
                    // Add New Loan logic
                    // print('Add New Loan');
                    // break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Add New Client'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Add New Docs'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Add Expenses'),
                ),
                
              ],
            ),
        ],
      ),
      body: ExpandableBottomSheet(
         enableToggle: true,

          background: RefreshIndicator(
                            onRefresh: () async => await  _reloadData( context),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child:  SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    amounts(),
                                    const SizedBox(height: 18),
                                    const Text( 'Pay Collections',style: TextStyle(),),
                                    const SizedBox(height: 6),
                                    payCollection(),
                                    const SizedBox(height: 18),
                                    LoanCalculatorPage()
                                    
                                    
                                  ],
                                ),
                              ),
                            ),
                              
                           
                              
                              ),
                            ),

                            persistentContentHeight: 70,
                            persistentHeader: const PersistentHeaderWidget(),
                            expandableContent: const BottomSheetContentWidget()
                          ),

        
      
      
    );
  }



Widget LoanAmount() {
  //  final AuthController loanController;
    return GetBuilder<AuthController>(
          builder: (controller) {
            if (controller.isLoading) {
              return CircularProgressIndicator();
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loan Amount: ${controller.loanAmount}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.getAgentLoanAmount();
                    },
                    child: Text('Fetch Loan Amount'),
                  ),
                ],
              );
            }
          },
        );
  }





  Widget amounts() {
  return GetBuilder<AuthController>(
    builder: (controller) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Collected Amount Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collected Amount',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.formattedLoanAmountCollected}', // Format the loan amount
                    style: const TextStyle(
                      fontSize: 36,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Expected Amount Column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expected Amount',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8), 
                  // Add spacing between the texts
                  Text(
                    '${controller.formattedLoanAmount}', // Format the loan amount
                    style: const TextStyle(
                      fontSize: 36,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // LoanAmount()
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget payCollection(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.to(()=> const CameraScreen(
                    fromEditProfile: false, isBarCodeScan: true, isHome: true,
                  ));
                },
                child: Container(
                  height: 150, width: Get.width /2 -20,
                  // color: Colors.green,
                  decoration: BoxDecoration(
                    color: Colors.green,
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
                  child:  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, color: Color.fromARGB(255, 235, 235, 235), size: 30,),
                        
                        Text('Pay Loan',style: TextStyle(color: Color.fromARGB(255, 235, 235, 235)),),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Container(
                height: 150, width: Get.width /2 -30,
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
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text('Add Savings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  

Widget todaySchedule2() {

  return GetBuilder<AuthController>(
    builder: (authController) {
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
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text('Name')),
                  SizedBox(width: 16),
                  Expanded(child: Text('Phone')),
                  SizedBox(width: 16),
                  Expanded(child: Text('Amount')),
                  SizedBox(width: 16),
                  Icon(Icons.check_circle),
                ],
              ),
              const Divider(), // Add a divider between header and content
              authController.agentTodaySche == null
                  ? Center(child: CircularProgressIndicator())
                  : authController.agentTodaySche.isEmpty
                      ? Center(child: Text('No schedules for today yet'))
                      : ListView.builder(
                        itemCount: authController.agentTodaySche.length,
                        itemBuilder: (context, index) {
                          final loan = authController.agentTodaySche[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(loan.clientName ?? 'N/A')),
                                SizedBox(width: 16),
                                Expanded(child: Text(loan.clientPhone ?? 'N/A')),
                                SizedBox(width: 16),
                                Expanded(child: Text('${loan.installAmount ?? '0.00'} /=')),
                                SizedBox(width: 16),
                                Icon(
                                  loan.status == 'pending'
                                      ? Icons.pending
                                      : Icons.check_circle,
                                  color: loan.status == 'pending'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ],
          ),
        ),
      );
    },
  );
}

}
