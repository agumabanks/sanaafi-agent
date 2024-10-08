import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:six_cash/common/models/contact_model.dart';
import 'package:six_cash/features/auth/controllers/auth_controller.dart';
import 'package:six_cash/util/dimensions.dart';

class QrCodeScannerController extends GetxController implements GetxService {
  bool _isBusy = false;
  bool _isDetect = false;

  String? _name;
  String? _phone;
  String? _type;
  String? _image;
  String? _clientId;
  String? _transactionType;

  String? get name => _name;
  String? get phone => _phone;
  String? get type => _type;
  String? get image => _image;
  String? get transactionType => _transactionType;
  String? get clientId => _clientId;

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  Future<void> processImage(InputImage inputImage, bool isHome, String? transactionType) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            final data = jsonDecode(barcode.rawValue!);
           
              _name = data['name']?.toString(); // Ensure it's a string
                _phone = data['phone']?.toString(); // Ensure it's a string
                _type = data['type']?.toString(); // Ensure it's a string
                _image = data['image']?.toString(); // Ensure it's a string
                _clientId = data['clientid']?.toString(); // Convert int to string if necessary

            if (_name != null && _phone != null && _image != null) {
              _transactionType = _type == "customer" ? transactionType : "cash_out";
              if (isHome && _type != "agent" && !_isDetect) {
                Get.defaultDialog(
                  title: 'Select Option'.tr,
                  content: TransactionSelect(clientId: _clientId, clientName: _name),
                  barrierDismissible: false,
                  radius: Dimensions.radiusSizeDefault,
                ).then((value) => _isDetect = false);
                _isDetect = true;
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle error
      print('Error processing image: $e');
    } finally {
      _isBusy = false;
    }
  }

void resetValues() {
  _name = null;
  _phone = null;
  _type = null;
  _image = null;
  _clientId = null;
  _transactionType = null;
  _isDetect = false;
  print('-----------------------------data reset');
}

}

class TransactionSelect extends StatefulWidget {
  final String? clientId;
  final String? clientName;

  const TransactionSelect({Key? key, this.clientId, this.clientName}) : super(key: key);

  @override
  _TransactionSelectState createState() => _TransactionSelectState();
}

class _TransactionSelectState extends State<TransactionSelect> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.clientName != null) Text(widget.clientName!),
            ListTile(
              title: Text('Pay Loan'.tr),
              onTap: () {
                // Add action if needed
              },
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
             authController.isLoading2 
              ? Center(child: CircularProgressIndicator()) 
              :   TextButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  int amount = int.parse(_amountController.text);
                  int clientId = int.parse(widget.clientId!);
                  authController.payLoan(clientId, amount);
                } else {
                  print('Amount is empty');
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }
}
