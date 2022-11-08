import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/confirm_screen.dart';
import '../DbHelper/db_connection.dart';
import '../screens/absent_screen.dart';
import './auth_functions.dart';

class Functions {
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
    if (teacherData != null) {
      if ((date.hour == int.parse(teacherData["hour"]!) &&
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
                "Attendance not marked as it is either not started or is already completed.",
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
