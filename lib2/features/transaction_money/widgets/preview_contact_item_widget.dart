import 'package:flutter/material.dart';
import '../../../common/models/contact_model.dart';
import '../../../util/color_resources.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class PreviewContactItemWidget extends StatelessWidget {
  final ContactModel? contactModel;
  const PreviewContactItemWidget({Key? key, required this.contactModel,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    String phoneNumber = contactModel!.phoneNumber!;
    if(phoneNumber.contains('-')) {
      phoneNumber.replaceAll('-', '');
    }


    return ListTile(
        title:  Text(contactModel!.name==null?phoneNumber: contactModel!.name!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
        subtitle:phoneNumber.isEmpty? const SizedBox():
          Text(phoneNumber, style: rubikLight.copyWith(fontSize: Dimensions.fontSizeLarge, color: ColorResources.getGreyBaseGray1()),),
      );
  }
}



