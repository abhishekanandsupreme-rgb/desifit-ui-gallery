import 'package:flutter/foundation.dart';
import '../auth/auth_service.dart';

class AuthState extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _currentUser == null || _currentUser!.uid == 'guest_user';

  AuthState() {
    _currentUser = AuthService.getCachedUser();
  }

  Future<void> loginWithGoogle() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AppState loginWithGoogle error: $e');
      rethrow;
    }
  }

  Future<void> loginAsGuest() async {
    _currentUser = UserModel(
      uid: 'guest_user',
      displayName: 'Guest Champ',
      email: 'guest@desifit.in',
      photoUrl: '',
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
