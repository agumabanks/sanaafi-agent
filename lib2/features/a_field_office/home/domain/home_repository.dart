// import 'package:your_app/models/agent.dart';
// import 'package:your_app/data/api/api_client.dart';

import '../../../../data/api/api_client.dart';

import 'agent.dart';

class HomeRepository {
  final ApiClient apiClient;
  HomeRepository({required this.apiClient});

  Future<Agent> getAgentData() async {
    // Fetch agent data from API
    var response = await apiClient.getData('agent');
    return Agent.fromJson(response.body);
  }
}
