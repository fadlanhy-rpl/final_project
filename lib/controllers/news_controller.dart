import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsController extends GetxController {
  final isChange = false.obs;

  void changeTheme() {
    isChange.value = !isChange.value;
    if (isChange.value) {
      Get.changeTheme(ThemeData.dark());
    } else {
      Get.changeTheme(ThemeData.light());
    }
  }
}