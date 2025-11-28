class NewsArticle {
  final String title;
  final String source;
  final String timeAgo;
  final String views;
  final String comments;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.views,
    required this.comments,
    required this.imageUrl,
  });

  // 1. Fungsi toJson (Packing) 🧳
  // Mengubah Object menjadi Map agar bisa disimpan ke Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'timeAgo': timeAgo,
      'views': views,
      'comments': comments,
      'imageUrl': imageUrl,
    };
  }

  // 2. Fungsi fromJson (Unpacking) 📦
  // Mengubah data dari Firestore kembali menjadi Object agar bisa dipakai di UI
  // (Kita siapkan sekarang biar nanti pas fitur "Tampilkan Bookmark" sudah siap)
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      source: json['source'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      views: json['views'] ?? '0',
      comments: json['comments'] ?? '0',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}