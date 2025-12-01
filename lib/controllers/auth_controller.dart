import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

import 'package:final_project/screens/main_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> firebaseUser = Rx<User?>(null);
  var userData = <String, dynamic>{}.obs;
  
  // --- FLAG BARU: Tanda Sedang Sibuk ---
  // Gunanya biar Satpam (_setInitialScreen) gak panik duluan saat login Google
  bool isSigningInWithGoogle = false;

  User? get user => firebaseUser.value;

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      firebaseUser.bindStream(_auth.authStateChanges());
      ever(firebaseUser, _setInitialScreen);
    });
  }

  // --- LOGIKA SATPAM YANG LEBIH SABAR ---
  _setInitialScreen(User? user) async {
    // CEK FLAG: Kalau lagi proses login Google, Satpam diem dulu!
    if (isSigningInWithGoogle) {
      print("Satpam: Lagi login Google, saya tunggu...");
      return; 
    }

    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userData.value = userDoc.data() as Map<String, dynamic>;
          Get.offAll(() => const MainScreen()); 
        } else {
          // Hanya logout jika BENAR-BENAR tidak ditemukan dan BUKAN proses login baru
          Get.snackbar("Akses Ditolak", "Akun Anda tidak ditemukan di database.");
          await logout();
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal memverifikasi akun: $e");
        Get.offAll(() => const LoginScreen());
      }
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        Map<String, dynamic> newUser = {
          'email': email,
          'username': username,
          'uid': uid,
          'createdAt': DateTime.now().toIso8601String(),
          'photoUrl': '',
          'role': 'user',
        };
        await _firestore.collection('users').doc(uid).set(newUser);
        userData.value = newUser;
      }
      Get.snackbar("Berhasil", "Akun berhasil dibuat! Selamat datang $username", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal daftar: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Berhasil", "Login berhasil!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
       Get.snackbar("Error", "Login gagal: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // --- LOGIKA GOOGLE YANG DIPERBARUI ---
  Future<void> loginWithGoogle() async {
    // 1. Naikkan Bendera: "Satpam, jangan ganggu dulu!"
    isSigningInWithGoogle = true; 
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isSigningInWithGoogle = false; // Batal, turunkan bendera
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Ini akan memicu 'ever', TAPI Satpam akan diam karena flag isSigningInWithGoogle = true
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
         String uid = userCredential.user!.uid;
         DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

         if (!doc.exists) {
           // User Baru: Buat dokumen
           Map<String, dynamic> newUser = {
              'email': googleUser.email,
              'username': googleUser.displayName ?? "User Google",
              'uid': uid,
              'createdAt': DateTime.now().toIso8601String(),
              'photoUrl': googleUser.photoUrl,
              'role': 'user',
           };
           // PROSES PENTING: Tulis database
           await _firestore.collection('users').doc(uid).set(newUser);
           userData.value = newUser;
         } else {
           // User Lama
           userData.value = doc.data() as Map<String, dynamic>;
         }
         
         // 2. Navigasi Manual (Karena Satpam lagi cuti)
         Get.offAll(() => const MainScreen());
         
         Get.snackbar("Berhasil", "Login Google sukses!", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      print("Error Google: $e");
      Get.snackbar("Gagal", "Gagal login Google: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
      // Kalau gagal fatal, logout biar bersih
      await _auth.signOut();
      await _googleSignIn.signOut();
    } finally {
      // 3. Turunkan Bendera: Selesai, Satpam boleh kerja lagi kalau ada perubahan user nanti
      isSigningInWithGoogle = false; 
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    userData.value = {};
  }
}