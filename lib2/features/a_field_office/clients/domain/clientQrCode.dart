
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';


// Function to parse JSON response
ClientQrCode clientQrCodeFromJson(String str) => ClientQrCode.fromJson(json.decode(str));

// Define the ClientQrCode class
class ClientQrCode {
  String? qrCode;

  ClientQrCode({this.qrCode});

  factory ClientQrCode.fromJson(Map<String, dynamic> json) {
    return ClientQrCode(
      qrCode: json["qr_code"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "qr_code": qrCode,
    };
  }
}