import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_code_scanner_controller.dart';
import '../../../helper/dialog_helper.dart';
import '../../../helper/route_helper.dart';
import '../../setting/screens/edit_profile_screen.dart';

import '../../../main.dart';
import '../../auth/screens/sign_up_information_screen.dart';
import '../widgets/loader_dialog_widget.dart';
import 'package:torch_light/torch_light.dart';

class CameraScreenController extends GetxController implements GetxService{
  bool _isBusy = false;
  set setBusy(bool value)=> _isBusy = value;

  String? _text;
  int _eyeBlink = 0;
  int _isSuccess = 0;

  CameraController? controller;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;



  String? get text => _text;
  int get captureLoading => _isSuccess;
  int get eyeBlink => _eyeBlink;
  int get isSuccess => _isSuccess;

  bool _fromEditProfile = false;
  bool get fromEditProfile => _fromEditProfile;

  var isFlashlightOn = false.obs;


  var isTorchAvailable = false.obs;
  var isTorchOn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkTorchAvailability();
  }

  Future<void> checkTorchAvailability() async {
    try {
      isTorchAvailable.value = await TorchLight.isTorchAvailable();
    } catch (e) {
      Get.snackbar('Error', 'Could not check if the device has an available torch');
    }
  }

  Future<void> toggleTorch() async {
    if (isTorchOn.value) {
      await disableTorch();
    } else {
      await enableTorch();
    }
  }

  Future<void> enableTorch() async {
    try {
      await TorchLight.enableTorch();
      isTorchOn.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Could not enable torch');
    }
  }

  Future<void> disableTorch() async {
    try {
      await TorchLight.disableTorch();
      isTorchOn.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Could not disable torch');
    }
  }
  
  // Method to toggle the flashlight
  Future<void> toggleFlashlight() async {
    try {
      if (isFlashlightOn.value) {
        await TorchLight.disableTorch();
        isFlashlightOn(false);
      } else {
        await TorchLight.enableTorch();
        isFlashlightOn(true);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  valueInitialize(bool fromEditProfile) {
    _eyeBlink = 0;
    _isSuccess = 0;
    _fromEditProfile = fromEditProfile;
  }

  Future startLiveFeed({bool isQrCodeScan = false,bool isHome = false, String? transactionType = ''}) async {
    final camera = cameras[isQrCodeScan ? 0 : 1];
    controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // f
    );
    controller?.initialize().then((_) {
      controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });

      controller?.startImageStream((CameraImage cameraImage) => _inputImageFromCameraImage(
        image: cameraImage, camera: camera, isHome: isHome,
        isQrCodeScan: isQrCodeScan, transactionType: transactionType,
      ));

      update();
    });
  }

  Future stopLiveFeed() async {
    _isBusy = false;
    try{
      try{
        await controller?.stopImageStream();
      }catch(e) {
        debugPrint('error ---> $e');
      }
      await controller?.dispose();
       controller = null;
      valueInitialize(_fromEditProfile);
    }catch(e){
      debugPrint('error is : $e');

    }
  }
  Future<void> _inputImageFromCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required bool isQrCodeScan,
    required bool isHome,
    String? transactionType,
  }) async {

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return;
    final plane = image.planes.first;

    // compose InputImage using bytes
    final inputImage =  InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );

    if(isQrCodeScan) {
      Get.find<QrCodeScannerController>().processImage(inputImage, isHome, transactionType);
    }else{
      processImage(inputImage);
    }

  }


  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );

  File? get getImage => _imageFile;

  Future<void> processImage(InputImage inputImage) async {

    if (_isBusy) return;
    _isBusy = true;

    try{
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if(faces.length == 1) {
        if((faces[0].rightEyeOpenProbability ?? 1) < 0.1 && (faces[0].leftEyeOpenProbability ?? 1) < 0.1 && _eyeBlink < 3) {
          _eyeBlink++;
        }
      }
    }catch(e) {
      debugPrint('error ===> $e');
    }

    if(_eyeBlink == 3) {
      try{
        await controller?.stopImageStream().then((value)async {
          DialogHelper.showAnimatedDialog(Get.context!,
            const LoaderDialogWidget(),
              dismissible: false,
              isFlip: true);
          _faceDetector.close();
          final XFile file =  await controller!.takePicture();
          _imageFile =  File(file.path);
        });
      }catch(e){
        debugPrint('error is $e');
      }
      if(_imageFile != null) {
        final inputImage = InputImage.fromFilePath(_imageFile!.path);
        processPicture(inputImage);
      }
    }
    update();
    _isBusy = false;
  }

  Future<void> processPicture(InputImage inputImage) async {

    bool hasEyeOpen = false;
    final faces = await _faceDetector.processImage(inputImage);
    try{
      if(faces.length == 1) {
        if(faces[0].rightEyeOpenProbability != null && faces[0].leftEyeOpenProbability != null) {
          if(faces[0].rightEyeOpenProbability! > 0.2 && faces[0].leftEyeOpenProbability! > 0.2){
            hasEyeOpen = true;
          }
        }
      }
    }catch(e){
      debugPrint('error ---> $e');
    }

    if(hasEyeOpen || GetPlatform.isIOS) {
      _isSuccess = 1;
      update();
      Future.delayed(const Duration(seconds: 1)).then((value) async {
        await _faceDetector.close();
        // stopLiveFeed();
        Get.back();
        if(_fromEditProfile) {
          Get.off(() => const EditProfileScreen());
        }else{
          Get.off(() => const SignUpInformationScreen());
        }
      });


    }else{
      _isSuccess = 2;
      update();
    }

  }
  // camera
  File? _imageFile;


  void removeImage(){
    _imageFile = null;
    update();
  }

  void showDeniedDialog({required bool fromEditProfile}) {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'camera_permission'.tr,
      middleText: 'you_must_allow_permission_for_further_use'.tr,
      confirm: TextButton(onPressed: () async{
        Permission.camera.request().then((value) async{
          var status = await Permission.camera.status;
          if (status.isDenied) {
            Get.back();
            Permission.camera.request();

          }
          else if(status.isGranted){
          }
          else if(status.isPermanentlyDenied){
            return showPermanentlyDeniedDialog(fromEditProfile: fromEditProfile);
          }
        });


      }, child: Text('allow'.tr)),
    );

  }

  void showPermanentlyDeniedDialog({required bool fromEditProfile}) {
    Get.defaultDialog(
        barrierDismissible: false,
        title: 'camera_permission'.tr,
        middleText: 'you_must_allow_permission_for_further_use'.tr,
        confirm: TextButton(onPressed: () async {
          final serviceStatus = await Permission.camera.status ;
          if(serviceStatus.isGranted){
            if(fromEditProfile == true){
              Get.back();
              Get.toNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
            }
            else{
              Get.offNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
            }
          }
          else{
            await openAppSettings().then((value)async{
              // final serviceStatus = await Permission.camera.status ;
              if(serviceStatus.isGranted){
                if(fromEditProfile == true){
                  Get.back();
                  return Get.toNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
                }
                else{
                  Get.back();
                  return Get.offNamed(RouteHelper.getSelfieRoute(fromEditProfile: fromEditProfile));
                }
              }
              else{
                Get.back();
                showPermanentlyDeniedDialog(fromEditProfile: fromEditProfile);
              }
            });
          }

        }, child: Text('go_to_settings'.tr))
    );
  }
}


