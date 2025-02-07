import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../util/dimensions.dart';
import '../../util/images.dart';
import '../../util/styles.dart';
class NoDataFoundWidget extends StatelessWidget {
  final bool? fromHome;
  const  NoDataFoundWidget({Key? key, this.fromHome = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fromHome! ?  noDataWidget(context) : SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: noDataWidget(context));
  }

  Padding noDataWidget(BuildContext context) {
    return Padding(
    padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.025),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset( Images.noData, width: 150, height: 150),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
             'no_data_found'.tr, textAlign: TextAlign.center, style: rubikRegular,
          ),
          const SizedBox(height: 40),

        ],
      ),
    ),
  );
  }
}
