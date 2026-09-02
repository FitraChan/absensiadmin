import 'dart:io';

import 'package:absensiadmin/home.dart';
import 'package:absensiadmin/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ini dari flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Tambahkan ini!
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    ProviderScope(
      // <- WAJIB ADA INI!
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Test App',
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) => true;
  }
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        isAuth = true;
      });
    } else {
      // const Login();
      Navigator.push(
        context,
        // ignore: unnecessary_new
        new MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (isAuth) {
    //   //print("true");
    //   child = Menu(
    //     i: 0,
    //   );
    // } else {
    //   //print("false");
    //   child = Login();
    // }
    return Scaffold(body: Home());
  }
}
