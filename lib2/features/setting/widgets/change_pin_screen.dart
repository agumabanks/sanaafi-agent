import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../controllers/profile_screen_controller.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_password_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({Key? key}) : super(key: key);

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _oldPinFocus = FocusNode();
  final FocusNode _newPinFocus = FocusNode();
  final FocusNode _confirmPinFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return ModalProgressHUD(
          inAsyncCall: controller.isLoading,
          progressIndicator: CustomLoaderWidget(color: Theme.of(context).textTheme.titleLarge!.color,),
          child: Scaffold(
              backgroundColor: ColorResources.getBackgroundColor(),
              appBar: CustomAppbarWidget(title: 'pin_change'.tr),
              body:  SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraOverLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  Dimensions.radiusSizeExtraExtraLarge),
                          child: Text(
                            'set_your_4_digit'.tr,
                            textAlign: TextAlign.center,
                            style: rubikMedium.copyWith(
                                color: Theme.of(context).textTheme.titleLarge!.color,
                                fontSize:
                                    Dimensions.fontSizeExtraOverLarge),
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraOverLarge,
                        ),
                        CustomPasswordFieldWidget(
                          controller: _oldPasswordController,
                          focusNode: _oldPinFocus,
                          isPassword: true,
                          isShowSuffixIcon: true,
                          isIcon: false,
                          hint: 'old_password'.tr,
                          letterSpacing: 10.0,
                          nextFocus: _newPinFocus,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        CustomPasswordFieldWidget(
                          controller: _newPasswordController,
                          focusNode: _newPinFocus,
                          nextFocus: _confirmPinFocus,
                          hint: 'new_password'.tr,
                          isShowSuffixIcon: true,
                          isPassword: true,
                          isIcon: false,
                          textAlign: TextAlign.start,
                          letterSpacing: 10.0,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                        CustomPasswordFieldWidget(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPinFocus,
                          textInputAction: TextInputAction.done,
                          hint: 'confirm_password'.tr,
                          isShowSuffixIcon: true,
                          isPassword: true,
                          isIcon: false,
                          letterSpacing: 10.0,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),
                      ],
                    ),
                  ),
                ),
              floatingActionButton:
                  GetBuilder<ProfileController>(builder: (controller) {
                return FloatingActionButton(
                  elevation: 0,
                  onPressed: () => controller.changePin(
                      oldPassword: _oldPasswordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      newPassword: _newPasswordController.text),
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  child: Icon(Icons.arrow_forward,color: ColorResources.blackColor,),
                );
              })),
        );
      },
    );
  }
}
