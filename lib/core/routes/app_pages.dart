import 'package:get/get.dart';
import '../../feature/auth/presentation/login_screen.dart';
import '../../feature/auth/presentation/register_screen.dart';
import '../../feature/game/presentation/game_screen.dart';
import '../../feature/levels/presentation/level_select_screen.dart';
import '../../feature/navigation/presentation/main_screen.dart';
import '../../feature/profile/presentation/profile_screen.dart';
import '../../feature/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.levels,
      page: () => const LevelSelectScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameScreen(),
      transition: Transition.circularReveal,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}

