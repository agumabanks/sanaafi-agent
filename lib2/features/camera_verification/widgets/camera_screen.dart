// import 'package:camera/camera.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:six_cash/common/widgets/custom_app_bar_widget.dart';
// import 'package:six_cash/features/auth/screens/sign_up_information_screen.dart';
// import 'package:six_cash/features/camera_verification/controllers/camera_screen_controller.dart';
// import 'package:six_cash/features/camera_verification/controllers/torch.dart';
// import 'package:six_cash/features/camera_verification/widgets/camera_instruction_widget.dart';
// import 'package:six_cash/features/setting/screens/edit_profile_screen.dart';
// import 'package:six_cash/util/color_resources.dart';
// import 'package:torch_light/torch_light.dart';


// class CameraScreen extends StatefulWidget {
//   final bool fromEditProfile;
//   final bool isBarCodeScan;
//   final bool isHome;
//   final String? transactionType;
//   const CameraScreen({
//     Key? key,
//     required this.fromEditProfile,
//     this.isBarCodeScan = false,
//     this.isHome = false,
//     this.transactionType = '',
//   }) : super(key: key);

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {


//   @override
//   void dispose() {
//     Get.find<CameraScreenController>().stopLiveFeed();
//     super.dispose();
//   }
//   @override
//   void initState() {
//     Get.find<CameraScreenController>().valueInitialize(widget.fromEditProfile);
//     Get.find<CameraScreenController>().startLiveFeed(
//       isQrCodeScan: widget.isBarCodeScan,
//       isHome: widget.isHome,
//       transactionType: widget.transactionType,
//     );
    
//     final TorchController torchController = Get.put(TorchController());

//     super.initState();
//   }


//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: CustomAppbarWidget(
//         title: widget.isBarCodeScan ? 'scanner'.tr : 'face_verification'.tr,
//         isSkip: (!widget.isBarCodeScan && true && !widget.fromEditProfile),
//         function: () {
//           if(widget.fromEditProfile) {
//             Get.off(() => const EditProfileScreen());
//           }else{
//             Get.off(() => const SignUpInformationScreen());
//           }
//         },
//       ),
//     floatingActionButton: Padding(
//   padding: const EdgeInsets.only(bottom: 5, right: 5),
//   child: GetBuilder<CameraScreenController>(
//     builder: (controller) {
//       return FloatingActionButton(
//         onPressed: () {
//           // controller.toggleFlashlight();
//                         _enableTorch(context);
//         },
//         elevation: 0,
//         backgroundColor: Theme.of(context).secondaryHeaderColor,
//         child: Icon(
//           controller.isTorchOn.value
//               ? Icons.flashlight_off // Icon when torch is on
//               : Icons.flashlight_on,  // Icon when torch is off
//           color: ColorResources.blackColor,
//           size: 28,
//         ),
//       );
//     },
//   ),
// ),


//       body:  Column(
//         children: [
//         Flexible(flex: 2, child: Stack(children: [
//           GetBuilder<CameraScreenController>(
//               builder: (cameraController) {
//                 if (cameraController.controller == null ||
//                     cameraController.controller?.value.isInitialized == false) {
//                   return const SizedBox();
//                 }

//                 return Container(
//                   color: Colors.black,
//                   height: size.height * 0.7,
//                   width: size.width,
//                   child: AspectRatio(
//                     aspectRatio: cameraController.controller!.value.aspectRatio,
//                     child: CameraPreview(cameraController.controller!),
//                   ),
//                 );
//               }
//           ),

//           FractionallySizedBox(
//             child: Align(
//               alignment: Alignment.center,
//               child: DottedBorder(
//                 strokeWidth: 3,borderType: BorderType.Rect, dashPattern: const [10],color: Colors.white,
//                 child: const FractionallySizedBox(heightFactor: 0.7, widthFactor: 0.8),
//               ),
//             ),
//           ),
//         ])),

//         Flexible(
//           flex: 1,
//           child: CameraInstructionWidget(isBarCodeScan: widget.isBarCodeScan),
//         ),
//       ]),
//     );
//   }



//  Future<bool> _isTorchAvailable(BuildContext context) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       return await TorchLight.isTorchAvailable();
//     } on Exception catch (_) {
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(
//           content: Text('Could not check if the device has an available torch'),
//         ),
//       );
//       rethrow;
//     }
//   }

//   Future<void> _enableTorch(BuildContext context) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       await TorchLight.enableTorch();
//     } on Exception catch (_) {
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(
//           content: Text('Could not enable torch'),
//         ),
//       );
//     }
//   }

//   Future<void> _disableTorch(BuildContext context) async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     try {
//       await TorchLight.disableTorch();
//     } on Exception catch (_) {
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(
//           content: Text('Could not disable torch'),
//         ),
//       );
//     }
//   }
// }

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../auth/screens/sign_up_information_screen.dart';
import '../controllers/camera_screen_controller.dart';
import 'camera_instruction_widget.dart';
import '../../setting/screens/edit_profile_screen.dart';
import '../../../util/color_resources.dart';

class CameraScreen extends StatefulWidget {
  final bool fromEditProfile;
  final bool isBarCodeScan;
  final bool isHome;
  final String? transactionType;

  const CameraScreen({
    Key? key,
    required this.fromEditProfile,
    this.isBarCodeScan = false,
    this.isHome = false,
    this.transactionType = '',
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isTorchOn = false;

  @override
  void dispose() {
    Get.find<CameraScreenController>().stopLiveFeed();
    super.dispose();
  }

  @override
  void initState() {
    Get.find<CameraScreenController>().valueInitialize(widget.fromEditProfile);
    Get.find<CameraScreenController>().startLiveFeed(
      isQrCodeScan: widget.isBarCodeScan,
      isHome: widget.isHome,
      transactionType: widget.transactionType,
    );

    super.initState();
  }

  // Function to toggle torch using the camera's flash mode
  void _toggleTorch() async {
    final cameraController = Get.find<CameraScreenController>().controller;
    if (cameraController != null && cameraController.value.isInitialized) {
      try {
        if (_isTorchOn) {
          await cameraController.setFlashMode(FlashMode.off);
          setState(() {
            _isTorchOn = false;
          });
        } else {
          await cameraController.setFlashMode(FlashMode.torch);
          setState(() {
            _isTorchOn = true;
          });
        }
      } catch (e) {
        Get.snackbar('Error', 'Torch could not be toggled');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppbarWidget(
        title: widget.isBarCodeScan ? 'scanner'.tr : 'face_verification'.tr,
        isSkip: (!widget.isBarCodeScan && true && !widget.fromEditProfile),
        function: () {
          if (widget.fromEditProfile) {
            Get.off(() => const EditProfileScreen());
          } else {
            Get.off(() => const SignUpInformationScreen());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5, right: 5),
        child: FloatingActionButton(
          onPressed: _toggleTorch,
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: Icon(
            _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
            color: ColorResources.blackColor,
            size: 28,
          ),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Stack(
              children: [
                GetBuilder<CameraScreenController>(
                  builder: (cameraController) {
                    if (cameraController.controller == null ||
                        cameraController.controller?.value.isInitialized ==
                            false) {
                      return const SizedBox();
                    }

                    return Container(
                      color: Colors.black,
                      height: size.height * 0.7,
                      width: size.width,
                      child: AspectRatio(
                        aspectRatio:
                            cameraController.controller!.value.aspectRatio,
                        child: CameraPreview(cameraController.controller!),
                      ),
                    );
                  },
                ),
                FractionallySizedBox(
                  child: Align(
                    alignment: Alignment.center,
                    child: DottedBorder(
                      strokeWidth: 3,
                      borderType: BorderType.Rect,
                      dashPattern: const [10],
                      color: Colors.white,
                      child: const FractionallySizedBox(
                          heightFactor: 0.7, widthFactor: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: CameraInstructionWidget(isBarCodeScan: widget.isBarCodeScan),
          ),
        ],
      ),
    );
  }
}
