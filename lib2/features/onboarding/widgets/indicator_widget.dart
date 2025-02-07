import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/on_boarding_controller.dart';
import '../../../util/app_constants.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
      
      builder: (onBoardController) {
      return AnimatedSmoothIndicator(
        activeIndex: onBoardController.page,
        count: AppConstants.onboardList.length,
        curve: Curves.easeOutSine,
        effect: CustomizableEffect(

          dotDecoration: DotDecoration(
            height: 6,
            width: 6,
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.2),
          ),
          activeDotDecoration: DotDecoration(
            height: 5,
            width: 16,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).textTheme.titleLarge!.color!,

          ),
        ),
      );
    });
  }
}
