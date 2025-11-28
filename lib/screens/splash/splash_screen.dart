import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Kalau pakai lottie
// import 'package:get/get.dart'; // Gak perlu Get di sini lagi buat navigasi

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita hapus initState dan Timer.
    // Splash Screen sekarang cuma widget statis (tampilan doang).
    // Navigasi sudah diurus sama AuthController di background.

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti ini sesuai aset kamu (Lottie atau Image biasa)
            Lottie.asset(
              'assets/lotties/splash_animation.json', 
              width: 250,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            const Text(
              "SkyNews",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
             const SizedBox(height: 20),
             // Loading indicator kecil biar user tau aplikasi lagi mikir
             const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}