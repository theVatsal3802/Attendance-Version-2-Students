import 'package:flutter/material.dart';

import '../widgets/heading_text.dart';
import '../widgets/images.dart';
import '../utils/vertical_space_helper.dart';

class AbsentScreen extends StatelessWidget {
  static const routeName = "/absent";
  const AbsentScreen({Key? key}) : super(key: key);

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
            children: [
              const AbsentImage(),
              const VerticalSpaceHelper(height: 10),
              const HeadingText(
                textAlign: TextAlign.center,
                text: "Sorry! Attendance Already Closed",
              ),
              const VerticalSpaceHelper(height: 30),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Back to Home",
                  textScaleFactor: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
