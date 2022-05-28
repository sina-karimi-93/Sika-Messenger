import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './database/db_handler.dart';
import './providers/chats_provider.dart';
import './providers/user_provider.dart';
import './providers/channels_provider.dart';
// Screens
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((_) => UserProvider())),
        ChangeNotifierProvider(create: ((_) => ChatsProvider())),
        ChangeNotifierProvider(create: ((_) => ChannelsProvider())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            // primary: const Color.fromRGBO(44, 95, 45, 1),
            // secondary: const Color.fromRGBO(255, 180, 0, 1),
            primary: Colors.teal,
            secondary: Colors.green,
          ),
        ),
        home: FutureBuilder<List>(
          future: DbHandler.getRecord(table: "users"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isNotEmpty) {
                Provider.of<UserProvider>(context, listen: false)
                    .setUser(snapshot.data!.first);
                return const HomeScreen();
              } else {
                return const AuthScreen();
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primary,
                body: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                ),
              );
            } else {
              return const Scaffold(
                backgroundColor: Colors.red,
                body: Center(
                    child: Text(
                  "Something went wrong, please reinstall your app.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              );
            }
          },
        ),
        routes: {
          AuthScreen.routeName: ((context) => const AuthScreen()),
          HomeScreen.routeName: ((context) => const HomeScreen()),
        },
      ),
    );
  }
}
