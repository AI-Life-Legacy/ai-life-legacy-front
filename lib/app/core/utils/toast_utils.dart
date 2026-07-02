import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtils {
  static void showInfoToast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        borderRadius: 24,
        margin: const EdgeInsets.all(24),
        backgroundColor: const Color(0xFF333333).withValues(alpha: 0.95),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 2000),
        animationDuration: const Duration(milliseconds: 300),
        barBlur: 10,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      ),
    );
  }

  static void showErrorToast(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        borderRadius: 24,
        margin: const EdgeInsets.all(24),
        backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.95),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 2000),
        animationDuration: const Duration(milliseconds: 300),
        barBlur: 10,
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
      ),
    );
  }
}
