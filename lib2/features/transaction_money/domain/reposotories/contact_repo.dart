import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/models/contact_model.dart';
import '../../../../data/api/api_client.dart';
import '../enums/suggest_type_enum.dart';
import '../../../../util/app_constants.dart';

class ContactRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ContactRepo({required this.apiClient, required this.sharedPreferences});

  List<ContactModel>? getRecentList({required String? type})  {
    String? recent = '';
    String key = type == AppConstants.sendMoney ?
    AppConstants.sendMoneySuggestList : type == AppConstants.cashOut ?
    AppConstants.recentAgentList : AppConstants.requestMoneySuggestList;

    if(sharedPreferences.containsKey(key)){
      try {
        recent =  sharedPreferences.get(key) as String?;
      }catch(error) {
        recent = '';
      }
    }

    if(recent != null && recent != '' && recent != 'null'){
      return  contactModelFromJson(utf8.decode(base64Url.decode(recent.replaceAll(' ', '+'))));
    }

    return null;

  }

  void addToSuggestList(List<ContactModel> contactModelList,{required SuggestType type}) async {
    String suggests = base64Url.encode(utf8.encode(contactModelToJson(contactModelList)));

    switch(type) {
      case SuggestType.sendMoney:
        await sharedPreferences.setString(AppConstants.sendMoneySuggestList, suggests);
        break;
      case SuggestType.cashOut:
        await sharedPreferences.setString(AppConstants.recentAgentList, suggests);
        break;
      case SuggestType.requestMoney:
        await sharedPreferences.setString(AppConstants.requestMoneySuggestList, suggests);
        break;
    }
  }

  Future<Response>  checkCustomerNumber({required String phoneNumber}) async {
    return await apiClient.postData(AppConstants.checkCustomerUri, {'phone' : phoneNumber});
  }
  Future<Response>  checkAgentNumber({required String phoneNumber}) async {
    return await apiClient.postData(AppConstants.checkAgentUri, {'phone' : phoneNumber});
  }


}