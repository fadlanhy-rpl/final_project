import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:final_project/model/new_article.dart'; // Pastikan path import ini benar

class BookmarkController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabel .obs (Reaktif) untuk memantau status bookmark
  // Kalau true = ikon nyala (disimpan), false = ikon mati
  var isBookmarked = false.obs;

  // --- Fungsi 1: Tambah ke Laci (Save) ---
  Future<void> addToBookmark(NewsArticle article) async {
    try {
      String uid = _auth.currentUser!.uid; // Ambil ID user yang login
      
      // Kita simpan di: users -> [UID] -> bookmarks -> [Judul Berita]
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(article.title) // Gunakan Judul sebagai ID Dokumen
          .set(article.toJson()); // Ubah objek jadi JSON

      isBookmarked.value = true; // Ubah status jadi tersimpan
      Get.snackbar("Disimpan", "Berita berhasil masuk daftar bacaan!");
      
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menyimpan bookmark: $e");
    }
  }

  // --- Fungsi 2: Buang dari Laci (Delete) ---
  Future<void> removeFromBookmark(String title) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(title) // Hapus berdasarkan judul
          .delete();
          
      isBookmarked.value = false; // Ubah status jadi tidak tersimpan
      Get.snackbar("Dihapus", "Berita dihapus dari bookmark.");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus: $e");
    }
  }

  // --- Fungsi 3: Cek Laci (Check Status) ---
  // Dipanggil setiap kali kita buka halaman detail berita
  Future<void> checkIfBookmarked(String title) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Coba ambil dokumen dengan judul tersebut
      var doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(title)
          .get();
          
      // doc.exists akan bernilai true jika dokumennya ada
      isBookmarked.value = doc.exists; 
    } catch (e) {
      // Kalau error (misal koneksi putus), anggap saja belum di-bookmark
      isBookmarked.value = false;
    }
  }
}