import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/model/new_article.dart';
import 'package:final_project/screens/detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Controller
    final authC = Get.find<AuthController>();
    // Kita put BookmarkController biar siap dipakai buat hapus data
    final bookmarkC = Get.put(BookmarkController()); 

    final String uid = authC.user?.uid ?? '';

    // Jaga-jaga kalau user belum login (walau harusnya gak bisa masuk sini)
    if (uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Silakan login dulu")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmark Saya 🔖", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Pastikan warna icon (misal tombol back) jadi hitam
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // 2. StreamBuilder: CCTV-nya Firestore
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('bookmarks')
            .snapshots(), // <--- Ini kuncinya! Ambil data secara LIVE
        builder: (context, snapshot) {
          // A. Sedang Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Ada Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // C. Data Kosong
          var data = snapshot.data?.docs ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada berita disimpan", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // D. Tampilkan Data
          return ListView.separated(
            itemCount: data.length,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Ubah data JSON dari Firestore ke Object NewsArticle
              // Ingat fungsi .fromJson yang kita buat di Model? Ini gunanya!
              NewsArticle article = NewsArticle.fromJson(data[index].data());

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    // Pindah ke DetailScreen
                    // Kita kirim balik data object jadi JSON (Map) karena DetailScreen mintanya Map
                    Get.to(() => DetailScreen(
                          newsDetail: article.toJson(),
                          heroTag: 'bookmark-${article.title}',
                        ));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      // Gambar
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: article.imageUrl.isNotEmpty
                            ? Image.network(
                                article.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Container(width:100, height:100, color:Colors.grey[200]),
                              )
                            : Container(width:100, height:100, color:Colors.grey[200]),
                      ),
                      
                      // Teks Judul
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(article.source, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // Panggil Controller buat hapus
                          bookmarkC.removeFromBookmark(article.title);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}