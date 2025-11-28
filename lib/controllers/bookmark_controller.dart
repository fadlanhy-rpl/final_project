import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:final_project/model/new_article.dart';

class BookmarkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. STATE MANAGEMENT
  // Variabel UI untuk satu artikel yang sedang dibuka
  var isBookmarked = false.obs;
  
  // 2. LOCAL CACHE (Daftar Belanja) 🛒
  // Menyimpan semua JUDUL berita yang dibookmark.
  // Pengecekan dilakukan ke list ini, bukan tembak ke server terus-menerus.
  var bookmarkedIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Saat Controller lahir, langsung ambil semua daftar belanjaan (1x Read)
    _loadAllBookmarks();
  }

  // --- Fungsi Internal: Ambil Semua Data (Initial Fetch) ---
  Future<void> _loadAllBookmarks() async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) return;

      // Ambil semua dokumen di koleksi bookmark (Cost: 1 Read per dokumen saat pertama kali)
      // Tapi karena kita pakai listener (snapshots), data akan selalu sinkron otomatis!
      _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .snapshots()
          .listen((snapshot) {
        
        // Update Local Cache kita dengan daftar ID terbaru
        bookmarkedIds.value = snapshot.docs.map((doc) => doc.id).toList();
        print("📦 Local Cache Updated: ${bookmarkedIds.length} items");
        
      });
    } catch (e) {
      print("Error loading bookmarks: $e");
    }
  }

  // --- Fungsi 1: Reset UI (Membersihkan Meja) ---
  // Dipanggil dari UI saat DetailScreen baru dibuka
  void resetState(String title) {
    // Cek instan dari Local Cache (GRATIS & CEPAT) ⚡
    isBookmarked.value = bookmarkedIds.contains(title);
  }

  // --- Fungsi 2: Tambah ke Laci (Save) ---
  Future<void> addToBookmark(NewsArticle article) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Optimistic Update: Ubah UI dulu biar terasa cepat
      isBookmarked.value = true; 

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(article.title)
          .set(article.toJson()); // Kita simpan FULL DATA (Aman jika API mati)

      Get.snackbar("Disimpan", "Berita masuk daftar bacaan", duration: const Duration(seconds: 1));
    } catch (e) {
      isBookmarked.value = false; // Revert jika gagal
      Get.snackbar("Gagal", "Gagal menyimpan: $e");
    }
  }

  // --- Fungsi 3: Hapus (Delete) ---
  Future<void> removeFromBookmark(String title) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Optimistic Update
      isBookmarked.value = false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(title)
          .delete();

      Get.snackbar("Dihapus", "Berita dihapus", duration: const Duration(seconds: 1));
    } catch (e) {
      isBookmarked.value = true; // Revert jika gagal
      Get.snackbar("Error", "Gagal menghapus: $e");
    }
  }
}