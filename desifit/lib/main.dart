import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/theme.dart';
import 'core/routing/routing.dart';
import 'core/state/app_state.dart';
import 'core/storage/local_storage.dart';
import 'core/ads/ad_service.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  // Global error zone — catches ALL uncaught async errors and prevents app crash
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch Flutter framework errors (widget build errors, layout errors, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FlutterError caught: ${details.exceptionAsString()}');
      debugPrint('Stack: ${details.stack}');
    };

    // Catch platform dispatcher errors (platform channel failures, etc.)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error caught: $error');
      debugPrint('Stack: $stack');
      return true; // Handled — do not crash
    };

    try {
      await LocalStorage.init();
    } catch (e) {
      debugPrint("LocalStorage initialization failed: $e");
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Firebase initialization failed (falling back to offline simulation): $e");
    }

    try {
      await AdService.init();
    } catch (e) {
      debugPrint("AdService initialization failed: $e");
    }

    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint("NotificationService initialization failed: $e");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const DesiFitApp(),
      ),
    );
  }, (error, stack) {
    // This catches any async error that escapes all try-catch blocks
    debugPrint('Uncaught zone error: $error');
    debugPrint('Stack: $stack');
  });
}

class DesiFitApp extends StatelessWidget {
  const DesiFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DesiFit',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: (settings) {
        final name = settings.name;
        final builder = AppRoutes.routes[name];
        if (builder != null) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => builder(context),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.06);
              const end = Offset.zero;
              const curve = Curves.easeOutBack;

              final offsetTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(offsetTween);

              final scaleTween = Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic));
              final scaleAnimation = animation.drive(scaleTween);

              final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
              final fadeAnimation = animation.drive(fadeTween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 220),
          );
        }
        return null;
      },
    );
  }
}
