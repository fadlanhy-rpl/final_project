
import 'package:flutter/material.dart';

import '../model/model.dart';

class DummyData {

  static final List<NewsSource> newsSources = [
    NewsSource(name: 'CNN', color: Colors.red, logo: 'assets/cnn_logo.png'),
    NewsSource(name: 'NBC', color: Colors.blue, logo: 'assets/nbc_logo.png'),
    NewsSource(name: 'BBC', color: Colors.orange, logo: 'assets/bbc_logo.png'),
    NewsSource(name: 'Fox', color: Colors.purple, logo: 'assets/fox_logo.png'),
    NewsSource(name: 'ABC', color: Colors.green, logo: 'assets/abc_logo.png'),
    NewsSource(name: 'CBS', color: Colors.teal, logo: 'assets/cbs_logo.png'),
    NewsSource(name: 'Reuters', color: Colors.indigo, logo: 'assets/reuters_logo.png'),
    NewsSource(name: 'AP', color: Colors.pink, logo: 'assets/ap_logo.png'),
  ]; 

  static final List<String> categories = [
    'Trending',
    'Business',
    'Health',
    'Politics',
    'Sports'
  ];

  static final BreakingNews breakingNews = BreakingNews(
    title: 'Ukraine conflict: Key developments for a Russian assault',
    source: 'CNN News',
    timeAgo: '2h ago',
    imageUrl: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/new-f9phYN6FjfkblBHblWjN2ub0zXzroy.png',
    isLive: true,
  );

}
