import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/controller/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Wait for smooth splash animations and Firebase initialization
    await Future.delayed(const Duration(milliseconds: 2200));

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final guestId = StorageService.getString('guest_id');

    if (firebaseUser != null) {
      await AuthController.to.fetchUserData(firebaseUser.uid);
      Get.offAllNamed(AppRoutes.main);
    } else if (guestId != null) {
      AuthController.to.playAsGuest();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}

