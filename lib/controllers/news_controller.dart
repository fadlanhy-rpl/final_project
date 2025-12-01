import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project/api/api.dart'; 

class NewsController extends GetxController {
  // --- 1. STATE (Data) ---
  var allNews = <Map<String, dynamic>>[].obs; 
  var isLoading = false.obs;
  var selectedCategory = ''.obs;
  
  // Variabel Error (Koki berteriak di sini)
  var errorMessage = ''.obs;

  // Variabel Tema
  final isChange = false.obs; 

  // --- 2. COMPUTED DATA (Data Olahan) ---
  List<Map<String, dynamic>> get breakingNews => allNews.take(5).toList();
  List<Map<String, dynamic>> get recommendations => allNews.skip(5).toList();

  @override
  void onInit() {
    super.onInit();
    fetchNews(); 
  }

  // --- 3. ACTIONS (Logika) ---
  
  void changeTheme() {
    isChange.value = !isChange.value;
    Get.changeTheme(isChange.value ? ThemeData.dark() : ThemeData.light());
  }

  // Optimasi: Cek kategori sebelum fetch
  void updateCategory(String category) {
    if (selectedCategory.value == category) return;
    
    selectedCategory.value = category;
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset teriakan error
      
      final data = await Api().getApi(category: selectedCategory.value);
      
      if (data.isNotEmpty) {
        allNews.assignAll(data);
      } else {
        errorMessage.value = "Tidak ada berita ditemukan.";
      }

    } catch (e) {
      // Koki cuma lapor error, gak perlu urus Snackbar
      errorMessage.value = "Gagal memuat berita. Periksa koneksi internet.";
      print("Error Fetching News: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshNews() async {
    await fetchNews();
  }
}