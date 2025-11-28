import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // PENTING: Biar kIsWeb dikenali
import 'package:get/get.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> firebaseUser = Rx<User?>(null);
  User? get user => firebaseUser.value;

  @override
  void onReady() {
    super.onReady();
    // Delay 3 detik buat Splash Screen sebelum cek status login
    Future.delayed(const Duration(seconds: 3), () {
      firebaseUser.bindStream(_auth.authStateChanges());
      ever(firebaseUser, _setInitialScreen);
    });
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  // --- Fungsi Register ---
  Future<void> register(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'username': username,
          'uid': uid,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      Get.snackbar("Berhasil", "Akun berhasil dibuat! Selamat datang $username", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal daftar: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // --- Fungsi Login Email ---
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Tambahan Notifikasi Sukses
      Get.snackbar("Berhasil", "Login berhasil! Selamat datang kembali.", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
       Get.snackbar("Error", "Login gagal: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // --- Fungsi Login Google ---
  Future<void> loginWithGoogle() async {
    try {
      // 1. Trigger flow Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User batal milih akun

      // 2. Ambil token autentikasi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 3. Buat kredensial Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Masuk ke Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 5. Simpan data user ke Firestore jika user baru
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        String uid = userCredential.user!.uid;
        await _firestore.collection('users').doc(uid).set({
          'email': googleUser.email,
          'username': googleUser.displayName ?? "User Google",
          'uid': uid,
          'createdAt': DateTime.now().toIso8601String(),
          'photoUrl': googleUser.photoUrl,
        });
      }
      // Update Notifikasi Sukses biar lebih cantik
      Get.snackbar("Berhasil", "Login Google sukses!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print("Error Google: $e");
      Get.snackbar("Gagal", "Gagal login Google: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // --- Fungsi Logout ---
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Pastikan logout dari Google juga
  }
}