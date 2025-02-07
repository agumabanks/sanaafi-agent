import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../camera_verification/controllers/camera_screen_controller.dart';
import '../controllers/create_account_controller.dart';
import '../../setting/controllers/profile_screen_controller.dart';
import '../../verification/controllers/verification_controller.dart';
import '../../../data/api/api_client.dart';
import '../../../common/models/signup_body_model.dart';
import '../../../util/dimensions.dart';
import '../../../common/widgets/appbar_header_widget.dart';
import '../../../common/widgets/custom_country_code_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../widgets/pin_field_widget.dart';

class PinSetScreen extends StatefulWidget {
  final SignUpBodyModel signUpBody;
  const PinSetScreen({Key? key, required this.signUpBody}) : super(key: key);

  @override
  State<PinSetScreen> createState() => _PinSetScreenState();
}

class _PinSetScreenState extends State<PinSetScreen> {
  final TextEditingController passController = TextEditingController();

  final TextEditingController confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(children: [
          Expanded(flex: 6, child: Container(color: Theme.of(context).primaryColor)),

          Expanded(flex: 5, child: Container(color: Theme.of(context).cardColor)),
        ]),

        const Positioned(
          top: Dimensions.paddingSizeOverLarge,
          left: 0, right: 0,
          child: AppBarHeaderWidget(),
        ),

        Positioned(top: context.height * 0.18, left: 0, right: 0, bottom: 0, child: PinFieldWidget(
          passController: passController,
          confirmPassController: confirmPassController,
        )),
      ]),

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeLarge,
          horizontal: Dimensions.paddingSizeSmall,
        ),
        child: FloatingActionButton(
          onPressed: () {
            String password =  passController.text.trim();
            String confirmPassword =  confirmPassController.text.trim();

            if(password.isEmpty  || confirmPassword.isEmpty){
              showCustomSnackBarHelper('enter_your_pin'.tr);
            }else if(password.length < 4 ){
              showCustomSnackBarHelper('pin_should_be_4_digit'.tr);
            }else if(password != confirmPassword){
              showCustomSnackBarHelper('pin_not_matched'.tr);
            }else{
              String gender =  Get.find<ProfileController>().gender;
              String countryCode = CustomCountryCodeWidget.getCountryCode(Get.find<CreateAccountController>().phoneNumber)!;
              String phoneNumber = Get.find<CreateAccountController>().phoneNumber!.replaceAll(countryCode, '');
              File? image =  Get.find<CameraScreenController>().getImage;
              String? otp =  Get.find<VerificationController>().otp;

              SignUpBodyModel signUpBody = SignUpBodyModel(
                  fName: widget.signUpBody.fName,
                  lName: widget.signUpBody.lName,
                  gender: gender,
                  occupation: widget.signUpBody.occupation,
                  email: widget.signUpBody.email,
                  phone: phoneNumber,
                  otp: otp,
                  password: password,
                  dialCountryCode: countryCode
              );

              MultipartBody multipartBody = MultipartBody('image',image );
              Get.find<AuthController>().registration(signUpBody,[multipartBody]);
            }

          },
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: GetBuilder<AuthController>(builder: (controller){
            return !controller.isLoading ? SizedBox(

              child:  Icon(Icons.arrow_forward,color: Theme.of(context).textTheme.bodyLarge!.color,size: 28,),
            ) : Center(child: SizedBox(height: 20.33,
                width: 20.33,
                child: CircularProgressIndicator(color: Theme.of(context).primaryColor)));
          },),
        ) ,
      ),
    );
  }
}
