import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/api/api.dart'; // Pastikan import ini benar
// Hapus import yang tidak berhubungan dengan data

class NewsController extends GetxController {
  // --- 1. STATE MANAGEMENT (Data Mentah) ---
  var allNews = <Map<String, dynamic>>[].obs; 
  var isLoading = false.obs;
  var selectedCategory = ''.obs;
  
  // State untuk Error Handling (Biar UI yang nentuin cara nampilinnya)
  var errorMessage = ''.obs;

  // State Tema (Masih oke disimpan di sini karena global, 
  // tapi idealnya dipisah ke ThemeController sendiri)
  final isChange = false.obs; 

  // --- 2. COMPUTED DATA (Data Olahan) ---
  // Getter ini ringan, karena cuma memotong list yang sudah ada di memori
  List<Map<String, dynamic>> get breakingNews => allNews.take(5).toList();
  List<Map<String, dynamic>> get recommendations => allNews.skip(5).toList();

  @override
  void onInit() {
    super.onInit();
    fetchNews(); 
  }

  // --- 3. ACTIONS (Fungsi Kerja) ---
  
  void changeTheme() {
    isChange.value = !isChange.value;
    Get.changeTheme(isChange.value ? ThemeData.dark() : ThemeData.light());
  }

  void updateCategory(String category) {
    // Optimasi: Kalau kategori sama, jangan reload data (Hemat Kuota & CPU)
    if (selectedCategory.value == category) return;
    
    selectedCategory.value = category;
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset error sebelum mulai
      
      // Simulasi delay biar loading kelihatan (Opsional, hapus di production)
      // await Future.delayed(Duration(seconds: 1));

      final data = await Api().getApi(category: selectedCategory.value);
      
      if (data.isNotEmpty) {
        allNews.assignAll(data);
      } else {
        errorMessage.value = "Tidak ada berita ditemukan.";
      }

    } catch (e) {
      errorMessage.value = "Gagal memuat berita. Periksa koneksi Anda.";
      print("Error Fetching News: $e");
      
      // Opsional: Tetap bisa panggil snackbar dari sini untuk kemudahan, 
      // tapi idealnya menggunakan 'ever()' di UI untuk mendengarkan perubahan errorMessage.
      Get.snackbar(
        "Terjadi Kesalahan", 
        errorMessage.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fungsi Refresh (untuk Pull-to-Refresh di UI)
  Future<void> refreshNews() async {
    // Paksa fetch ulang walaupun kategori sama
    await fetchNews();
  }
}