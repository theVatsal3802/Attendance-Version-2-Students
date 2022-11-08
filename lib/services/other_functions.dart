import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/confirm_screen.dart';
import '../DbHelper/db_connection.dart';
import '../screens/absent_screen.dart';
import './auth_functions.dart';

class Functions {
  Future<String> _determinePosition() async {
    String currentAddress = "";
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please Enable your device location service");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location Permission is denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location Permission is denied forever");
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    try {
      currentAddress =
          "${(position.latitude * 1000).ceil()}, ${(position.longitude * 1000).ceil()}";
      return currentAddress;
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to get current location");
      return "No Location Available";
    }
  }

  void clearFields(TextEditingController subject, TextEditingController code) {
    subject.text = "";
    code.text = "";
  }

  Future<int> markAttendance(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String subject,
    String code,
    TextEditingController subjectController,
    TextEditingController codeContorller,
  ) async {
    FocusScope.of(context).unfocus();
    DateTime date = DateTime.now();
    bool valid = formKey.currentState!.validate();
    if (!valid) {
      return -1;
    }
    formKey.currentState!.save();
    User? user = FirebaseAuth.instance.currentUser;
    int codeInt = int.parse(code);
    final Map<String, dynamic>? teacherData =
        await MongoDB.teacherData(codeInt);
    String batch = await AuthFunctions().extractBatch(user!.email!);
    String rollno = user.email!.substring(0, 12);
    String location = await _determinePosition();
    if (teacherData != null) {
      if (location == teacherData["location"] &&
              (date.hour.toString() == teacherData["hour"] &&
                  date.minute >= int.parse(teacherData["minute"]!)) ||
          (date.hour > int.parse(teacherData["hour"]!) &&
              date.minute < int.parse(teacherData["minute"]!))) {
        try {
          await MongoDB.markAttendance(batch, subject, rollno).then(
            (_) {
              Navigator.of(context)
                  .pushNamed(ConfirmScreen.routeName, arguments: subject)
                  .then(
                (_) {
                  clearFields(subjectController, codeContorller);
                },
              );
            },
          );
        } catch (e) {
          rethrow;
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Attendance Not marked",
                textScaleFactor: 1,
              ),
              content: const Text(
                "Attendance not marked due to wrong location",
                textScaleFactor: 1,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Attendance Not marked",
              textScaleFactor: 1,
            ),
            content: const Text(
              "Please re-check the attendance code or the subject as we could not find the code in the database.",
              textScaleFactor: 1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  textScaleFactor: 1,
                ),
              ),
            ],
          );
        },
      ).then(
        (_) {
          Navigator.of(context).pushNamed(AbsentScreen.routeName).then((_) {
            clearFields(subjectController, codeContorller);
          });
        },
      );
      return 1;
    }
    return 0;
  }
}
