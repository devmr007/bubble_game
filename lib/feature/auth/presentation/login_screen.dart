import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/bubble_background.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/responsive_container.dart';
import '../controller/auth_controller.dart';
import 'forgot_password_dialog.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authController = AuthController.to;

    return Scaffold(
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
                    const SizedBox(height: 20),
                    const AuthHeader(
                      title: AppStrings.loginTitle,
                      subtitle: AppStrings.loginSubtitle,
                    ),
                    const SizedBox(height: 32),
                    // Form Box
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppStyles.gameCard,
                      child: Column(
                        children: [
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  Get.dialog(const ForgotPasswordDialog()),
                              child: Text(
                                AppStrings.forgotPassword,
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => CustomButton(
                              text: AppStrings.signIn,
                              isLoading: authController.isLoading.value,
                              onPressed: () => authController.signInWithEmail(
                                emailController.text,
                                passwordController.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text('OR', style: AppStyles.bodySmall),
                              ),
                              const Expanded(
                                child: Divider(color: Colors.white24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Google Sign In
                          CustomButton(
                            text: AppStrings.continueWithGoogle,
                            icon: Icons.g_mobiledata_rounded,
                            gradient: AppColors.buttonGoogle,
                            onPressed: () => authController.signInWithGoogle(),
                          ),
                          const SizedBox(height: 12),
                          // Guest Mode
                          CustomButton(
                            text: AppStrings.playAsGuest,
                            icon: Icons.play_arrow_rounded,
                            gradient: AppColors.buttonGold,
                            onPressed: () => authController.playAsGuest(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Switch to Sign Up
                    Center(
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
                        child: Text(
                          AppStrings.noAccount,
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
