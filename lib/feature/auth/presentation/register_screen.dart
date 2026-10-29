import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/dialog_util.dart';
import '../../../core/widgets/bubble_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/responsive_container.dart';
import '../controller/auth_controller.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authController = AuthController.to;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BubbleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const AuthHeader(
                      title: 'Join the Fun!',
                      subtitle:
                          'Create your account to unlock levels and win coins',
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppStyles.gameCard,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            hintText: AppStrings.name,
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            hintText: AppStrings.email,
                            prefixIcon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => CustomTextField(
                              controller: passwordController,
                              hintText: AppStrings.password,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText:
                                  !authController.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authController.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.textMuted,
                                ),
                                onPressed:
                                    authController.togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: confirmPasswordController,
                            hintText: AppStrings.confirmPassword,
                            prefixIcon: Icons.lock_reset_rounded,
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => CustomButton(
                              text: AppStrings.signUp,
                              isLoading: authController.isLoading.value,
                              onPressed: () {
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  DialogUtil.showError(
                                    'Passwords do not match',
                                  );
                                  return;
                                }
                                authController.signUpWithEmail(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
