
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../a_field_office/home/widgets/FormattedLoanAmount .dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../history/widgets/transaction_list_widget.dart';

class BottomSheetContentWidget extends StatefulWidget {
  const BottomSheetContentWidget({ Key? key}) : super(key: key);

  @override
  State<BottomSheetContentWidget> createState() =>
      _BottomSheetContentWidgetState();
}

class _BottomSheetContentWidgetState extends State<BottomSheetContentWidget> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      height: MediaQuery.of(context).size.height  * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                'Today\'s Schedules '.tr,
                style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: Dimensions.paddingSizeDefault,
          ),
          Expanded(
            flex: 10,
            child: Container(
              color: ColorResources.getBackgroundColor(),
              child: SingleChildScrollView(
                  child: todaySchedule()
                  // TransactionListWidget(
                  //     scrollController: scrollController, isHome: true)
                      ),
            ),
          ),
        ],
      ),
    );
  }


  Widget todaySchedule() {
  return GetBuilder<AuthController>(
    builder: (authController) {
      return Container(
        height: MediaQuery.of(context).size.height  * 0.7,
        width: Get.width,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name'),
                    SizedBox(width: 16),
                    Text('Phone'),
                    SizedBox(width: 16),
                    Text('Amount'),
                    SizedBox(width: 16),
                    Icon(Icons.check_circle),
                  ],
                ),
              ),
              const Divider(), // Add a divider between header and content
              authController.agentTodaySche == null
                  ? const Center(child: CircularProgressIndicator())
                  : authController.agentTodaySche.isEmpty
                      ? const Center(child: Text('No schedules for today yet'))
                      : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: ListView.builder(
                              itemCount: authController.agentTodaySche.length,
                              itemBuilder: (context, index) {
                                final loan = authController.agentTodaySche[index];
                                var amount = loan.installAmount;
                                return Padding(
                                  padding:const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(loan.clientName ?? 'N/A'),
                                              FormattedLoanAmount(amount:loan.balance)
                                               
                                            ],
                                          )),
                                          const SizedBox(width: 16),
                                          Expanded(child: Text(loan.clientPhone ?? 'N/A')),
                                          const SizedBox(width: 16),
                                          
                                          Expanded(child: FormattedLoanAmount(amount:amount)),
                                          
                                          // Text('${loan.installAmount ?? '0.00'} /=')),
                                          const SizedBox(width: 16),
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
                                      const Divider(),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ),
                      ),
            ],
          ),
        ),
      );
    },
  );
}
}
