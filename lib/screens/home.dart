import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../auth/auth_screen.dart';
import '../widgets/heading_text.dart';
import '../utils/vertical_space_helper.dart';
import '../services/other_functions.dart';
import '../DbHelper/db_connection.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription subscription;
  bool isConnected = false;
  bool isAlertSet = false;
  final _codeContorller = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  void showDialogBox() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "No Connection",
            textScaleFactor: 1,
          ),
          content: Image.asset(
            "assets/images/noNet.gif",
            height: 100,
            width: 200,
            fit: BoxFit.contain,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isAlertSet = false;
                });
                isConnected = await InternetConnectionChecker().hasConnection;
                if (!isConnected) {
                  showDialogBox();
                  setState(() {
                    isAlertSet = true;
                  });
                }
              },
              child: const Text(
                "OK",
                textScaleFactor: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (result) async {
        isConnected = await InternetConnectionChecker().hasConnection;
        if (!isConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        }
        if (isConnected && isAlertSet == true) {
          await MongoDB.connect().then(
            (_) {
              Fluttertoast.showToast(
                msg: "Connected Again!",
                toastLength: Toast.LENGTH_SHORT,
              );
            },
          );
        }
      },
    );
  }

  void callFunction() async {
    setState(() {
      isLoading = true;
    });
    try {
      int res = await Functions().markAttendance(
        context,
        _formKey,
        _subjectController.text.trim().toUpperCase(),
        _codeContorller.text.trim(),
        _subjectController,
        _codeContorller,
      );
      if (res == -1) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  int? code;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Mark Attendance",
            textScaleFactor: 1,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then(
                  (_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AuthScreen.routeName,
                      (route) => false,
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const HeadingText(
                  text: "Subject",
                  textAlign: TextAlign.start,
                ),
                const VerticalSpaceHelper(height: 5),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  enableSuggestions: true,
                  autocorrect: true,
                  key: const ValueKey("subject"),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    hintText: "Eg: CST101, etc.",
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  controller: _subjectController,
                  validator: (value) {
                    RegExp subjectValid = RegExp(
                      r"^[A-Z]{3}[0-9]{3}$",
                      caseSensitive: true,
                    );
                    value = value!.trim().toUpperCase();
                    if (value.isEmpty) {
                      return "Please enter 6 digit subject code";
                    } else if (!subjectValid.hasMatch(value)) {
                      return "Subject Code must have exactly 3 letters and 3 numbers";
                    }
                    return null;
                  },
                ),
                const VerticalSpaceHelper(height: 20),
                const HeadingText(
                  text: "Attendance Code",
                  textAlign: TextAlign.start,
                ),
                const VerticalSpaceHelper(height: 5),
                TextFormField(
                  controller: _codeContorller,
                  enableSuggestions: false,
                  autocorrect: false,
                  key: const ValueKey("code"),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    hintText: "Eg: 123456, etc.",
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    value = value!.trim().toUpperCase();
                    if (value.isEmpty) {
                      return "Please enter attendance code";
                    }
                    return null;
                  },
                ),
                const VerticalSpaceHelper(height: 30),
                if (isLoading)
                  const Center(child: CircularProgressIndicator.adaptive()),
                if (!isLoading)
                  ElevatedButton(
                    onPressed: () {
                      callFunction();
                    },
                    child: const Text(
                      "Mark Attendance",
                      textScaleFactor: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
