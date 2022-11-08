import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../auth/auth_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Widget buildListTile({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      iconColor: Theme.of(context).colorScheme.onPrimary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      style: ListTileStyle.drawer,
      leading: Icon(
        icon,
      ),
      title: Text(
        text,
        textScaleFactor: 1,
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(
      color: Colors.white70,
      endIndent: 10,
      indent: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Hello",
              textScaleFactor: 1,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline3!.fontSize,
                color: Theme.of(context).colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            buildListTile(
              context: context,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(Home.routeName);
              },
              icon: Icons.check_box_rounded,
              text: "Mark Attendance",
            ),
            buildDivider(),
            buildListTile(
              context: context,
              onTap: () async {
                await FirebaseAuth.instance.signOut().then(
                      (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                          AuthScreen.routeName, (route) => false),
                    );
              },
              icon: Icons.logout,
              text: "Logout",
            ),
          ],
        ),
      ),
    );
  }
}
