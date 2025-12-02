import 'package:final_project/api/api.dart';
import 'package:final_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

// Import Controller
import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/controllers/news_controller.dart'; // Perlu ini untuk ganti tema
import 'package:final_project/model/new_article.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controller
  final BookmarkController bookmarkC = Get.put(BookmarkController());
  final NewsController newsC = Get.find(); // Ambil NewsController yang sudah ada

  // UI State
  PageController _pageController = PageController();
  final _selectedCategory = ''.obs;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filterNews = [];
  final isLoading = false.obs;

  // --- Logic Fetch & Search (SAMA SEPERTI SEBELUMNYA) ---
  Future<void> fetchNews(String type) async {
    isLoading.value = true;
    try {
      final result = await Api().getApi(category: type);
      // Casting data agar aman
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(result);
      
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
      setState(() => _filterNews = _allNews);
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
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Helper Widgets ---

  Widget buttonCategory(String label, String category, bool isDark) {
    return Obx(() => GestureDetector(
      onTap: () {
        _selectedCategory.value = category;
        fetchNews(category);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Logic Warna Button: Kalau aktif Biru, kalau tidak aktif sesuaikan tema
          color: _selectedCategory.value == category
              ? Colors.blue
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _selectedCategory.value == category
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]), // Teks Button Dinamis
              fontWeight: _selectedCategory.value == category
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    ));
  }

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return DateFormat('dd MM yyyy, HH:mm').format(dateTime);
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

  @override
  Widget build(BuildContext context) {
    // 1. CEK TEMA SAAT INI
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Background Scaffold mengikuti tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu, size: 28, color: isDark ? Colors.white : Colors.grey[800]),
                  Row(
                    children: [
                      // TOMBOL GANTI TEMA (BARU)
                      IconButton(
                        onPressed: () => newsC.changeTheme(),
                        icon: Obx(() => Icon(
                          newsC.isChange.value ? Icons.light_mode : Icons.dark_mode,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        )),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.notifications_outlined,
                        size: 24,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                // Background Search Bar Dinamis
                color: isDark ? Colors.grey[900] : Colors.white, 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                // Warna Teks Input Dinamis
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                  ),
                  hintText: 'Search news...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: IconButton(
                    onPressed: () => _applySearch(_searchController.text),
                    icon: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch('');
                        },
                      )
                    : Icon(Icons.mic_none_outlined, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Pass isDark ke helper widget
                buttonCategory('semua', '', isDark),
                buttonCategory('nasional', 'nasional', isDark),
                buttonCategory('internasional', 'internasional', isDark),
                buttonCategory('ekonomi', 'ekonomi', isDark),
                buttonCategory('olahraga', 'olahraga', isDark),
                buttonCategory('teknologi', 'teknologi', isDark),
                buttonCategory('hiburan', 'hiburan', isDark),
                buttonCategory('gaya-hidup', 'gaya-hidup', isDark),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_filterNews.isEmpty) {
                return Center(child: Text('No news Found', 
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black)));
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _filterNews.length,
                  itemBuilder: (context, index) {
                    final item = _filterNews[index];
                    final articleObject = _mapToArticle(item);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(newsDetail: item, heroTag: 'hero-$index'),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2.0,
                        // Background Card Dinamis
                        color: isDark ? Colors.grey[900] : Colors.white,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  item['image']?['small'] ?? '',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => Container(height: 180, color: Colors.grey[200]),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['link'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        // Subtitle color dinamis
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Obx(() {
                                    bool isSaved = bookmarkC.bookmarkedIds.contains(articleObject.title);
                                    return IconButton(
                                      onPressed: () {
                                        if (isSaved) {
                                          bookmarkC.removeFromBookmark(articleObject.title);
                                        } else {
                                          bookmarkC.addToBookmark(articleObject);
                                        }
                                      },
                                      icon: Icon(
                                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                                        color: isSaved ? Colors.blue : (isDark ? Colors.grey[400] : Colors.grey),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Text(
                                item['title'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  // Judul Berita Dinamis
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),

                              Text(
                                item['contentSnippet'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  // Snippet Dinamis
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              Text(
                                formatDate(item['isoDate'] ?? ''),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}