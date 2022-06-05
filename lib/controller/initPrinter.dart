import 'dart:typed_data';

import 'package:flutter/material.dart';

class PrinterIpAddressController with ChangeNotifier {
  dynamic companyInfo;
  String? printerIpAddress;
  int? printerPort;
  bool isLoading = false;
  Uint8List? imagebytes;
  get getPrinterIpAddress => printerIpAddress;
  get getPrinterPort => printerPort;
  get getLoading => isLoading;
  get getCompanyInfo => companyInfo;
  Uint8List? get imageBytes=>imagebytes;

  setPrinterIpAddress(String? ipAddress, int? port,Uint8List? imageBytes) {
    printerIpAddress = ipAddress;
    printerPort = port;
    imagebytes = imageBytes;
    notifyListeners();
  }
  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
  setCompanyProfile(data) {
    companyInfo = data;
    notifyListeners();
  }
}
