// ignore: file_names
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:package_info/package_info.dart';

import 'package:provider/provider.dart';

import 'package:restro_ms_online/controller/alertController.dart';
import 'package:restro_ms_online/controller/initPrinter.dart';
import 'package:restro_ms_online/controller/urlController.dart';
import 'package:restro_ms_online/main.dart';
import 'package:restro_ms_online/screens/alertPage/message.dart';
import 'package:restro_ms_online/screens/homescreen.dart';
import 'package:restro_ms_online/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  void getPrinter() async {
    try {
      final printIpAddress =
          Provider.of<PrinterIpAddressController>(context, listen: false);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userid');
      var baseUrl = prefs.getString('baseUrl');
      printIpAddress.setLoading(true);
      var printerUrl = Uri.parse("$baseUrl/api/counters/printer/$userId");
      var response = await http.get(printerUrl);
      print(response.statusCode);
      print(userId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        final image = (data['qrcodes']['fonepay']) ?? '';
        if (image.isEmpty) {
          Uint8List bytess = Uint8List.fromList([]);
          printIpAddress.setPrinterIpAddress(
              data['ip_address'], int.tryParse(data['port']), bytess);
          printIpAddress.setLoading(false);
        } else {
          final ByteData imageData =
              await NetworkAssetBundle(Uri.parse(image)).load("");

          Uint8List bytess = imageData.buffer.asUint8List();
          printIpAddress.setPrinterIpAddress(
              data['ip_address'], int.tryParse(data['port']), bytess);
          printIpAddress.setLoading(false);
        }
      } else {
        Fluttertoast.showToast(msg: 'Unable TO load data');
      }
    } catch (erro) {
      print(erro);
      Fluttertoast.showToast(
          msg: 'No internet', toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<bool?> _alert(context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you really want to exit app ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = json.decode(prefs.getString('user')!);
    var data = (userData['display_name']);
    return data;
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var versionName = packageInfo.version;
    return versionName;
  }

  @override
  void initState() {
    getPrinter();
    super.initState();
    checkDayOpen();
  }

  void checkDayOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var baseUrl = prefs.getString('baseUrl');
    var checkurl = Uri.parse('$baseUrl/api/daySettings/checkDayStatus');
    var res = await http.get(checkurl);
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data['status'] != 1) {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() => _alert(context).then((value) => value!)),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white10,
            elevation: 0.0,
          ),
          body:
              Consumer<UrlController>(builder: (context, urlController, child) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 30.0, bottom: 30.0, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 00.0, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: OutlinedButton.icon(
                              onPressed: () {
                                RestartWidget.restartApp(context);
                              },
                              icon: const Icon(Icons.restart_alt_sharp),
                              label: const Text('Restart')),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text(
                                'WelCome To RetroMS',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              FutureBuilder(
                                  future: getInfo(),
                                  builder: (context, snapShot) {
                                    if (snapShot.hasData) {
                                      return Text(snapShot.data.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold));
                                    } else {
                                      return const Text('');
                                    }
                                  })
                            ],
                          ),
                        )),
                        Flexible(
                          child: OutlinedButton.icon(
                              onPressed: () async {
                                final printerIpController =
                                    Provider.of<PrinterIpAddressController>(
                                        context,
                                        listen: false);
                                if (!printerIpController.isLoading) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  var userData =
                                      json.decode(prefs.getString('user')!);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ProfileScreen(data: userData);
                                  }));
                                } else {
                                  Fluttertoast.showToast(msg: 'isLoading');
                                }
                              },
                              icon: const Icon(Icons.person),
                              label: const Text('Profile')),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Consumer<PrinterIpAddressController>(
                        builder: (context, printerIpController, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (!printerIpController.isLoading) {
                                urlController.setUrlValue(0);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              } else {
                                Fluttertoast.showToast(msg: 'isLoading');
                              }
                            },
                            child: Material(
                              elevation: 10.0,
                              color: urlController.getUrlValue == 0
                                  ? const Color(0xffCC471B)
                                  : Colors.white,
                              child: const SizedBox(
                                height: 100,
                                width: 100,
                                child: Center(
                                    child: Text(
                                  'Table',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          InkWell(
                            onTap: () {
                              if (!printerIpController.isLoading) {
                                urlController.setUrlValue(1);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              } else {
                                Fluttertoast.showToast(msg: 'isLoading');
                              }
                            },
                            child: Material(
                              color: urlController.getUrlValue == 1
                                  ? const Color(0xffCC471B)
                                  : Colors.white,
                              elevation: 10.0,
                              child: const SizedBox(
                                height: 100,
                                width: 100,
                                child: Center(
                                  child: Text('TakeAways',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          InkWell(
                            onTap: () {
                              if (!printerIpController.isLoading) {
                                urlController.setUrlValue(2);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              } else {
                                Fluttertoast.showToast(msg: 'isLoading');
                              }
                            },
                            child: Material(
                              color: urlController.getUrlValue == 2
                                  ? const Color(0xffCC471B)
                                  : Colors.white,
                              elevation: 10.0,
                              child: const SizedBox(
                                height: 100,
                                width: 100,
                                child: Center(
                                    child: Text('Home\nDelivery',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.message_sharp),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text('Add Message')
                          ]),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xffCC471B),
                      ),
                      onPressed: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return const MessagePage();
                            });
                      },
                    ),
                  ),
                  FutureBuilder(
                      future: getVersion(),
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 25.0,
                                child: Text(
                                  "Powered By: NCT Pvt. Ltd",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFcc471b),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                child: Text(
                                  "नेपालमा बनेकाे",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFcc471b),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  "v${snapShot.data}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFcc471b),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Text('data');
                        }
                      }),
                ],
              ),
            );
          })),
    );
  }
}
