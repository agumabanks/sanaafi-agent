
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/banner_controller.dart';
import '../controllers/home_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../setting/controllers/profile_screen_controller.dart';
import '../../requested_money/controllers/requested_money_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../../transaction_money/controllers/transaction_controller.dart';
import '../../history/controllers/transaction_history_controller.dart';
import '../controllers/websitelink_controller.dart';
import '../../../util/dimensions.dart';
import '../widgets/home_app_bar_widget.dart';
import '../widgets/bottomsheet_content_widget.dart';
import '../widgets/persistent_header_widget.dart';
import '../widgets/theme_one_widget.dart';
import '../widgets/linked_website_widget.dart';
import '../widgets/theme_two_widget.dart';
import '../widgets/theme_three_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _loadData(BuildContext context, bool reload) async {
    if(reload){
      Get.find<SplashController>().getConfigData();
    }

    Get.find<ProfileController>().getProfileData(reload: reload);
    Get.find<BannerController>().getBannerList(reload);
    Get.find<RequestedMoneyController>().getRequestedMoneyList(reload, isUpdate: reload);
    Get.find<RequestedMoneyController>().getOwnRequestedMoneyList(reload, isUpdate: reload);
    Get.find<TransactionHistoryController>().getTransactionData(1, reload: reload);
    Get.find<WebsiteLinkController>().getWebsiteList(reload, isUpdate: reload);
    Get.find<NotificationController>().getNotificationList(reload);
    Get.find<TransactionMoneyController>().getPurposeList(reload,  isUpdate: reload);
    Get.find<TransactionMoneyController>().getWithdrawMethods(isReload: reload);
    Get.find<RequestedMoneyController>().getWithdrawHistoryList(reload: false);




  }
  @override
  void initState() {

    _loadData(context, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<HomeController>(
        builder: (controller) {
          return Scaffold(
            appBar: const HomeAppBarWidget(),
            body: ExpandableBottomSheet(
                enableToggle: true,
                background: RefreshIndicator(
                  onRefresh: () async => await _loadData(context, true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: GetBuilder<SplashController>(builder: (splashController) {
                      int themeIndex = splashController.configModel!.themeIndex ?? 1;
                      return Column(children: [

                        themeIndex == 1 ?  const ThemeOneWidget() :
                        themeIndex == 2 ? const ThemeTwoWidget() :
                        themeIndex == 3 ? const ThemeThreeWidget() :
                        const ThemeOneWidget(),


                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        const LinkedWebsiteWidget(),
                        const SizedBox(height: 80),

                      ]);
                    }),
                  ),
                ),
                persistentContentHeight: 70,
                persistentHeader: const PersistentHeaderWidget(),
                expandableContent: const BottomSheetContentWidget()
            ),
          );
        });
  }

}

