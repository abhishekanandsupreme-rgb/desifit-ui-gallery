import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/badges_dialog.dart';
import '../widgets/matka_hydration_widget.dart';
import '../widgets/diet_tracker_card.dart';
import '../widgets/budget_tracker_card.dart';
import '../widgets/health_profile_card.dart';
import '../widgets/toolbox_grid.dart';
import '../widgets/quick_add_grid.dart';
import 'story_viewer_screen.dart';
import '../../../../core/ads/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTrackerIndex = 0;

  void _showLogoutConfirmation(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Hey ${state.currentUser!.displayName}, do you want to log out of your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                state.logout();
                Navigator.pop(context);
              },
              child: const Text('LOG OUT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildTrackerTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _buildTabButton(0, '🔥 Diet', AppColors.primary),
          _buildTabButton(1, '💰 Budget', AppColors.primary),
          _buildTabButton(2, '💧 Hydration', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, Color activeColor) {
    final isSelected = _selectedTrackerIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTrackerIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : Colors.grey[600],
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }












  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final clampedTextScaler = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: clampedTextScaler,
      ),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          final displayName = state.isLoggedIn ? state.currentUser!.displayName.split(' ')[0] : 'Champ';
          final photoUrl = state.isLoggedIn ? state.currentUser!.photoUrl : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header Logo
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Greeting Section & Profile Logout Trigger
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  state.translate('Hello, Champ!', name: displayName),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => BadgesDialog.show(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.35), width: 1.2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const _HeartbeatStreakWidget(
                                        child: Text('🔥', style: TextStyle(fontSize: 13)),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.sattuStreak} ${state.sattuStreak == 1 ? 'Day' : 'Days'}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.isLoggedIn
                                ? state.translate('Hit your targets today!')
                                : state.translate('Ready to fuel up on a budget?'),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: state.translate('Profile menu. Logged in as {name}. Double tap to log out.', name: displayName),
                      child: GestureDetector(
                        onTap: () {
                          if (state.isLoggedIn) {
                            _showLogoutConfirmation(context, state);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.onboarding);
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl.isEmpty
                              ? Icon(
                                  state.isLoggedIn ? Icons.person : Icons.login,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SwadeshiHeroBanner(state: state),
                const SizedBox(height: 24),

                // 1. Fitness Stories Tray
                Text(
                  state.translate('FITNESS STORIES'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.stories.length,
                    itemBuilder: (context, idx) {
                      final story = state.stories[idx];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Semantics(
                          button: true,
                          label: state.translate(
                            story.isRead ? 'Read fitness story: {title}' : 'Unread fitness story: {title}',
                            name: story.title,
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StoryViewerScreen(initialIndex: idx),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: story.isRead
                                          ? [Colors.grey.shade400, Colors.grey.shade600]
                                          : [AppColors.primary, AppColors.primaryContainer],
                                    ),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      story.avatarText,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                story.title,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: story.isRead ? Colors.grey : AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Combined Daily Tracker Hub
                _buildTrackerTabs(context),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTrackerIndex == 0
                      ? const DietTrackerCard()
                      : _selectedTrackerIndex == 1
                          ? const BudgetTrackerCard()
                          : const MatkaHydrationWidget(key: ValueKey('hydration')),
                ),
                const SizedBox(height: 24),

                // 3. Expandable My Health Profile Card
                const HealthProfileCard(),
                const SizedBox(height: 24),

                // 4. Swadeshi Toolbox
                const ToolboxGrid(),
                const SizedBox(height: 24),

                // 5. Daily Mythbuster
                Text(
                  state.translate('DAILY MYTHBUSTER'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                const FlashcardWidget(),
                const SizedBox(height: 24),

                // 6. Quick Add Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      state.translate('Quick Add'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(),
                  ],
                ),
                const SizedBox(height: 16),
                const QuickAddGrid(),
                const SizedBox(height: 32),

                // 7. Affiliate & Ad Banner Section
                Container(
                  width: double.infinity,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Amazon Deal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Buy 1kg Premium Peanut Butter on Amazon',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          button: true,
                          label: 'Shop Now on Amazon. Open Affiliate Link.',
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening Amazon Affiliate Link...')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SHOP NOW',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sponsor Ad Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: const BannerAdWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SwadeshiHeroBanner extends StatefulWidget {
  final AppState state;
  const _SwadeshiHeroBanner({required this.state});

  @override
  State<_SwadeshiHeroBanner> createState() => _SwadeshiHeroBannerState();
}

class _SwadeshiHeroBannerState extends State<_SwadeshiHeroBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowVal = _glowAnimation.value;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25 * glowVal),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04 * glowVal),
                blurRadius: 16 * glowVal,
                spreadRadius: 1.2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Positioned(
                bottom: -24,
                right: -24,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.sports_martial_arts,
                    size: 130,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          widget.state.translate('SWADESHI STRENGTH'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.state.translate("India's Only Calisthenics & Desi Workouts App"),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          fontSize: 20,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.state.translate(
                      "Reclaiming traditional strength (Dand, Baithak, Gada Swings) fused with progressive calisthenics. Build steel muscle inside your hostel room."
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Row of category highlights
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMiniBadge('👊 Desi Strength', Colors.amber),
                      _buildMiniBadge('💪 Bodyweight Calisthenics', AppColors.secondary),
                      _buildMiniBadge('🔥 0 Cost Gym', Colors.red),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        widget.state.translate(text),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }
}

class _BouncingScaleWidget extends StatefulWidget {
  final Widget child;
  const _BouncingScaleWidget({required this.child});

  @override
  State<_BouncingScaleWidget> createState() => _BouncingScaleWidgetState();
}

class _BouncingScaleWidgetState extends State<_BouncingScaleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class _HeartbeatStreakWidget extends StatefulWidget {
  final Widget child;
  const _HeartbeatStreakWidget({required this.child});

  @override
  State<_HeartbeatStreakWidget> createState() => _HeartbeatStreakWidgetState();
}

class _HeartbeatStreakWidgetState extends State<_HeartbeatStreakWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.94, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
