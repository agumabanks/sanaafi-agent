import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/custom_ink_well_widget.dart';
import '../controllers/transaction_history_controller.dart';
import '../domain/models/transaction_model.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class TransactionTypeButtonWidget extends StatelessWidget {
  final String text;
  final int index;
  final List<Transactions> transactionHistoryList;

  const TransactionTypeButtonWidget({Key? key, required this.text, required this.index, required this.transactionHistoryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Get.find<TransactionHistoryController>().transactionTypeIndex == index ? Theme.of(context).secondaryHeaderColor :  Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
          border: Border.all(width: .5,color: ColorResources.getGreyColor())
      ),
      child: CustomInkWellWidget(
        onTap: () => Get.find<TransactionHistoryController>().setIndex(index),
        radius: Dimensions.radiusSizeLarge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
          child: Text(text,
              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Get.find<TransactionHistoryController>().transactionTypeIndex == index
                  ? ColorResources.blackColor : Theme.of(context).textTheme.titleLarge!.color)),
        ),
      ),
    );
  }
}
