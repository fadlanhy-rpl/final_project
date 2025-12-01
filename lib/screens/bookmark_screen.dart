import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/controllers/news_controller.dart';
import 'package:final_project/model/new_article.dart';
import 'package:final_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final bookmarkC = Get.put(BookmarkController());
    final NewsController newsC = Get.find();

    final String uid = authC.user?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A2B47);
    final textSecondary = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "Silakan login dulu",
            style: GoogleFonts.poppins(color: textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: true,
        
        title: Text(
          "Saved Articles",
          style: GoogleFonts.playfairDisplay(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => newsC.changeTheme(),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() => Icon(
                newsC.isChange.value ? Icons.light_mode : Icons.dark_mode,
                color: textSecondary,
                size: 20,
              )),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('bookmarks')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(color: textSecondary),
              ),
            );
          }

          var data = snapshot.data?.docs ?? [];
          
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark_outline_rounded,
                      size: 60,
                      color: const Color(0xFF3B82F6).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No Saved Articles",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Articles you save will appear here",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        "Explore News",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: data.length,
            padding: const EdgeInsets.all(20),
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              NewsArticle article = NewsArticle.fromJson(data[index].data());

              return Dismissible(
                key: Key(article.title),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (_) => bookmarkC.removeFromBookmark(article.title),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => DetailScreen(
                      newsDetail: article.toJson(),
                      heroTag: 'bookmark-${article.title}',
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: article.imageUrl.isNotEmpty
                              ? Image.network(
                                  article.imageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image, color: Colors.grey[400]),
                                  ),
                                )
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image, color: Colors.grey[400]),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: textPrimary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: 14,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _domainFromLink(article.source),
                                      style: GoogleFonts.poppins(
                                        color: textSecondary,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Saved',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.chevron_right, size: 20, color: textSecondary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _domainFromLink(String link) {
    try {
      return Uri.parse(link).host.replaceAll('www.', '');
    } catch (_) {
      return 'Sumber';
    }
  }
}
