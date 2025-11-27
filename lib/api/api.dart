import 'dart:convert';
import 'package:get/get.dart';


import 'package:http/http.dart' as http;

class Api extends GetxController {
  Future<List<Map<String, dynamic>>> getApi({String category = ''}) async{
    final url = 'https://berita-indo-api.vercel.app/v1/cnn-news/'.obs;
    if (category.isNotEmpty) {
      url.value += category;
    }
    final response = await http.get(Uri.parse(url.value));

    
    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      final jsonList = json['data'] as List;
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    }
    else{
      throw Exception('Gagal Menampilkan Data');
    }
  }
}
