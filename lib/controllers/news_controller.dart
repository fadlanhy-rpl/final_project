import 'package:final_project/api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsController extends GetxController {
  // --- 1. State (Data) ---
  // .obs artinya "Observable" (Bisa dipantau perubahannya)
  var allNews = <Map<String, dynamic>>[].obs; 
  var isLoading = false.obs;
  var selectedCategory = ''.obs;

  // Ini fitur ganti tema yang lama, kita simpan aja di sini dulu
  final isChange = false.obs; 

  // --- 2. Computed Data (Data Olahan) ---
  // Otomatis terupdate kalau allNews berubah
  List<Map<String, dynamic>> get breakingNews => allNews.take(5).toList();
  List<Map<String, dynamic>> get recommendations => allNews.skip(5).toList();

  // --- 3. Lifecycle (Saat Controller Lahir) ---
  @override
  void onInit() {
    super.onInit();
    fetchNews(); // Langsung cari berita pas aplikasi jalan
  }

  // --- 4. Logic (Fungsi Kerja) ---
  void changeTheme() {
    isChange.value = !isChange.value;
    Get.changeTheme(isChange.value ? ThemeData.dark() : ThemeData.light());
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    fetchNews();
  }

  Future<void> fetchNews() async {
    isLoading.value = true; // Pasang status loading
    try {
      // Panggil "Koki" (API) buat masak
      final data = await Api().getApi(category: selectedCategory.value);
      
      // Hidangkan makanan (Update state)
      allNews.assignAll(data); 
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat berita: $e");
    } finally {
      isLoading.value = false; // Matikan status loading
    }
  }
}