import 'package:flutter/material.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class GenderCardWidget extends StatelessWidget {
  final String? icon, text;
  final Color? color;
  final Function? onTap;
  const GenderCardWidget({Key? key, this.icon, this.text, this.color,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: 76,
        width: 94,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(icon!),
            ),
            const SizedBox(
              height: Dimensions.paddingSizeExtraSmall,
            ),
            Text(
              text!,
              style: rubikRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
