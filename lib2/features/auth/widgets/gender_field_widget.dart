import '../../setting/controllers/edit_profile_controller.dart';
import '../../setting/controllers/profile_screen_controller.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gender_card_widget.dart';
class GenderFieldWidget extends StatelessWidget {
  final bool fromEditProfile;
  const GenderFieldWidget({
    Key? key,
    this.fromEditProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController){
      return GetBuilder<EditProfileController>(
        builder: (editProfileController) {
          String? gender = fromEditProfile ? editProfileController.gender : profileController.gender;
          return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeExtraLarge,
            left: Dimensions.paddingSizeLarge,
            bottom: Dimensions.paddingSizeDefault,
          ),

          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: ColorResources.getShadowColor().withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 3),
                )
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'select_your_gender'.tr,
                style: rubikMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
              const SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GenderCardWidget(
                      icon: Images.male,
                      text: 'male'.tr,
                      color: gender == 'Male' ? Theme.of(context).secondaryHeaderColor:ColorResources.genderDefaultColor.withOpacity(0.5),
                      onTap: ()=> fromEditProfile ? editProfileController.setGender('Male') : profileController.setGender('Male'),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall,),

                     GenderCardWidget(
                      icon: Images.female,
                      text: 'female'.tr,
                      color: gender == 'Female' ? Theme.of(context).secondaryHeaderColor:ColorResources.genderDefaultColor.withOpacity(0.5),
                      onTap: () => fromEditProfile ? editProfileController.setGender('Female') : profileController.setGender('Female'),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall,),
                     GenderCardWidget(
                      icon: Images.other,
                      text: 'other'.tr,
                      color: gender == 'Other' ? Theme.of(context).secondaryHeaderColor:ColorResources.genderDefaultColor.withOpacity(0.5),
                       onTap: () => fromEditProfile ? editProfileController.setGender('Other') : profileController.setGender('Other'),

                     ),
                  ],
                ),
              )
            ],
          ),
    );
        }
      );
    });
  }
}