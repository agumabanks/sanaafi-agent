import 'package:get/get_connect/http/src/response/response.dart';
import '../../../../data/api/api_client.dart';
import '../../../../util/app_constants.dart';

class NotificationRepo{
  final ApiClient apiClient;

  NotificationRepo({required this.apiClient});

  Future<Response> getNotificationList(int offset) async {
    return await apiClient.getData('${AppConstants.notificationUri}?limit=10&offset=$offset');
  }
}