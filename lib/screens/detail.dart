import 'package:final_project/controllers/news_controller.dart';
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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _fadeTop = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _fadeBottom = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _slideBottom =
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    ),
  );

  // Variabel observable untuk bookmark
  final isBookmarked = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Menggunakan Get.find() karena controller sudah di-inisialisasi di halaman home
    final c = Get.find<NewsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = (widget.newsDetail['title'] ?? '').toString();
    final img = (widget.newsDetail['image']?['small'] ?? '').toString();
    final date = (widget.newsDetail['isoDate'] ?? '').toString();
    final content = (widget.newsDetail['contentSnippet'] ?? '').toString();
    final link = (widget.newsDetail['link'] ?? '').toString();

    // Menggunakan Scaffold yang mengikuti tema dari main.dart
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            flex: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: img.isNotEmpty
                      ? Image.network(
                          img,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, w, p) => p == null
                              ? w
                              : Container(color: Colors.grey[200]),
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[200]),
                        )
                      : Container(color: Colors.grey[200]),
                ),
                Container(
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
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // PERBAIKAN: Menghapus setState, cukup ubah nilai .obs
                                    isBookmarked.value = !isBookmarked.value;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    // PERBAIKAN: Bungkus dengan Obx
                                    child: Obx(
                                      () => AnimatedScale(
                                        scale: isBookmarked.value ? 1.15 : 1.0,
                                        duration:
                                            const Duration(milliseconds: 180),
                                        curve: Curves.easeOutBack,
                                        child: Icon(
                                          isBookmarked.value
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // PERBAIKAN: Tombol ganti tema
                                GestureDetector(
                                  onTap: () => c.changeTheme(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Obx(
                                      () => Icon(
                                        c.isChange.value
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      FadeTransition(
                        opacity: _fadeTop,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (link.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(_categoryFromLink(link),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              const SizedBox(height: 16),
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('• ${_relativeTime(date)}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 40,
            child: FadeTransition(
              opacity: _fadeBottom,
              child: SlideTransition(
                position: _slideBottom,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // PERBAIKAN: Warna mengikuti tema
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (link.isNotEmpty)
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(_domainFromLink(link),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700]))),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                size: 16, color: Colors.blue),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            content.isNotEmpty
                                ? content
                                : 'Tidak ada ringkasan.',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                // PERBAIKAN: Warna teks mengikuti tema
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                height: 1.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons (dapat disesuaikan warnanya jika perlu)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                              icon: Icons.thumb_up_outlined, label: 'Suka'),
                          _ActionButton(
                              icon: Icons.comment_outlined, label: 'Komentar'),
                          _ActionButton(
                              icon: Icons.share_outlined, label: 'Bagikan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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