
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../widgets/base_text.dart';

void successSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    titleText: BaseText(
      text: title,
      bold: FontWeight.bold,
    ),
    messageText: BaseText(
      text: message,
      bold: FontWeight.w500,
      color: Colors.grey.shade600,
    ),
    margin: const EdgeInsets.all(15),
    borderRadius: 10,
    icon: Icon(
      MingCute.check_circle_line,
      color: Colors.green.shade800,
      size: 30,
    ),
    boxShadows: [
      BoxShadow(
        color: Colors.grey.shade500,
        spreadRadius: 2,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
    backgroundColor: Colors.white,
    colorText: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shouldIconPulse: false,
  );
}

void failedSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    titleText: BaseText(
      text: title,
      bold: FontWeight.bold,
    ),
    messageText: BaseText(
      text: message,
      bold: FontWeight.w500,
      color: Colors.grey.shade600,
    ),
    margin: const EdgeInsets.all(15),
    borderRadius: 10,
    icon: Icon(
      MingCute.close_circle_line,
      color: Colors.red.shade800,
      size: 30,
    ),
    boxShadows: [
      BoxShadow(
        color: Colors.grey.shade500,
        spreadRadius: 2,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
    backgroundColor: Colors.white,
    colorText: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shouldIconPulse: false,
  );
}

void infoSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    titleText: BaseText(
      text: title,
      bold: FontWeight.w600,
    ),
    messageText: BaseText(
      text: message,
      bold: FontWeight.w500,
      color: Colors.grey.shade600,
    ),
    margin: const EdgeInsets.all(15),
    borderRadius: 10,
    icon: Icon(
      MingCute.information_line,
      color: Colors.blue.shade800,
      size: 30,
    ),
    boxShadows: [
      BoxShadow(
        color: Colors.grey.shade500,
        spreadRadius: 2,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
    backgroundColor: Colors.white,
    colorText: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shouldIconPulse: false,
  );
}