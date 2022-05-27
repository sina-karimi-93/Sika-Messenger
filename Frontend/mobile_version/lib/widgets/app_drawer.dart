import 'package:flutter/material.dart';
import 'package:mobile_version/providers/user_provider.dart';
import 'package:mobile_version/screens/auth_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Text("${user.name}"),
            ),
          ),
          ListTile(
            onTap: () {
              userProvider.logout(user.localId);
              Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
            },
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logut",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(
              Icons.arrow_right,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
