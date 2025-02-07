
import 'package:flutter/material.dart';
import '../../util/dimensions.dart';
import '../../util/styles.dart';

class CustomLargeButtonWidget extends StatelessWidget {
  final String? text;
  final Function? onTap;
  final Color? backgroundColor;
  final double bottomPadding;
  const CustomLargeButtonWidget({Key? key,
    this.backgroundColor,
    this.onTap,
    this.text,
    this.bottomPadding = Dimensions.paddingSizeExtraOverLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(
          left: Dimensions.paddingSizeExtraExtraLarge,
          right: Dimensions.paddingSizeExtraExtraLarge,
          bottom: bottomPadding,
      ),
      child: TextButton(
        onPressed: onTap as void Function()?,
        style: TextButton.styleFrom(
          minimumSize: MediaQuery.of(context).size,
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
          ),
        ),
        child:  Text(
          text!,
          style: rubikRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
      ),
    );
  }
}
