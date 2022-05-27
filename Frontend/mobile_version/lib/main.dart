import 'package:flutter/material.dart';
import 'package:mobile_version/providers/user_provider.dart';
import 'package:provider/provider.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: const Color.fromRGBO(44, 95, 45, 1),
            // secondary: const Color.fromRGBO(255, 180, 0, 1),
            secondary: Colors.deepOrange,
          ),
        ),
        home: const AuthScreen(),
        routes: {
          AuthScreen.routeName: ((context) => const AuthScreen()),
          HomeScreen.routeName: ((context) => const HomeScreen()),
        },
      ),
    );
  }
}
