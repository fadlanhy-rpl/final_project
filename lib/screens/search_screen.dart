import 'package:final_project/api/api.dart';
import 'package:final_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Controller & Model untuk Bookmark
import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/model/new_article.dart';
import 'package:final_project/controllers/news_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // --- PRESERVED CONTROLLERS & STATE ---
  final BookmarkController bookmarkC = Get.put(BookmarkController());
  final NewsController newsC = Get.find();
  
  final _selectedCategory = ''.obs;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filterNews = [];
  final isLoading = false.obs;

  // --- PRESERVED LOGIC (UNCHANGED) ---
  Future<void> fetchNews(String type) async {
    isLoading.value = true;
    try {
      final data = await Api().getApi(category: type);
      if (mounted) {
        setState(() {
          _allNews = data;
          _filterNews = data;
        });
      }
    } catch (e) {
      print("Error fetching: $e");
    } finally {
      isLoading.value = false;
    }
  }

  _applySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filterNews = _allNews;
      });
    } else {
      setState(() {
        _filterNews = _allNews.where((item) {
          final title = item['title'].toString().toLowerCase();
          final snippet = (item['contentSnippet'] ?? '').toString().toLowerCase();
          final search = query.toLowerCase();
          return title.contains(search) || snippet.contains(search);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews(_selectedCategory.value);
    _searchController.addListener(() {
      _applySearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  NewsArticle _mapToArticle(Map<String, dynamic> item) {
    return NewsArticle(
      title: (item['title'] ?? '').toString(),
      source: (item['link'] ?? '').toString(),
      timeAgo: (item['isoDate'] ?? '').toString(),
      views: '0',
      comments: '0',
      imageUrl: (item['image']?['small'] ?? '').toString(),
      content: (item['contentSnippet'] ?? '').toString(),
    );
  }

  // --- REDESIGNED UI ---
  
  Widget _buildCategoryPill(String label, String category) {
    return Obx(() {
      final isSelected = _selectedCategory.value == category;
      return GestureDetector(
        onTap: () {
          _selectedCategory.value = category;
          fetchNews(category);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNewsListItem(Map<String, dynamic> item, int index) {
    final articleObject = _mapToArticle(item);
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(newsDetail: item, heroTag: 'list-$index'),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image']?['small'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['contentSnippet'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12, color: const Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(item['isoDate'] ?? ''),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      // Bookmark Button
                      Obx(() {
                        bool isSaved = bookmarkC.bookmarkedIds.contains(articleObject.title);
                        return GestureDetector(
                          onTap: () {
                            if (isSaved) {
                              bookmarkC.removeFromBookmark(articleObject.title);
                            } else {
                              bookmarkC.addToBookmark(articleObject);
                            }
                          },
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: isSaved ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(Icons.menu, color: const Color(0xFF1E293B)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(Icons.notifications_outlined, color: const Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: const Color(0xFF94A3B8)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: const Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              _applySearch('');
                            },
                          )
                        : Icon(Icons.mic_none_outlined, color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryPill('All', ''),
                  _buildCategoryPill('Nasional', 'nasional'),
                  _buildCategoryPill('Internasional', 'internasional'),
                  _buildCategoryPill('Ekonomi', 'ekonomi'),
                  _buildCategoryPill('Olahraga', 'olahraga'),
                  _buildCategoryPill('Teknologi', 'teknologi'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            
            // News List
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
                }
                if (_filterNews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: const Color(0xFFCBD5E1)),
                        const SizedBox(height: 16),
                        Text(
                          'No news found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filterNews.length,
                  itemBuilder: (context, index) {
                    return _buildNewsListItem(_filterNews[index], index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
