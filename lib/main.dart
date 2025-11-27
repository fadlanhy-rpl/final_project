import 'package:final_project/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyNews App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light(),      
      // darkTheme: ThemeData.dark(),

      home: const SplashScreen(),
    );
  }
}