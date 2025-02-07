import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/verification_controller.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../../common/widgets/rounded_button_widget.dart';

class TimerSection extends StatelessWidget {
  final String phoneNumber;
  final bool isForgetPassword;
  const TimerSection({Key? key, required this.phoneNumber, required this.isForgetPassword}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return GetBuilder<VerificationController>(builder: (verificationController){
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Visibility(
            visible: verificationController.visibility && !authController.isLoading,
            child: RoundedButtonWidget(
              buttonText: 'resend_otp'.tr,
              onTap: (){

                if(isForgetPassword){
                  authController.otpForForgetPass(phoneNumber).then((value){
                    verificationController.setVisibility(false);
                    verificationController.startTimer();
                  });
                }else{
                  authController.checkPhone(phoneNumber).then((value){
                    if(value.statusCode == 200){
                      verificationController.setVisibility(false);
                      verificationController.startTimer();
                    }
                  });
                }

              },
            ),
          ),

          Visibility(
            visible: !verificationController.visibility,
            child: Text('${'resend_otp'.tr} ${'in'.tr} ${verificationController.maxSecond} ${'seconds'.tr}',
              style: rubikRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]);
      });
    });
  }
}