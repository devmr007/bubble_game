import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final authController = AuthController.to;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyles.gameCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.resetPassword, style: AppStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Enter your registered email and we will send you a password reset link.',
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              hintText: AppStrings.email,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: AppStyles.bodyLarge.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text: 'Send',
                      isLoading: authController.isLoading.value,
                      onPressed: () {
                        authController.resetPassword(emailController.text);
                        Get.back();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

