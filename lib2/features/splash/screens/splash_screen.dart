import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/splash_controller.dart';
import '../../transaction_money/controllers/contact_controller.dart';
import '../../../data/api/api_checker.dart';
import '../../auth/domain/models/user_short_data_model.dart';
import '../../../helper/route_helper.dart';
import '../../../util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/custom_snackbar_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();

    bool isFirstTime = true;

    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      if (await ApiChecker.isVpnActive()) {
        showCustomSnackBarHelper('you are using vpn', isVpn: true, duration: const Duration(minutes: 10));
      }
      if (isFirstTime) {
        isFirstTime = false;
        await _route();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _route() async {
    await Get.find<ContactController>().getContactList().then((_) {
      Get.find<SplashController>().getConfigData().then((value) {
        if (value.isOk) {
          Timer(const Duration(seconds: 1), () async {
            Get.find<SplashController>().initSharedData().then((value) {
              UserShortDataModel? userData = Get.find<AuthController>().getUserData();

              if (userData != null && (Get.find<SplashController>().configModel!.companyName != null)) {
                Get.offNamed(RouteHelper.getLoginRoute(
                  countryCode: userData.countryCode, phoneNumber: userData.phone,
                ));
              } else {
                Get.offNamed(RouteHelper.getChoseLoginRegRoute());
              }
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(), // Spacer for top alignment
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.logo, height: 175),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0), // Add some padding to bottom
              child: Text("By Sanaa"), // "By Sanaa" at the bottom of the screen
            ),
          ],
        ),
      ),
    );
  }
}
