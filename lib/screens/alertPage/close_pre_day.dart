import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:restro_ms_online/controller/alertController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClosePreviousDayPage extends StatefulWidget {
  const ClosePreviousDayPage({Key? key}) : super(key: key);

  @override
  State<ClosePreviousDayPage> createState() => _ClosePreviousDayPageState();
}

class _ClosePreviousDayPageState extends State<ClosePreviousDayPage> {
  bool isLoading = false;
  void previousdayClose() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');

    final userId = prefs.getString('userid');
    final url = Uri.parse('$baseUrl/api/daySettings/finalClosePrevDay');
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var data = {
      "user_id": userId,
    };
    var body = jsonEncode(data);
    var response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: const DayOpenPage());
          });
    } else {
      Fluttertoast.showToast(
          msg: 'Please try again',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
        const  Text(
            'Please close Previous Day.',
            style: TextStyle(fontSize: 24 ,fontWeight: FontWeight.bold),
          ),
         const SizedBox(height: 10.0,),
          ElevatedButton(
            child: !isLoading
                ? const Text("Close Day")
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent,
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              previousdayClose();
            },
          )
        ],
      ),
    );
  }
}
