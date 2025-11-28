import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil Satpam (Controller)
    final AuthController authC = Get.find();

    final TextEditingController emailC = TextEditingController();
    final TextEditingController passC = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center( // Center biar konten ada di tengah vertikal
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Judul
                const Text(
                  "SkyNews ☁️",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Masuk untuk membaca berita terkini",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Input Email
                TextField(
                  controller: emailC,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Password
                TextField(
                  controller: passC,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Login Biasa
                ElevatedButton(
                  onPressed: () => authC.login(emailC.text, passC.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("LOGIN", style: TextStyle(fontSize: 16)),
                ),
                
                const SizedBox(height: 16),
                const Text("Atau", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),

                // --- TOMBOL GOOGLE (BARU) ---
                OutlinedButton.icon(
                  onPressed: () => authC.loginWithGoogle(),
                  icon: Image.network(
                    'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                    height: 24,
                  ),
                  label: const Text("Masuk dengan Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                // ---------------------------

                const SizedBox(height: 24),

                // Tombol Daftar
                TextButton(
                  onPressed: () => Get.to(() => const RegisterScreen()),
                  child: const Text("Belum punya akun? Daftar di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}