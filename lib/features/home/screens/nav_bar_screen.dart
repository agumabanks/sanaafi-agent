import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Replace these imports with your actual file references
import 'package:six_cash/common/widgets/custom_dialog_widget.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
import 'package:six_cash/features/camera_verification/screens/camera_screen.dart';
import 'package:six_cash/features/home/controllers/menu_controller.dart';
import 'package:six_cash/features/home/widgets/bottom_item_widget.dart';
import 'package:six_cash/features/home/widgets/floating_action_button_widget.dart';
import 'package:six_cash/features/splash/screens/splash_screen.dart';
import 'package:six_cash/helper/dialog_helper.dart';
import 'package:six_cash/util/color_resources.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/util/images.dart';

// PopScope is assumed to be your custom widget that handles back navigation logic.
class PopScope extends StatelessWidget {
  final bool canPop;
  final Function(bool) onPopInvoked;
  final Widget child;

  const PopScope({
    Key? key,
    required this.canPop,
    required this.onPopInvoked,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (canPop) {
          onPopInvoked(true);
          return false;
        }
        onPopInvoked(false);
        return false;
      },
      child: child,
    );
  }
}

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({Key? key}) : super(key: key);

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    Get.find<MenuItemController>().selectHomePage(isUpdate: false);
    Get.find<AuthController>().checkBiometricWithPin();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (_) => _onWillPop(context),
      child: GetBuilder<MenuItemController>(builder: (menuController) {
        return Scaffold(
          backgroundColor: Theme.of(context)
              .bottomNavigationBarTheme
              .selectedItemColor,
          body: PageStorage(
            bucket: bucket,
            child: menuController.screen[menuController.currentTabIndex],
          ),

          /// Wrap the bottom navigation in a Padding (or Container with margin) 
          /// to move it up from the very bottom of the screen.
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 12.0,left: 10, right: 10), // Adjust as needed
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),

                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorResources.getBlackAndWhite().withOpacity(0.14),
                    blurRadius: 80,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: ColorResources.getBlackAndWhite().withOpacity(0.20),
                    blurRadius: 0.5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomItemWidget(
                    onTop: () => menuController.selectHomePage(),
                    icon: menuController.currentTabIndex == 0
                        ? Images.homeIconBold
                        : Images.homeIcon,
                    name: 'home'.tr,
                    selectIndex: 0,
                  ),
                  BottomItemWidget(
                    onTop: () => menuController.selectHistoryPage(),
                    icon: menuController.currentTabIndex == 1
                        ? Images.clockIconBold
                        : Images.clockIcon,
                    name: 'history'.tr,
                    selectIndex: 1,
                  ),
                  BottomItemWidget(
                    onTop: () => menuController.selectNotificationPage(),
                    icon: menuController.currentTabIndex == 2
                        ? Images.notificationIconBold
                        : Images.notificationIcon,
                    name: 'notification'.tr,
                    selectIndex: 2,
                  ),
                  BottomItemWidget(
                    onTop: () => menuController.selectProfilePage(),
                    icon: menuController.currentTabIndex == 3
                        ? Images.profileIconBold
                        : Images.profileIcon,
                    name: 'profile'.tr,
                    selectIndex: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onWillPop(BuildContext context) {
    DialogHelper.showAnimatedDialog(
      context,
      CustomDialogWidget(
        icon: Icons.exit_to_app_rounded,
        title: 'exit'.tr,
        description: 'do_you_want_to_exit_the_app'.tr,
        onTapFalse: () => Navigator.of(context).pop(false),
        onTapTrue: () {
          SystemNavigator.pop().then(
            (value) => Get.offAll(() => const SplashScreen()),
          );
        },
        onTapTrueText: 'yes'.tr,
        onTapFalseText: 'no'.tr,
      ),
      dismissible: false,
      isFlip: true,
    );
  }
}
