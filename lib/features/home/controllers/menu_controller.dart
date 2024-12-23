import 'package:six_cash/features/a_field_office/home/screens/fo-home.dart';
import 'package:six_cash/features/a_field_office/transactions/screens/LoanTransactionView.dart';
import 'package:six_cash/features/history/screens/history_screen.dart';
import 'package:six_cash/features/home/screens/home_screen.dart';
import 'package:six_cash/features/notification/screens/notification_screen.dart';
import 'package:six_cash/features/setting/screens/profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../a_field_office/clients/screens/ClientsPage.dart';

class MenuItemController extends GetxController implements GetxService{
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;


  final List<Widget> screen = [
    OFHomePage(),
    ClientsPage(),
    LoanTransactionView(),
    // const NotificationScreen(),
    const ProfileScreen()
  ];

  // OFHomePage

  void resetNavBarTabIndex(){
    _currentTabIndex = 0;
  }

  void selectHomePage({bool isUpdate = true}) {
    _currentTabIndex = 0;
    if(isUpdate) {
      update();
    }
  }

  void selectHistoryPage() {
    _currentTabIndex = 1;
    update();
  }

  void selectNotificationPage() {
    _currentTabIndex = 2;
    update();
  }

  void selectProfilePage() {
    _currentTabIndex = 3;
    update();
  }
}
