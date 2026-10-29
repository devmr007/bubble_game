import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/dialog_util.dart';
import '../model/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind auth state stream
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    if (firebaseUser == null) {
      // Check if logged in as guest locally
      final guestId = StorageService.getString('guest_id');
      if (guestId != null) {
        final guestName =
            StorageService.getString('guest_name') ?? 'Guest Player';
        final coins = StorageService.getInt('guest_coins', defaultValue: 100);
        final level = StorageService.getInt('guest_level', defaultValue: 1);
        currentUser.value = UserModel(
          uid: guestId,
          email: 'guest@bubblegame.app',
          displayName: guestName,
          coins: coins,
          currentLevel: level,
          unlockedLevels: List.generate(level, (i) => i + 1),
          isGuest: true,
        );
      } else {
        currentUser.value = null;
      }
    } else {
      await fetchUserData(firebaseUser.uid);
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        currentUser.value = UserModel.fromFirestore(doc.data()!, uid);
      } else {
        // Create new firestore profile for existing auth user
        final user = _auth.currentUser;
        if (user != null) {
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'Player',
            photoUrl: user.photoURL,
          );
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set(newUser.toFirestore());
          currentUser.value = newUser;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user data: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      DialogUtil.showError('Please enter both email and password');
      return;
    }

    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await StorageService.remove('guest_id');
      DialogUtil.showSuccess('Welcome back!');
      Get.offAllNamed(AppRoutes.main);
    } on FirebaseAuthException catch (e) {
      DialogUtil.showError(e.message ?? 'Authentication failed');
    } catch (e) {
      DialogUtil.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      DialogUtil.showError('Please fill in all fields');
      return;
    }
    if (password.length < 6) {
      DialogUtil.showError('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: name.trim(),
          coins: AppConstants.defaultStartingCoins,
          currentLevel: 1,
          unlockedLevels: const [1],
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toFirestore());
        currentUser.value = newUser;
      }

      await StorageService.remove('guest_id');
      DialogUtil.showSuccess('Account created successfully!');
      Get.offAllNamed(AppRoutes.main);
    } on FirebaseAuthException catch (e) {
      DialogUtil.showError(e.message ?? 'Registration failed');
    } catch (e) {
      DialogUtil.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user != null) {
        final docRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? googleUser.displayName ?? 'Player',
            photoUrl: user.photoURL ?? googleUser.photoUrl,
            coins: AppConstants.defaultStartingCoins,
            currentLevel: 1,
            unlockedLevels: const [1],
          );
          await docRef.set(newUser.toFirestore());
          currentUser.value = newUser;
        } else {
          currentUser.value = UserModel.fromFirestore(doc.data()!, user.uid);
        }
      }

      await StorageService.remove('guest_id');
      DialogUtil.showSuccess('Signed in with Google!');
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      DialogUtil.showError('Google sign in error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void playAsGuest() {
    final guest = UserModel.guest();
    currentUser.value = guest;
    StorageService.setString('guest_id', guest.uid);
    StorageService.setString('guest_name', guest.displayName);
    StorageService.setInt('guest_coins', guest.coins);
    StorageService.setInt('guest_level', guest.currentLevel);

    DialogUtil.showInfo('Playing as Guest. Sign in later to save to cloud!');
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      DialogUtil.showError('Please enter your email');
      return;
    }
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      DialogUtil.showSuccess('Password reset link sent to your email!');
    } on FirebaseAuthException catch (e) {
      DialogUtil.showError(e.message ?? 'Failed to send reset link');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    final confirm = await DialogUtil.showConfirmDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (confirm == true) {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await StorageService.remove('guest_id');
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> updateProfileName(String newName) async {
    if (newName.trim().isEmpty) return;
    final user = currentUser.value;
    if (user == null) return;

    final updated = user.copyWith(displayName: newName.trim());
    currentUser.value = updated;

    if (!user.isGuest) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'displayName': newName.trim()});
      await _auth.currentUser?.updateDisplayName(newName.trim());
    } else {
      await StorageService.setString('guest_name', newName.trim());
    }
    DialogUtil.showSuccess('Profile updated!');
  }

  Future<void> recordGameCompletion({
    required int level,
    required int stars,
    required int coinsWon,
    required int score,
  }) async {
    final user = currentUser.value;
    if (user == null) return;

    final currentStars = Map<String, int>.from(user.levelStars);
    final previousStars = currentStars[level.toString()] ?? 0;
    if (stars > previousStars) {
      currentStars[level.toString()] = stars;
    }

    final newUnlocked = List<int>.from(user.unlockedLevels);
    final nextLevel = level + 1;
    if (nextLevel <= AppConstants.totalLevels &&
        !newUnlocked.contains(nextLevel)) {
      newUnlocked.add(nextLevel);
    }

    final newCurrentLevel = nextLevel <= AppConstants.totalLevels
        ? (nextLevel > user.currentLevel ? nextLevel : user.currentLevel)
        : user.currentLevel;

    final newCoins = user.coins + coinsWon;
    final newHighScore = score > user.highScore ? score : user.highScore;
    final newPlayed = user.gamesPlayed + 1;
    final newWon = user.gamesWon + 1;

    final updated = user.copyWith(
      coins: newCoins,
      currentLevel: newCurrentLevel,
      unlockedLevels: newUnlocked,
      levelStars: currentStars,
      highScore: newHighScore,
      gamesPlayed: newPlayed,
      gamesWon: newWon,
    );

    currentUser.value = updated;

    if (!user.isGuest) {
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
              'coins': newCoins,
              'currentLevel': newCurrentLevel,
              'unlockedLevels': newUnlocked,
              'levelStars': currentStars,
              'highScore': newHighScore,
              'gamesPlayed': newPlayed,
              'gamesWon': newWon,
              'updatedAt': Timestamp.now(),
            });
      } catch (e) {
        if (kDebugMode) print('Failed to update firestore score: $e');
      }
    } else {
      await StorageService.setInt('guest_coins', newCoins);
      await StorageService.setInt('guest_level', newCurrentLevel);
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
