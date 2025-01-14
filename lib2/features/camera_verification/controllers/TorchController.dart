import 'package:get/get.dart';
import 'package:torch_light/torch_light.dart';

class TorchController extends GetxController {
  bool isTorchOn = false;

  // Check if the torch is available
  Future<bool> isTorchAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      Get.snackbar('Error', 'Could not check if the device has an available torch');
      return false;
    }
  }

  // Enable torch
  Future<void> enableTorch() async {
    try {
      await TorchLight.enableTorch();
      isTorchOn = true;
      update(); // Update UI
    } on Exception catch (_) {
      Get.snackbar('Error', 'Could not enable torch');
    }
  }

  // Disable torch
  Future<void> disableTorch() async {
    try {
      await TorchLight.disableTorch();
      isTorchOn = false;
      update(); // Update UI
    } on Exception catch (_) {
      Get.snackbar('Error', 'Could not disable torch');
    }
  }

  // Toggle torch
  Future<void> toggleTorch() async {
    if (isTorchOn) {
      await disableTorch();
    } else {
      await enableTorch();
    }
  }
}