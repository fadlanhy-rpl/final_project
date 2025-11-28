import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controller didefinisikan di sini agar tidak reset saat rebuild
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  
  // 2. Variabel untuk status mata (Terlihat/Tidak)
  bool _isObscure = true; 

  @override
  void dispose() {
    // Bersihkan memori saat layar ditutup
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                TextField(
                  controller: emailC,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // --- KOLOM PASSWORD DENGAN FITUR MATA ---
                TextField(
                  controller: passC,
                  obscureText: _isObscure, // Status dari variabel
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                    // Tombol Mata di ujung kanan
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Ubah status saat ditekan
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                ),
                // ----------------------------------------
                
                const SizedBox(height: 24),

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

                const SizedBox(height: 24),

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