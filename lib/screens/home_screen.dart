import 'dart:async';
import 'package:final_project/controllers/auth_controller.dart';
import 'package:final_project/controllers/news_controller.dart';
import 'package:final_project/screens/detail.dart'; // Pastikan import ini benar
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeInteractiveScreen extends StatefulWidget {
  const HomeInteractiveScreen({super.key});

  @override
  State<HomeInteractiveScreen> createState() => _HomeInteractiveScreenState();
}

class _HomeInteractiveScreenState extends State<HomeInteractiveScreen> {
  // PageController untuk carousel slider (UI Logic, tetap di sini oke)
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoPageTimer;

  // Panggil Controller kita (Si Otak)
  // Get.put membuat controller ini tersedia di memori
  final NewsController c = Get.put(NewsController());

  @override
  void initState() {
    super.initState();
    // KITA HAPUS fetchNews() DARI SINI.
    // Controller sudah otomatis fetch data saat dia dibuat (onInit).
    
    _startAutoPage(); // Timer animasi slider jalan terus
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
      // Kita cek c.breakingNews bukan _breakingNews lagi
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

  // Helper function UI (Bisa tetap di sini)
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
    if (t.contains('olahraga') || t.contains('sepak') || t.contains('bola')) return 'Sports';
    if (t.contains('politik') || t.contains('pemerintah')) return 'Politics';
    if (t.contains('ekonomi') || t.contains('bisnis')) return 'Business';
    if (t.contains('teknologi') || t.contains('digital')) return 'Technology';
    return 'News';
  }

  Widget _categoryChip(String label, String category) {
    // Bungkus dengan Obx karena kita memantau c.selectedCategory
    return Obx(() {
      final isActive = c.selectedCategory.value == category;
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Panggil fungsi di controller
            c.updateCategory(category);
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
    });
  }

  // ... (Fungsi _buildBreakingCard dan _buildRecommendationTile SAMA PERSIS, tidak perlu diubah) ...
  // Salin ulang _buildBreakingCard dan _buildRecommendationTile dari file lamamu ke sini
  // Pastikan paste di dalam class _HomeInteractiveScreenState

  // Biar kode di sini tidak kepanjangan, saya asumsikan kamu menyalin 2 widget helper itu di sini ya.
  // _buildBreakingCard(...) { ... }
  // _buildRecommendationTile(...) { ... }
  
  // --- COPY DARI FILE LAMA UNTUK _buildBreakingCard dan _buildRecommendationTile ---
  // (Saya bantu tampilkan _buildBreakingCard biar tidak bingung letaknya)
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
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) {
                  if (p == null) return w;
                  return Container(color: Colors.grey[300]);
                },
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  ),
                ),
              ),
              Positioned(
                left: 14, right: 14, bottom: 14,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(Map<String, dynamic> item, int index) {
     // Code tile sama persis seperti sebelumnya, hanya pastikan tidak ada error variabel
     // Kalau mau simple, copy paste method _buildRecommendationTile dari file lamamu
     final imageUrl = item['image']?['small'] ?? '';
     final title = (item['title'] ?? '').toString();
     return InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(newsDetail: item, heroTag: 'rec-$index'))),
        child: Container(
          margin: EdgeInsets.only(bottom: 14),
          height: 90, // Contoh tinggi
          child: Row(children: [
             ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: 90, height: 90, fit: BoxFit.cover)),
             SizedBox(width: 12),
             Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis))
          ]),
        )
     );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.blue,
          // Panggil ulang fetchNews di controller saat pull-to-refresh
          onRefresh: () => c.fetchNews(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                title: const Text('SkyNews', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blueAccent)),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () => c.changeTheme(), // Panggil controller
                    icon: Obx(() => Icon( // Obx memantau perubahan icon tema
                      c.isChange.value ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    )),
                  ),

                  IconButton(
                    icon: Icon(Icons.logout, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                    onPressed: () {
                      // Panggil fungsi logout dari AuthController
                      Get.find<AuthController>().logout();
                    },
                  ),
                ],
              ),

              // Bagian 1: Carousel (Breaking News)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 210,
                  // OBX DI SINI! Inilah kunci reaktifnya.
                  // Setiap kali c.isLoading atau c.breakingNews berubah, bagian ini digambar ulang.
                  child: Obx(() {
                    if (c.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (c.breakingNews.isEmpty) {
                      return const Center(child: Text("Tidak ada berita"));
                    }
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: c.breakingNews.length, // Ambil dari Controller
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildBreakingCard(c.breakingNews[index], index),
                      ),
                    );
                  }),
                ),
              ),

              // ... (Indikator Dots bisa kamu tambahkan lagi di sini kalau mau) ...

              // Bagian 2: Category Chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryChip('Semua', ''),
                      _categoryChip('Nasional', 'nasional'),
                      _categoryChip('Teknologi', 'teknologi'),
                      _categoryChip('Ekonomi', 'ekonomi'),
                      _categoryChip('Olahraga', 'olahraga'),
                    ],
                  ),
                ),
              ),

              // Bagian 3: Recommendation List
              // Gunakan Obx lagi untuk list di bawah
              Obx(() {
                if (c.isLoading.value) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())));
                }
                return SliverList.separated(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildRecommendationTile(c.recommendations[index], index), // Ambil dari Controller
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
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
}