import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restro_ms_online/models/Category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _formKey = GlobalKey<FormState>();
  final message = TextEditingController();

  bool isLoading = false;

  void messageCreate() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var baseUrl = preferences.getString('baseUrl');
    var userid = preferences.get('userid');

    var tableSwipeUrl = Uri.parse('$baseUrl/api/company/changeMessage');
    Map<String, String> header = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var body = {"message": message.text};

    var response =
        await http.post(tableSwipeUrl, headers: header, body: jsonEncode(body));
    if (response.statusCode == 200) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully Created message!');
    } else {
      throw response.body;
    }
    setState(() {
      isLoading = false;
    });
  }

  void clearAll() {
    message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: Dialog(
        child: SizedBox(
          height: 300,
          width: 500,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(''),
                        const Text(
                          'Message',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xfffcc471b),
                              fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                            onPressed: () {
                              if (!isLoading) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                    const Divider(
                      thickness: 1.5,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        controller: message,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter title';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Title',
                          contentPadding: const EdgeInsets.only(
                            bottom: 10.0,
                            left: 8,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(
                      thickness: 1.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.restart_alt),
                                      Text('Reset')
                                    ]),
                                style: ElevatedButton.styleFrom(
                                  primary: const Color(0xffCC471B),
                                ),
                                onPressed: () {
                                  if (!isLoading) {
                                    clearAll();
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                child: !isLoading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                            Icon(Icons.confirmation_num_sharp),
                                            Text('Confirm')
                                          ])
                                    : const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                ),
                                onPressed: !isLoading
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          FocusScope.of(context);
                                          messageCreate();
                                        }
                                      }
                                    : () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
