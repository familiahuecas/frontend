import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  runApp(MyApp(initialRoute: token == null ? '/login' : '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Familia Huecas',
      initialRoute: initialRoute,
      routes: {
        '/': (context) => HomeScreen(token: ''), // Ajusta el token según sea necesario
        '/login': (context) => LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

