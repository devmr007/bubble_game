import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class DialogUtil {
  static void showSuccess(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message, {String title = 'Oops!'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.danger,
  }) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.gameCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppStyles.h2),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        cancelText,
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(confirmText, style: AppStyles.buttonText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
