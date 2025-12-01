import 'dart:async';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/news_controller.dart';
import 'package:final_project/screens/bookmark_screen.dart';
import 'package:final_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoPageTimer;
  int _currentPage = 0;

  final NewsController c = Get.put(NewsController());

  @override
  void initState() {
    super.initState();
    _startAutoPage();
    _pageController.addListener(_onPageChanged);

    ever(c.errorMessage, (msg) {
      if (msg.isNotEmpty) {
        Get.snackbar(
          "Pemberitahuan",
          msg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPageTimer?.cancel();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPage() {
    _autoPageTimer?.cancel();
    _autoPageTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!_pageController.hasClients || c.breakingNews.isEmpty) return;
      final next = (_pageController.page ?? 0).round() + 1;
      final target = next % c.breakingNews.length;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onPageChanged() {
    if (_pageController.hasClients && _pageController.page != null) {
      final newPage = _pageController.page!.round();
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A2B47);
    final textSecondary = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF3B82F6),
          onRefresh: () => c.fetchNews(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(DateTime.now()),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Selamat Datang!',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 8),
                      Obx(() => _buildIconButton(
                        c.isChange.value ? Icons.light_mode : Icons.dark_mode,
                        isDark,
                        () => c.changeTheme(),
                      )),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.logout_rounded, isDark, () {
                        Get.find<AuthController>().logout();
                      }),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    'Breaking News',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: Obx(() {
                    if (c.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF3B82F6),
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (c.breakingNews.isEmpty) {
                      return Center(
                        child: Text(
                          "Tidak ada berita",
                          style: GoogleFonts.poppins(color: textSecondary),
                        ),
                      );
                    }
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: c.breakingNews.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildBreakingCard(c.breakingNews[index], index, cardColor, textPrimary, textSecondary),
                      ),
                    );
                  }),
                ),
              ),

              SliverToBoxAdapter(
                child: Obx(() {
                  if (c.breakingNews.isEmpty) return const SizedBox();
                  final itemCount = c.breakingNews.length > 5 ? 5 : c.breakingNews.length;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        itemCount,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == (_currentPage % itemCount) ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == (_currentPage % itemCount)
                                ? const Color(0xFF3B82F6) 
                                : textSecondary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryChip('All', '', isDark, textPrimary),
                      _categoryChip('Nasional', 'nasional', isDark, textPrimary),
                      _categoryChip('Teknologi', 'teknologi', isDark, textPrimary),
                      _categoryChip('Ekonomi', 'ekonomi', isDark, textPrimary),
                      _categoryChip('Olahraga', 'olahraga', isDark, textPrimary),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommendation',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'See all',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Obx(() {
                if (c.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }
                return SliverList.separated(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildRecommendationTile(
                      c.recommendations[index],
                      index,
                      cardColor,
                      textPrimary,
                      textSecondary,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: c.recommendations.length,
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Widget _buildIconButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[300] : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, String category, bool isDark, Color textPrimary) {
    return Obx(() {
      final isActive = c.selectedCategory.value == category;
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => c.updateCategory(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF3B82F6)
                  : isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : textPrimary.withOpacity(0.7),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBreakingCard(
    Map<String, dynamic> item,
    int index,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final imageUrl = item['image']?['small'] ?? '';
    final title = (item['title'] ?? '').toString();
    final isoDate = item['isoDate'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => DetailScreen(newsDetail: item, heroTag: 'hero-$index'),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'hero-$index',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, w, p) {
                          if (p == null) return w;
                          return Container(color: Colors.grey[200]);
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400], size: 40),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Breaking',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                          child: const Icon(Icons.person, size: 14, color: Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'News Editor',
                          style: GoogleFonts.poppins(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time, size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(isoDate),
                          style: GoogleFonts.poppins(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(
    Map<String, dynamic> item,
    int index,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final imageUrl = item['image']?['small'] ?? '';
    final title = (item['title'] ?? '').toString();
    final isoDate = item['isoDate'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailScreen(newsDetail: item, heroTag: 'rec-$index'),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) {
                  if (p == null) return w;
                  return Container(width: 88, height: 88, color: Colors.grey[200]);
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _relativeTime(isoDate),
                        style: GoogleFonts.poppins(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 13, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '10 min read',
                        style: GoogleFonts.poppins(
                          color: textSecondary,
                          fontSize: 11,
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
}
