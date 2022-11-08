import 'package:flutter/material.dart';

import '../utils/vertical_space_helper.dart';
import '../widgets/images.dart';
import '../widgets/heading_text.dart';

class ConfirmScreen extends StatelessWidget {
  static const routeName = "/confirm";
  const ConfirmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subject = ModalRoute.of(context)!.settings.arguments as String;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ConfirmScreenWidget(),
                HeadingText(
                  text: "Attendance marked for $subject",
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
