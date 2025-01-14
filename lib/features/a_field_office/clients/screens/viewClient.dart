import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:six_cash/common/widgets/custom_button_widget.dart';
import 'package:six_cash/common/widgets/custom_image_widget.dart';
import 'package:six_cash/common/widgets/hero_dialogue_route_widget.dart';
import 'package:six_cash/features/a_field_office/clients/controllers/AddGuarantorController.dart';
import 'package:six_cash/features/a_field_office/clients/screens/AddGuarantorPage.dart';
import 'package:six_cash/features/a_field_office/clients/screens/clientQr.dart';
import 'package:six_cash/features/a_field_office/clients/widgets/clientAddPhoto.dart';
import 'package:six_cash/features/a_field_office/loans/loans/controllers/loanController.dart';
import 'package:six_cash/features/a_field_office/loans/loans/screens/newloanForm.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
import 'package:six_cash/features/auth/widgets/qr_code_popup_widget.dart';
import 'package:six_cash/features/splash/controllers/splash_controller.dart';
import 'package:six_cash/helper/route_helper.dart';
import 'package:six_cash/helper/tween_helper.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/images.dart';
import 'package:six_cash/util/styles.dart';

class ClientProfilePage extends StatefulWidget {
  final int clientId;

  ClientProfilePage({required this.clientId});

  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final AuthController authController = Get.find<AuthController>();
  final AddGuarantorController guarantorController = Get.put(AddGuarantorController());
  final ClientLoanController loanController = Get.put(ClientLoanController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchClientProfile();
    });
  }

  Future<void> _fetchClientProfile() async {
    await authController.getClientProfile(widget.clientId);
    await guarantorController.fetchClientGuarantors(widget.clientId);
    await loanController.fetchClientLoans(widget.clientId);
    Get.find<AuthController>().getClientQrCode(widget.clientId);
    Get.find<ClientLoanController>().fetchClientLoansHistory(widget.clientId);
  }

  @override
    final String _heroQrTag = 'hero-qr-tag';
  Widget build(BuildContext context) {
    final formatterBalance = NumberFormat('#,##0');
    return GetBuilder<AuthController>(
      builder: (controller) {
        return WillPopScope(
            onWillPop: () async {
              print('____________________________reset values \n resetting');
              Get.find<AuthController>().resetClient(); // Reset client when back button is pressed
              return true; // Return true to allow the screen to be popped
            },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 221, 221, 221),
            appBar: AppBar(
                // automaticallyImplyLeading: false, // Removes the default back button

            title: const Text('Client Profile'),
            leading: Row(
  mainAxisSize: MainAxisSize.min, // Prevents the row from taking up the whole app bar width
  children: [
     
    IconButton(
      icon: Icon(Icons.home),
      onPressed: () {
        Get.offAllNamed(RouteHelper.getNavBarRoute(), arguments: true);
      },
    ),
  ],
),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.add),
                onSelected: (value) {
                  // Handle the button actions based on the value
                  switch (value) {
                    case 0:
                      // Add New Document logic
                      print('Add New Document');
                       Get.to(AddClientPhotosPage(clientId: controller.clientProfile!.content!.first.id!));
                      break;
                    case 1:
                      // Add Photo logic
                      print('Add Photo');
                      Get.to(AddClientPhotosPage(clientId: controller.clientProfile!.content!.first.id!));
                      break;
                    case 2:
                      // Add National ID logic
                      print('Add National ID');
                       Get.to(AddClientPhotosPage(clientId: controller.clientProfile!.content!.first.id!));
                      break;
                    case 3:
                      // Add New Loan logic
                       Get.to(AddGuarantorPage(clientId: controller.clientProfile!.content!.first.id!));
                      print('Add New Guarantors');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Add New Document'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Add Photo'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Add National ID'),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Text('Add New Guarantors'),
                  ),
                ],
              ),
            ],
          ), 
               
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.clientProfile == null || controller.clientProfile!.content!.isEmpty
                    ? const Center(child: Text('Failed to load client profile.'))
                    : ModalProgressHUD(
                       inAsyncCall: authController.isLoading,
                       progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor),
          
                      child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: Get.width,
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
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Image.asset(Images.male),

                                      Row(
                                        children: [
                                          Container(
                                                              width: 100,
                                                              height: 100,
                                                              decoration: BoxDecoration(
                                                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusProfileAvatar)),
                                                                border: Border.all(width: 1, color: Theme.of(context).highlightColor),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusProfileAvatar)),
                                                                child: CustomImageWidget(
                                                                  fit: BoxFit.cover,
                                                                  // https://bafubira.sanaa.co/storage/app/public/clients/photos/WswWAGeAnVbHtQy8eoSoTT4eVEwoC5Xn9Wmpperp.jpg
                                                                  image: "https://bafubira.sanaa.co/storage/app/public/${controller.clientProfile!.content!.first.client_photo}",
                                                                  placeholder: Images.avatar,
                                                                ),
                                                              ),
                                                            ),

                                                            const SizedBox(width: 20),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '${controller.clientProfile!.content!.first.name}',
                                                                        style: rubikMedium.copyWith(
                                                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                          fontSize: Dimensions.fontSizeLarge,
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                   
                                                                     SizedBox(
                                                                            child: Text(
                                                                              '${controller.clientProfile!.content!.first.phone}',
                                                                              style: rubikMedium.copyWith(
                                                                                color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(Get.isDarkMode ? 0.8 :0.5),
                                                                                fontSize: Dimensions.fontSizeLarge,
                                                                              ),
                                                                              textAlign: TextAlign.start, maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              // textDirection: TextDirection.ltr,
                                                                            ),
                                                                          ),
                                                                  ],
                                                                ),
                                        ],
                                      ),
                                                        const SizedBox(width: Dimensions.paddingSizeSmall),


                                      
                                
                                      
                                      
                               SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      GetBuilder<AuthController>(builder: (controller) {
                                if (controller.isLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (controller.clientCode != null) {
                                  return InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      HeroDialogRouteWidget(
                                        builder: (_) => ClientQrCodePopupWidget(clientCode: controller.clientCode),
                                      ),
                                    ),
                                    child: Hero(
                                      tag: 'heroQrTag',
                                      createRectTween: (begin, end) => TweenHelper(
                                        begin: begin,
                                        end: end,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        color: Colors.white,
                                        child: SvgPicture.string(controller.clientCode!),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                                      }),
                                    ],
                                  ),
                                )
                                
                                
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'NIN: ${controller.clientProfile!.content!.first.nin}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Address: ${controller.clientProfile!.content!.first.address ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'DOB: ${controller.clientProfile!.content!.first.dob?.toIso8601String() ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Business: ${controller.clientProfile!.content!.first.business ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(thickness: 1),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // const Text(
                                          //   'Account Balances',
                                          //   style: TextStyle(fontSize: 20),
                                          // ),


                                           Text(
                                                                        'Account Balances',
                                                                        style: rubikMedium.copyWith(
                                                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                          fontSize: Dimensions.fontSizeLarge,
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      ),

                                          const SizedBox(height: 8),
                                          Container(
                                            width: Get.width / 2 - 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Savings:',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  '${controller.clientProfile!.content!.first.savingsBalance ?? 0.0}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: Get.width / 2 - 50,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                
                                                const Text(
                                                  'Loan:',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  '${controller.clientProfile!.content!.first.creditBalance ?? 0.0}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: Get.width / 2 - 50,
                                            decoration: BoxDecoration(
                                              color: Colors.green[300],
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
                                            child: CustomButtonWidget(buttonText: 'Pay Loan'.tr, onTap: (){
                                              // showPayLoanDialog();
                                              Get.defaultDialog(
                                                        title: "Pay Loan",
                                                        content: TransactionSelect(clientId: '${controller.clientProfile!.content!.first.id}', clientName: '${controller.clientProfile!.content!.first.name}'),
                                                        // textConfirm: "Pay",
                                                        // textCancel: "Cancel",
                                                        // confirmTextColor: Colors.white,
                                                        
                                                        
                                                      );
                                              // Get.find<ClientLoanController>().fetchLoanOffers();
                                              //  Get.to(LoanApplicationPage(clientId: controller.clientProfile!.content!.first.id!,));
                                            }),
                                          ),
                                          SizedBox(height:10),

                                           Container(
                                            width: Get.width / 2 - 50,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 0, 0, 0),
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
                                            child: CustomButtonWidget(buttonText: 'New Loan'.tr, onTap: (){
                                              Get.find<ClientLoanController>().fetchLoanOffers();
                                               Get.to(LoanApplicationPage(clientId: controller.clientProfile!.content!.first.id!,));
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  // client loans
                                  
                                   Text(
                                                                        'Client loans',
                                                                        style: rubikMedium.copyWith(
                                                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                          fontSize: Dimensions.fontSizeLarge,
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      ),
                                  const SizedBox(height: 15),
                                  clientLoans(),
                                  const SizedBox(height: 18),
                                  // const Divider(thickness: 1),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                           Text(
                                                                        'Guarantors Section',
                                                                        style: rubikMedium.copyWith(
                                                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                          fontSize: Dimensions.fontSizeLarge,
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                                                      ),
                                          
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      getGuarantors(),
                                    ],
                                  ),
                                  const Divider(thickness: 1),
                                  const Text(
                                    'View transactions History',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  clientLoanPaymentHistory()
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),
          ),
        );
      },
    );
  }

  // client loans
  Widget clientLoans() {
    
    return GetBuilder<ClientLoanController>(
      builder: (_controller) {
        if (_controller.isLoadingLo.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (_controller.clientLoans.isEmpty) {
          return const Center(child: Text('No loans found.'));
        } else {
          final formatter = NumberFormat('#,##0');

          


          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.clientLoans.length,
            itemBuilder: (context, index) {
              final loan = _controller.clientLoans[index];
              
              
              // Parse the string amounts to double
              double amount = double.tryParse(loan.amount!) ?? 0.0;
              double paidAmount = double.tryParse(loan.paidAmount!) ?? 0.0;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('Amount:      ${formatter.format(amount)}'),
                       Text('Amount Paid: ${formatter.format(paidAmount)}'),
                       Text('${loan.status == 2 ? "Completed" : loan.status == 1 ? "Running" : "Pending"}',
                      ),
                       
                    ],
                  ),const Divider(thickness: 1),
                ],
              );
              
              // ListTile(

              //   title: Text('Amount: ${formatter.format(amount)}'),
              //   subtitle: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Amount Paid: ${formatter.format(paidAmount)}'),
              //       Text('Status: ${loan.status}'),
              //     ],
              //   ),
              // );
            },
          );
        }
      },
    );
  }

  // Guarantors list
  Widget getGuarantors() {
    return GetBuilder<AddGuarantorController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.guarantorList.isEmpty) {
          return const Center(child: Text('No guarantors found.'));
        }

        final guarantors = controller.guarantorList;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guarantors.length,
          itemBuilder: (context, index) {
            final guarantor = guarantors[index];
            return ListTile(
              title: Text('Guarantor ID: ${guarantor.id}'),
              subtitle: Text('Name: ${guarantor.name}'),
              trailing: Text('NIN: ${guarantor.nin}'),
            );
          },
        );
      },
    );
  }








