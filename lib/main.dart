import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_pages.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/controller/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  await StorageService.init();
  await FirebaseService.init();

  // Initialize Global Controllers
  Get.put(AuthController(), permanent: true);

  runApp(const BubbleGameApp());
}

class BubbleGameApp extends StatelessWidget {
  const BubbleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
