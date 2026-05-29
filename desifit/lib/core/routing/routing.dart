import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell.dart';
import '../../features/dashboard/presentation/screens/workout_screen.dart';
import '../../features/dashboard/presentation/screens/progress_report_screen.dart';
import '../../features/health_feed/presentation/screens/health_feed_screen.dart';
import '../../features/dashboard/presentation/screens/progress_scan_screen.dart';
import '../../features/dashboard/presentation/screens/calorie_counter_screen.dart';
import '../../features/recipe_engine/presentation/screens/sasta_protein_calculator_screen.dart';
import '../../features/planner/presentation/screens/grocery_planner_screen.dart';
import '../../features/dashboard/presentation/screens/akhada_sandbox_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String mainShell = '/main';
  static const String workout = '/workout';
  static const String progressReport = '/progress-report';
  static const String healthFeed = '/health-feed';
  static const String progressScan = '/progress-scan';
  static const String calorieCounter = '/calorie-counter';
  static const String sastaCalculator = '/sasta-calculator';
  static const String groceryPlanner = '/grocery-planner';
  static const String akhadaSandbox = '/akhada-sandbox';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (context) => const OnboardingScreen(),
        mainShell: (context) => const MainShell(),
        workout: (context) => const WorkoutScreen(),
        progressReport: (context) => const ProgressReportScreen(),
        healthFeed: (context) => const HealthFeedScreen(),
        progressScan: (context) => const ProgressScanScreen(),
        calorieCounter: (context) => const CalorieCounterScreen(),
        sastaCalculator: (context) => const SastaProteinCalculatorScreen(),
        groceryPlanner: (context) => const GroceryPlannerScreen(),
        akhadaSandbox: (context) => const AkhadaSandboxScreen(),
      };
}
