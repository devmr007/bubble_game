import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  void showEditNameDialog() {
    final user = AuthController.to.currentUser.value;
    final controller = TextEditingController(text: user?.displayName ?? '');

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppStyles.gameCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Name', style: AppStyles.h2),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller,
                hintText: 'Enter new name',
                prefixIcon: Icons.person_rounded,
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
                    child: CustomButton(
                      text: 'Save',
                      onPressed: () {
                        AuthController.to.updateProfileName(controller.text);
                        Get.back();
                      },
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

  void signOut() {
    AuthController.to.signOut();
  }
}

