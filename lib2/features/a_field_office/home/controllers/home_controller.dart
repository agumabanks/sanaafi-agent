import 'package:get/get.dart';
import '../domain/agent.dart';
import '../domain/home_repository.dart';
// import 'package:your_app/models/agent.dart';
// import 'package:your_app/repositories/home_repository.dart';

class OFHomeController extends GetxController {
  final HomeRepository homeRepository;
  OFHomeController({required this.homeRepository});

  // var isLoading = false.obs;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  var agentName = ''.obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgentData();
  }

  void fetchAgentData() async {
    // isLoading(true);
    _isLoading = true;
    try {
      Agent agent = await homeRepository.getAgentData();
      agentName(agent.name);
    } finally {
      
      _isLoading = false;
    }
  }

  void changeTabIndex(int index) {
    currentIndex(index);
  }
}
