import 'dart:async';
import 'package:final_project/controllers/news_controller.dart';
import 'package:flutter/material.dart';
import '../api/api.dart';
import 'detail.dart';
import 'package:get/get.dart';

class HomeInteractiveScreen extends StatefulWidget {
  const HomeInteractiveScreen({super.key});

  @override
  State<HomeInteractiveScreen> createState() => _HomeInteractiveScreenState();
}

class _HomeInteractiveScreenState extends State<HomeInteractiveScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoPageTimer;

  final _selectedCategory = ''.obs;
  final _isLoading = false.obs;

  List<Map<String, dynamic>> _allNews = [];

  List<Map<String, dynamic>> get _breakingNews => _allNews.take(5).toList();
  List<Map<String, dynamic>> get _recommendations => _allNews.skip(5).toList();

  @override
  void initState() {
    super.initState();
    _fetchNews(_selectedCategory.value);
    _startAutoPage();
  }

  @override
  void dispose() {
    _autoPageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPage() {
    _autoPageTimer?.cancel();
    _autoPageTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!_pageController.hasClients || _breakingNews.isEmpty) return;
      final next = (_pageController.page ?? 0).round() + 1;
      final target = next % _breakingNews.length;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _fetchNews(String category) async {
    setState(() => _isLoading.value = true);
    try {
      final data = await Api().getApi(category: category);
      _allNews = data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Gagal memuat berita: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading.value = false);
    }
  }

  String _relativeTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return '${diff.inDays} hari lalu';
      if (diff.inHours > 0) return '${diff.inHours} jam lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
      return 'Baru saja';
    } catch (_) {
      return '';
    }
  }

  String _categoryFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('olahraga') || t.contains('sepak') || t.contains('bola'))
      return 'Sports';
    if (t.contains('politik') || t.contains('pemerintah')) return 'Politics';
    if (t.contains('ekonomi') || t.contains('bisnis')) return 'Business';
    if (t.contains('teknologi') || t.contains('digital')) return 'Technology';
    return 'News';
  }

  Widget _categoryChip(String label, String category) {
    final isActive = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() => _selectedCategory.value = category);
          _fetchNews(category);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? Colors.blue 
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive 
                  ? Colors.white 
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakingCard(Map<String, dynamic> item, int index) {
    final imageUrl = item['image']?['small'] ?? '';
    final title = (item['title'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) =>
                DetailScreen(newsDetail: item, heroTag: 'hero-$index'),
          ),
        );
      },
      child: Hero(
        tag: 'hero-$index',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) {
                  if (p == null) return w;
                  return Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
              // Top-left category badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _categoryFromTitle(title),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Bottom content
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime((item['isoDate'] ?? '').toString()),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
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
  }

  Widget _buildRecommendationTile(Map<String, dynamic> item, int index) {
    final imageUrl = item['image']?['small'] ?? '';
    final title = (item['title'] ?? '').toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                DetailScreen(newsDetail: item, heroTag: 'rec-$index'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'rec-$index',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, w, p) => p == null
                      ? w
                      : Container(
                          width: 84,
                          height: 84,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    width: 84, 
                    height: 84, 
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _categoryFromTitle(title),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _relativeTime((item['isoDate'] ?? '').toString()),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500], 
                          fontSize: 12,
                        ),
                      ),
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
    final c = Get.put(NewsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.blue,
          onRefresh: () => _fetchNews(_selectedCategory.value),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                title: const Text(
                  'SkyNews',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent,
                  ),
                ),
                centerTitle: true,
                leading: Icon(
                  Icons.menu, 
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      c.changeTheme();
                    },
                    icon: Obx(
                      () => c.isChange.value 
                          ? Icon(
                              Icons.light_mode, 
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ) 
                          : Icon(
                              Icons.dark_mode, 
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(12),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              // Breaking News title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Breaking News',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Breaking News carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 210,
                  child: _isLoading.value
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, __) => Container(
                            width: MediaQuery.of(context).size.width * 0.76,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[850] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: 2,
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _breakingNews.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildBreakingCard(
                              _breakingNews[index],
                              index,
                            ),
                          ),
                        ),
                ),
              ),

              // Dots indicator
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (_, __) {
                    final count = _breakingNews.length;
                    if (count == 0) return const SizedBox(height: 12);
                    final current = (_pageController.hasClients
                        ? (_pageController.page ?? 0.0)
                        : 0.0);
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(count, (i) {
                          final selected = (current.round() == i);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: selected ? 18 : 6,
                            decoration: BoxDecoration(
                              color: selected 
                                  ? Colors.blue 
                                  : isDark ? Colors.grey[600] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),

              // Category chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryChip('semua', ''),
                      _categoryChip('nasional', 'nasional'),
                      _categoryChip('internasional', 'internasional'),
                      _categoryChip('ekonomi', 'ekonomi'),
                      _categoryChip('olahraga', 'olahraga'),
                      _categoryChip('teknologi', 'teknologi'),
                      _categoryChip('hiburan', 'hiburan'),
                      _categoryChip('gaya-hidup', 'gaya-hidup'),
                    ],
                  ),
                ),
              ),

              // Recommendation title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recommendations list
              if (_isLoading.value)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: List.generate(
                        5,
                        (i) => Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          height: 108,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildRecommendationTile(
                      _recommendations[index],
                      index,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemCount: 5,
                ),

              // bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}