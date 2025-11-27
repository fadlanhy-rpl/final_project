import 'package:final_project/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
    void initState() {
      Future.delayed(const Duration(seconds: 3), () {
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeInteractiveScreen()), (route) => false);
        Get.to(MainScreen());
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Lottie.asset('assets/lotties/splash_animation.json', width: 400, height: 300),
            SizedBox(height: 12,),
            Text('Welcome to', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.grey),),
            SizedBox(height: 2,),
            Text('SkyNews App', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),)
          ],
        ),
      ),
    );
  }
}

