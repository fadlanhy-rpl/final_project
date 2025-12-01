import 'package:final_project/controllers/bookmark_controller.dart';
import 'package:final_project/controllers/news_controller.dart';
import 'package:final_project/model/new_article.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final AnimationController _animController;
  late final Animation<double> _fadeTop;
  late final Animation<double> _fadeBottom;
  late final Animation<Offset> _slideBottom;

  final NewsController newsC = Get.find();
  final BookmarkController bookmarkC = Get.put(BookmarkController());
  final TextEditingController _commentController = TextEditingController();

  late NewsArticle article;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _parseDataToModel();
    bookmarkC.resetState(article.title);
  }

  @override
  void dispose() {
    _animController.dispose();
    _commentController.dispose();
    super.dispose();
  }

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
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _animController.forward(),
    );
  }

  void _parseDataToModel() {
    final data = widget.newsDetail;

    String image = '';
    if (data['imageUrl'] != null) {
      image = data['imageUrl'];
    } else if (data['image'] != null && data['image']['small'] != null) {
      image = data['image']['small'];
    }

    String source = '';
    if (data['source'] != null) {
      source = data['source'];
    } else if (data['link'] != null) {
      source = data['link'];
    }

    String time = '';
    if (data['timeAgo'] != null) {
      time = data['timeAgo'];
    } else if (data['isoDate'] != null) {
      time = data['isoDate'];
    }

    String content = '';
    if (data['content'] != null) {
      content = data['content'];
    } else if (data['contentSnippet'] != null) {
      content = data['contentSnippet'];
    } else if (data['description'] != null) {
      content = data['description'];
    }

    article = NewsArticle(
      title: (data['title'] ?? '').toString(),
      source: source,
      timeAgo: time,
      views: (data['views'] ?? '0').toString(),
      comments: (data['comments'] ?? '0').toString(),
      imageUrl: image,
      content: content,
    );
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

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return '';
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF0F4F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A2B47);
    final textSecondary = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Obx(() {
                      final isActive = bookmarkC.isBookmarked.value;
                      return _buildCircleButton(
                        icon: isActive ? Icons.bookmark : Icons.bookmark_border,
                        isActive: isActive,
                        onTap: () {
                          if (isActive) {
                            bookmarkC.removeFromBookmark(article.title);
                          } else {
                            bookmarkC.addToBookmark(article);
                          }
                        },
                      );
                    }),
                    const SizedBox(width: 10),
                    _buildCircleButton(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: article.imageUrl.isNotEmpty
                      ? Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(color: Colors.grey[300]),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                // Top navigation bar
              ],
            ),
          ),

          Expanded(
            flex: 6,
            child: FadeTransition(
              opacity: _fadeBottom,
              child: SlideTransition(
                position: _slideBottom,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                article.title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Author & Date Row
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF1D4ED8),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _domainFromLink(article.source),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(article.timeAgo),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Divider
                              Container(
                                height: 1,
                                color: textSecondary.withOpacity(0.1),
                              ),

                              const SizedBox(height: 20),

                              // Content
                              Text(
                                article.content.isNotEmpty
                                    ? article.content
                                    : 'Tidak ada ringkasan tersedia untuk artikel ini.',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.8,
                                  color: textSecondary,
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border(
                            top: BorderSide(
                              color: textSecondary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextField(
                                    controller: _commentController,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Write a comment...',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1D4ED8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1A2B47),
        ),
      ),
    );
  }
}
