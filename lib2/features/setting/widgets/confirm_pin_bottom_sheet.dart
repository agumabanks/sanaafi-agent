
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../transaction_money/controllers/bootom_slider_controller.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../transaction_money/widgets/next_button_widget.dart';

class ConfirmPinBottomSheet extends StatelessWidget {
  final Function? callBack;
  final bool isAuth;
   ConfirmPinBottomSheet({Key? key, this.callBack, this.isAuth = false}) : super(key: key);
   final TextEditingController _textEditingController = TextEditingController();

   @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Container(
              alignment: Alignment.center,
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27.0),
                  color: ColorResources.getGreyBaseGray6()
              ),

              child:PinCodeTextField(
                controller: _textEditingController,
                length: 4, appContext:  context, onChanged: (value){
                Get.find<BottomSliderController>().updatePinCompleteStatus(value);
              },

                keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                obscureText: true, hintCharacter: '•', hintStyle: rubikMedium.copyWith(color: ColorResources.getGreyBaseGray4()),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                cursorColor: ColorResources.getGreyBaseGray6(),

                pinTheme: PinTheme.defaults(
                  shape: PinCodeFieldShape.circle,
                  activeColor: ColorResources.getGreyBaseGray6(),
                  activeFillColor: Colors.red,selectedColor: ColorResources.getGreyBaseGray6(),
                  borderWidth: 0,

                  inactiveColor: ColorResources.getGreyBaseGray6(),
                  //fieldHeight: 20.0
                ),

              ),

            ),
          ),
        ),

        InkWell(
            onTap: () {
              if(Get.find<BottomSliderController>().isPinCompleted) {
                if(isAuth) {
                  callBack!(!Get.find<AuthController>().biometric);
                }else{
                  callBack!();
                }

              }else {
                Get.find<BottomSliderController>().updatePinCompleteStatus('');
                Get.back(closeOverlays: true);
                showCustomSnackBarHelper('please_input_4_digit_pin'.tr);
              }
            },

            child: GetBuilder<BottomSliderController>(
                builder: (controller) {
                  return controller.isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).textTheme.titleLarge!.color,)): NextButtonWidget(isSubmittable: controller.isPinCompleted);
                }
            )
        )
      ],
    );
  }
}
