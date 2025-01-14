// import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/banner_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../add_money/screens/web_screen.dart';
import 'banner_shimmer_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GetBuilder<SplashController>(
      builder: (splashController) {


        return (splashController.configModel?.systemFeature?.bannerStatus ?? false) ? GetBuilder<BannerController>(builder: (bannerController){
          return bannerController.bannerList == null  ? const Center(child: BannerShimmerWidget()) :
          bannerController.bannerList!.isNotEmpty ?  Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
            child: Stack(
              children: [ ],
            ),
          ) : const SizedBox();
        }) : const SizedBox();
      }
    );
  }
}
