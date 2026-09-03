import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/routing/routing.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/analytics_service.dart';
import './home_screen.dart';
import '../../../recipe_engine/presentation/screens/recipe_screen.dart';
import './coach_screen.dart';
import './workout_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../widgets/badges_dialog.dart';
import '../widgets/celebration_overlay.dart';
import '../../../../core/notifications/notification_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Log initial tab screen view
    AnalyticsService.logEvent('screen_view', {'screen_name': 'home'});
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const RecipeScreen(),
    const CoachScreen(),
    const WorkoutScreen(),
    const LeaderboardScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getAppBarTitle(int index, AppState state) {
    switch (index) {
      case 0:
        return 'DesiFit';
      case 1:
        return state.translate('Recipes');
      case 2:
        return state.translate('Coach');
      case 3:
        return state.translate('Workouts');
      case 4:
        return state.translate('Leaderboard');
      default:
        return 'DesiFit';
    }
  }

  String _getTabScreenName(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'recipes';
      case 2:
        return 'coach';
      case 3:
        return 'workouts';
      case 4:
        return 'leaderboard';
      default:
        return 'unknown';
    }
  }

  void _showSettingsDialog(BuildContext context, AppState state) {
    final budgetController = TextEditingController(text: state.dailyBudgetLimit.toInt().toString());
    final proteinController = TextEditingController(text: state.proteinGoal.toInt().toString());
    bool isHinglish = state.isHinglish;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                state.translate('Settings'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hinglish Toggle
                    SwitchListTile(
                      title: Text(
                        state.translate('Hinglish Mode'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        state.translate('Translate UI to Hinglish'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: isHinglish,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setDialogState(() {
                          isHinglish = val;
                        });
                        state.setHinglish(val);
                      },
                    ),
                    const Divider(),
                    // Daily Reminders Toggle
                    SwitchListTile(
                      title: Text(
                        state.translate('Daily Reminders'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        state.translate('Enable habit-forming notifications'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: NotificationService.areNotificationsEnabled(),
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) async {
                        await NotificationService.setNotificationsEnabled(val);
                        setDialogState(() {});
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.emoji_events_rounded, color: Colors.orange),
                      title: Text(
                        state.translate('Badges & Achievements'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.pop(context); // Close Settings dialog
                        BadgesDialog.show(context); // Open Badges dialog
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Budget limit
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: state.translate('Daily Budget (₹)'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Protein goal
                    TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: state.translate('Daily Protein Goal (g)'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    state.translate('Cancel'),
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final budget = double.tryParse(budgetController.text) ?? state.dailyBudgetLimit;
                    final protein = double.tryParse(proteinController.text) ?? state.proteinGoal;
                    state.setLimits(budget, protein);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.translate('Settings saved successfully!')),
                      ),
                    );
                  },
                  child: Text(
                    state.translate('Save'),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Stack(
      children: [
        Scaffold(
          extendBody: true, // Allow body to bleed behind bottom bar for glassmorphism blur
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              _getAppBarTitle(_currentIndex, state),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppColors.primaryContainer,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.emoji_events_outlined, color: AppColors.onSurfaceVariant),
                tooltip: 'Badges & Achievements',
                onPressed: () => BadgesDialog.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.menu_book_outlined, color: AppColors.onSurfaceVariant),
                tooltip: 'Desi Health Feed',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.healthFeed);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
                onPressed: () => _showSettingsDialog(context, state),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: state.currentUser?.photoUrl.isNotEmpty == true
                      ? NetworkImage(state.currentUser!.photoUrl)
                      : null,
                  child: state.currentUser?.photoUrl.isNotEmpty == true
                      ? null
                      : const Icon(Icons.person, color: AppColors.primary, size: 18),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Log the page change
                  AnalyticsService.logEvent('screen_view', {'screen_name': _getTabScreenName(index)});
                },
                children: _pages,
              ),
              if (state.isSyncing)
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.translate('Syncing local data...'),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildGlassBottomNavBar(state),
        ),
        if (state.showConfetti && state.celebrationTitle.isNotEmpty)
          Positioned.fill(
            child: CelebrationOverlay(
              title: state.celebrationTitle,
              message: state.celebrationMessage,
            ),
          ),
      ],
    );
  }

  Widget _buildGlassBottomNavBar(AppState state) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5F2).withValues(alpha: 0.85), // Blended warm cream-saffron tint
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35), // Blended saffron outline
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(state, 0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(state, 1, Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Recipes'),
                _buildNavItem(state, 2, Icons.directions_run, Icons.directions_run, 'Coach'),
                _buildNavItem(state, 3, Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
                _buildNavItem(state, 4, Icons.leaderboard_outlined, Icons.leaderboard, 'Leaderboard'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(AppState state, int index, IconData outlineIcon, IconData filledIcon, String label) {
    final bool isActive = _currentIndex == index;
    final String translatedLabel = state.translate(label);

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
          width: 58, // Prevent size variations and layout shifts between items
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? filledIcon : outlineIcon,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                translatedLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: isActive ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
