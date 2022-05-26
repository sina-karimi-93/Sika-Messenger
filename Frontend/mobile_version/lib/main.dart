import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color.fromRGBO(44, 95, 45, 1),
          // secondary: const Color.fromRGBO(255, 180, 0, 1),
          secondary: Colors.deepOrange,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
