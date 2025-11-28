import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/controllers/news_controller.dart';
import 'package:final_project/model/new_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> newsDetail;
  final String heroTag;

  const DetailScreen({
    super.key,
    required this.newsDetail,
    required this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  
  // --- 1. Controllers & Variables ---
  late final AnimationController _animController;
  late final Animation<double> _fadeTop;
  late final Animation<double> _fadeBottom;
  late final Animation<Offset> _slideBottom;

  final NewsController newsC = Get.find();
  // Kita inject BookmarkController di sini
  final BookmarkController bookmarkC = Get.put(BookmarkController());

  // Objek artikel yang sudah rapi
  late NewsArticle article;

  // --- 2. Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _parseDataToModel();
    
    // Cek status bookmark saat halaman dibuka
    bookmarkC.checkIfBookmarked(article.title);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- 3. Setup Helpers ---
  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeTop = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _fadeBottom = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    );

    _slideBottom = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    ));

    // Jalankan animasi setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) => _animController.forward());
  }

  // Mengubah Map mentah menjadi Object Model agar aman dikirim ke Firebase
  void _parseDataToModel() {
    article = NewsArticle(
      title: (widget.newsDetail['title'] ?? '').toString(),
      source: (widget.newsDetail['link'] ?? '').toString(), // Link as source ID
      timeAgo: (widget.newsDetail['isoDate'] ?? '').toString(),
      views: '0', // Dummy data kalau di API gak ada
      comments: '0',
      imageUrl: (widget.newsDetail['image']?['small'] ?? '').toString(),
    );
  }

  // --- 4. Main Build ---
  @override
  Widget build(BuildContext context) {
    // Scaffold mengikuti tema global
    return Scaffold(
      body: Column(
        children: [
          // Bagian Atas (Gambar & AppBar)
          Flexible(
            flex: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeroImage(),
                _buildGradientOverlay(),
                _buildSafeAreaAppBar(context),
              ],
            ),
          ),
          // Bagian Bawah (Konten Berita)
          Flexible(
            flex: 40,
            child: _buildContentBody(context),
          ),
        ],
      ),
    );
  }

  // --- 5. Widget Extracted (Clean Code) ---
  
  Widget _buildHeroImage() {
    return Hero(
      tag: widget.heroTag,
      child: article.imageUrl.isNotEmpty
          ? Image.network(
              article.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
            )
          : Container(color: Colors.grey[200]),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.25),
            Colors.black.withOpacity(0.65),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeAreaAppBar(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    // TOMBOL BOOKMARK (Logic sudah terhubung)
                    Obx(() {
                      final isActive = bookmarkC.isBookmarked.value;
                      return _buildCircleButton(
                        icon: isActive ? Icons.bookmark : Icons.bookmark_border,
                        isActive: isActive, // Untuk animasi scale
                        onTap: () {
                          if (isActive) {
                            bookmarkC.removeFromBookmark(article.title);
                          } else {
                            bookmarkC.addToBookmark(article);
                          }
                        },
                      );
                    }),
                    const SizedBox(width: 8),
                    // Tombol Tema
                    _buildCircleButton(
                      icon: newsC.isChange.value ? Icons.light_mode : Icons.dark_mode,
                      onTap: () => newsC.changeTheme(),
                      isObx: true, // Flag khusus
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Info Judul & Waktu (Fade In)
          FadeTransition(
            opacity: _fadeTop,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTag(),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• ${_relativeTime(article.timeAgo)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(BuildContext context) {
    final content = (widget.newsDetail['contentSnippet'] ?? '').toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeBottom,
      child: SlideTransition(
        position: _slideBottom,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.source.isNotEmpty)
                _buildDomainTag(article.source, isDark),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content.isNotEmpty ? content : 'Tidak ada ringkasan.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(icon: Icons.thumb_up_outlined, label: 'Suka'),
                  _ActionButton(icon: Icons.comment_outlined, label: 'Komentar'),
                  _ActionButton(icon: Icons.share_outlined, label: 'Bagikan'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. Smaller Helper Widgets ---

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    bool isObx = false,
  }) {
    // Helper untuk membuat tombol bulat transparan
    Widget iconWidget = Icon(icon, size: 20, color: Colors.white);
    
    // Jika perlu animasi scale (untuk bookmark)
    if (isActive) {
      iconWidget = AnimatedScale(
        scale: 1.15,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: iconWidget,
      );
    }

    // Jika butuh Obx (untuk tema)
    if (isObx) {
      iconWidget = Obx(() => Icon(
        newsC.isChange.value ? Icons.light_mode : Icons.dark_mode,
        size: 20, color: Colors.white
      ));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      ),
    );
  }

  Widget _buildCategoryTag() {
    if (article.source.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _categoryFromLink(article.source),
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildDomainTag(String link, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _domainFromLink(link),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.verified, size: 16, color: Colors.blue),
      ],
    );
  }

  // --- 7. Utility Functions (Logic) ---
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

  String _categoryFromLink(String link) {
    final l = link.toLowerCase();
    if (l.contains('olahraga') || l.contains('sport')) return 'Olahraga';
    if (l.contains('teknologi')) return 'Teknologi';
    if (l.contains('ekonomi') || l.contains('bisnis')) return 'Ekonomi';
    if (l.contains('internasional')) return 'Internasional';
    if (l.contains('nasional')) return 'Nasional';
    if (l.contains('hiburan')) return 'Hiburan';
    if (l.contains('gaya-hidup')) return 'Gaya Hidup';
    return 'Berita';
  }

  String _domainFromLink(String link) {
    try {
      return Uri.parse(link).host.replaceAll('www.', '');
    } catch (_) {
      return 'Sumber';
    }
  }
}

// Widget tombol aksi bawah tetap sama
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}