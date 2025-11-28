import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Firebase
import 'firebase_options.dart'; // 2. Import Config Firebase (hasil generate CLI)

// Import Screen & Controller
import 'package:final_project/screens/splash/splash_screen.dart';
import 'package:final_project/controllers/auth_controller.dart'; // Import Controller Satpam

void main() async {
  // 3. Pastikan binding Flutter siap sebelum menjalankan kode async (wajib untuk Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Nyalakan mesin Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. "Pekerjakan Satpam" (Inject AuthController)
    // Dengan baris ini, AuthController langsung aktif memantau status login user
    // sejak aplikasi pertama kali dibuka.
    Get.put(AuthController());

    return GetMaterialApp(
      title: 'SkyNews App',
      debugShowCheckedModeBanner: false,
      
      // Tema aplikasi (bisa dikembangkan nanti dengan ThemeController)
      theme: ThemeData.light(),      
      // darkTheme: ThemeData.dark(),

      // Halaman pertama yang muncul tetap Splash Screen
      // Nanti AuthController yang akan menentukan setelah Splash mau ke Home atau Login
      home: const SplashScreen(),
    );
  }
}