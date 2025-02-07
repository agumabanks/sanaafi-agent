import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../../common/widgets/custom_password_field_widget.dart';

class PinFieldWidget extends StatelessWidget {
  final TextEditingController passController, confirmPassController;
   PinFieldWidget({
     Key? key,
     required this.passController,
     required this.confirmPassController
   }) : super(key: key);

   final FocusNode confirmFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraExtraLarge,
        vertical: Dimensions.paddingSizeExtraExtraLarge,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusSizeExtraExtraLarge),
          topRight: Radius.circular(Dimensions.radiusSizeExtraExtraLarge),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.radiusSizeExtraExtraLarge),
              child: Text(
                'set_your_4_digit'.tr,
                textAlign: TextAlign.center,
                style: rubikMedium.copyWith(
                  color: Theme.of(context).textTheme.titleLarge!.color,
                  fontSize: Dimensions.fontSizeExtraOverLarge,
                ),
              ),
            ),
            const SizedBox(
              height: Dimensions.paddingSizeExtraOverLarge,
            ),
            CustomPasswordFieldWidget(
              controller: passController,
              nextFocus: confirmFocus,
              isPassword: true,
              isShowSuffixIcon: true,
              isIcon: false,
              hint: 'set_your_pin'.tr,
              letterSpacing: 10.0,

            ),
            const SizedBox(
              height: Dimensions.paddingSizeExtraLarge,
            ),
            CustomPasswordFieldWidget(
              controller: confirmPassController,
              focusNode: confirmFocus,
              hint: 'confirm_pin'.tr,
              isShowSuffixIcon: true,
              isPassword: true,
              isIcon: false,
              letterSpacing: 10.0,

            ),

          ],
        ),
      ),
    );
  }
}
