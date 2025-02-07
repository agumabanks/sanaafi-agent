import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';

class PreviewAmountWidget extends StatelessWidget {
  const PreviewAmountWidget({ Key? key, required this.amountText, this.onTap, this.title }) : super(key: key);
  final String amountText;
  final String? title;
  final Function? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            child: Text(title != null ? title! : 'amount'.tr, style: rubikMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: ColorResources.getGreyBaseGray1(),
            )),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(PriceConverterHelper.balanceWithSymbol(balance: amountText), style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              if(onTap != null) InkWell(
                onTap: onTap as void Function()?,
                child: Image.asset(Images.editIcon, height: Dimensions.radiusSizeExtraLarge,width: Dimensions.radiusSizeExtraLarge)
              )
            ]
          )
        ],
      ),
    );
  }
}