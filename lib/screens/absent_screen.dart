import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/heading_text.dart';
import '../widgets/images.dart';
import '../utils/vertical_space_helper.dart';

class AbsentScreen extends StatefulWidget {
  static const routeName = "/absent";
  const AbsentScreen({Key? key}) : super(key: key);

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(
      const Duration(seconds: 3),
      () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              AbsentImage(),
              VerticalSpaceHelper(height: 10),
              HeadingText(
                textAlign: TextAlign.center,
                text: "Sorry! Attendance Already Closed",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
