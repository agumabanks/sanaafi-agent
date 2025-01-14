import 'package:get/get_connect/http/src/response/response.dart';
import '../../../../data/api/api_client.dart';
import '../../../../util/app_constants.dart';

class WebsiteLinkRepo{
  final ApiClient apiClient;

  WebsiteLinkRepo({required this.apiClient});

  Future<Response> getWebsiteListApi() async {
    return await apiClient.getData(AppConstants.customerLinkedWebsite);
  }
}