import 'package:flutter/material.dart';
import 'package:mobile_version/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';

import '../screens/auth_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    final user = userProvider.user;

    void logout() async {
      /*
      Logout user and redirect him/her to auth screen
      */
      await userProvider.logout(user.localId);
      channelsProvider.emptyChannels();
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }

    void newChannel() {
      /*
      This method opens a dialog and gets a channel name and description,
      then craetes new channel for the user.
      */
      final _nameController = TextEditingController();
      final _descriptionController = TextEditingController();
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              content: SizedBox(
                height: isPortrait ? size.height * 0.23 : size.height * 0.35,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _nameController,
                          maxLength: 25,
                          validator: (value) {
                            if (value!.replaceAll(" ", "").isEmpty) {
                              return "Please add a name.";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text("Name"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLength: 75,
                          validator: (value) {
                            if (value!.replaceAll(" ", "").isEmpty) {
                              return "Please enter a description.";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text("Description"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                            onPressed: () async {
                              final form = _formKey.currentState;
                              if (form!.validate()) {
                                final name = _nameController.value.text;
                                final description =
                                    _descriptionController.value.text;
                                final bool result = await channelsProvider
                                    .addChannel(name, description, {
                                  "email": user.email,
                                  "password": user.password,
                                });
                                if (result == true) {
                                  await Navigator.of(context)
                                      .pushReplacementNamed(
                                          HomeScreen.routeName);
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Error",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                          content: const Text(
                                              "Something went wrong"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Ok"),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            child: const Text("Create",
                                style: TextStyle(fontWeight: FontWeight.bold)))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    }

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Text(user.name),
            ),
          ),
          DrawerItem(
            handler: newChannel,
            title: "Add New Channel",
            icon: Icons.newspaper,
          ),
          DrawerItem(
            handler: newChannel,
            title: "Add New Group",
            icon: Icons.group_add_rounded,
          ),
          DrawerItem(
            handler: logout,
            title: "Logout",
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    required this.handler,
    required this.title,
    required this.icon,
    Key? key,
  }) : super(key: key);

  final handler;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => handler(),
      leading: Icon(
        icon,
        color: Colors.red,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(
        Icons.arrow_right,
        color: Colors.red,
      ),
    );
  }
}
