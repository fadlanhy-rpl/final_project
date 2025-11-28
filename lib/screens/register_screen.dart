import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find();

    // 1. Tambah Controller buat Username
    final TextEditingController emailC = TextEditingController();
    final TextEditingController passC = TextEditingController();
    final TextEditingController userC = TextEditingController(); // <-- BARU

    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Bungkus pakai Scroll biar gak mentok keyboard
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Buat Akun Baru 📝",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 30),

              // --- FIELD USERNAME BARU ---
              TextField(
                controller: userC,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              // ---------------------------

              TextField(
                controller: emailC,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // Validasi input kosong dikit
                  if (userC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
                    Get.snackbar("Error", "Semua data harus diisi ya!", backgroundColor: Colors.red, colorText: Colors.white);
                  } else {
                    // Panggil fungsi register yang baru (ada usernamenya)
                    authC.register(emailC.text, passC.text, userC.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}