//   import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart'; // Import the package for formatting

// Client loan payment history widget
Widget clientLoanPaymentHistory() {
  return GetBuilder<ClientLoanController>(
    builder: (_controller) {
      if (_controller.isLoadingLo.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (_controller.clientLoansHistory.isEmpty) {
        return const Center(child: Text('No loan payment history found.'));
      } else {
        final formatter = NumberFormat('#,##0'); // Formatter for currency display

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.clientLoansHistory.length,
          itemBuilder: (context, index) {
            final payment = _controller.clientLoansHistory[index];
            
            // Format the payment amount and date
            String formattedAmount = formatter.format(double.tryParse(payment.amount) ?? 0.0);
            String formattedDate = DateFormat('yyyy-MM-dd').format(payment.paymentDate);
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Date:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                        Text(
                          '$formattedAmount /=',
                           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    if (payment.note != null && payment.note!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            payment.note!,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }
    },
  );
}

  // Method to show the custom dialog
  void showPayLoanDialog() {
    // Get.defaultDialog(
    //   title: "Pay Loan",
    //   content: TransactionSelect(clientId: _clientId, clientName: _name),
    //   textConfirm: "Pay",
    //   textCancel: "Cancel",
    //   confirmTextColor: Colors.white,
      
       
    // );
  }

   

}


class TransactionSelect extends StatefulWidget {
  final String? clientId;
  final String? clientName;

  const TransactionSelect({Key? key, this.clientId, this.clientName}) : super(key: key);

  @override
  _TransactionSelectState createState() => _TransactionSelectState();
}

class _TransactionSelectState extends State<TransactionSelect> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.clientName != null) Text(widget.clientName!),
            ListTile(
              title: Text('Pay Loan'.tr),
              onTap: () {
                // Add action if needed
              },
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
             authController.isLoading2 
              ? Center(child: CircularProgressIndicator()) 
              :   TextButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  int amount = int.parse(_amountController.text);
                  int clientId = int.parse(widget.clientId!);
                  authController.payLoan(clientId, amount);
                } else {
                  print('Amount is empty');
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }}