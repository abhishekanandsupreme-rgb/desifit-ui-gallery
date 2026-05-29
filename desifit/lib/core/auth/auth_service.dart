import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../storage/local_storage.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        displayName: json['displayName'] ?? '',
        email: json['email'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
      );
}

class AuthService {
  static FirebaseAuth? _authInstance;
  static FirebaseAuth get _auth {
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  static GoogleSignIn? _googleSignInInstance;
  static GoogleSignIn get _googleSignIn {
    _googleSignInInstance ??= GoogleSignIn();
    return _googleSignInInstance!;
  }

  // Try to sign in with Google. If config is missing, trigger simulator.
  static Future<UserModel?> signInWithGoogle({bool forceSimulate = false}) async {
    if (forceSimulate) {
      return _runSimulation();
    }

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.signIn().timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw TimeoutException('Google Sign-In Timed Out'),
            );
        
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          displayName: user.displayName ?? 'Desi Champ',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
        );
        _saveUserToCache(userModel);
        return userModel;
      }
    } catch (e) {
      print('Firebase/Google Auth failed: $e.');
      // Only fallback to simulator in debug mode, on localhost, or if explicitly requested.
      // In production/release (on actual domains), propagation is required to avoid data cross-contamination.
      if (kDebugMode || _isLocalHost || forceSimulate) {
        print('Falling back to simulator mode.');
        return _runSimulation();
      }
      rethrow;
    }
    return null;
  }


  static Future<UserModel> _runSimulation() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1200));
    final simulatedUser = UserModel(
      uid: 'simulated_user_123',
      displayName: 'Aarav Sharma',
      email: 'aarav.sharma@desifit.in',
      photoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=120',
    );
    _saveUserToCache(simulatedUser);
    return simulatedUser;
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Sign out error (ignored for simulator): $e');
    }
    _clearUserCache();
  }

  static UserModel? getCachedUser() {
    final map = LocalStorage.getCachedUser();
    if (map != null) {
      try {
        return UserModel.fromJson(map);
      } catch (e) {
        print('Error reading cached user: $e');
      }
    }
    return null;
  }

  static void _saveUserToCache(UserModel user) {
    LocalStorage.saveUser(user.toJson());
  }

  static void _clearUserCache() {
    LocalStorage.clearUser();
  }

  static bool get _isLocalHost {
    if (kIsWeb) {
      final host = Uri.base.host;
      return host == 'localhost' || host == '127.0.0.1';
    }
    return false;
  }
}
