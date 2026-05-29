import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class BadgeMetadata {
  final String name;
  final String category;
  final String description;
  final String icon;
  final List<Color> gradientColors;

  BadgeMetadata({
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}

final List<BadgeMetadata> allBadges = [
  BadgeMetadata(
    name: 'Sattu Scholar',
    category: 'Milestone Level 1',
    description: 'Unlocked by exploring recipes or adding a Sattu/soya meal.',
    icon: '🎓',
    gradientColors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
  ),
  BadgeMetadata(
    name: 'Protein Pro',
    category: 'Milestone Level 2',
    description: 'Unlocked by meeting your daily protein goals.',
    icon: '🍗',
    gradientColors: [const Color(0xFFF12711), const Color(0xFFF5AF19)],
  ),
  BadgeMetadata(
    name: 'Loha Lath',
    category: 'Workout Champion',
    description: 'Unlocked by completing your dorm workout sessions.',
    icon: '💪',
    gradientColors: [const Color(0xFF833AB4), const Color(0xFFFD1D1D)],
  ),
  BadgeMetadata(
    name: 'Paisa Bachau',
    category: 'Budget Master',
    description: 'Unlocked by logging meals and staying under daily budget.',
    icon: '💰',
    gradientColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
  ),
  BadgeMetadata(
    name: 'Sattu Samrat',
    category: 'Ultimate Milestone',
    description: 'Unlocked by maintaining an active 5+ day Sattu Streak.',
    icon: '👑',
    gradientColors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
  ),
];

class BadgesDialog extends StatelessWidget {
  const BadgesDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const BadgesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Consumer<AppState>(
              builder: (context, state, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dialog Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '🏆 Badges & Achievements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (state.isGuest) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Claim Your Badges!',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Guest badges are temporary. Sign in to save your sattu metrics permanently!',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await state.loginWithGoogle();
                                      if (context.mounted) Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Login failed: $e')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.onSurface,
                                    elevation: 1,
                                    shadowColor: Colors.black12,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.outlineVariant.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    minimumSize: const Size.fromHeight(38),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                        width: 14,
                                        height: 14,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.login,
                                          color: Colors.red,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Sign In with Google',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Streak Summary Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 32)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${state.sattuStreak} Day Sattu Streak',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Complete workouts or hit budget/protein goals daily to build your streak!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Badges Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: allBadges.length,
                          itemBuilder: (context, index) {
                            final badge = allBadges[index];
                            final isEarned = state.earnedBadges.contains(badge.name);

                            return InkWell(
                              onTap: () {
                                // Manual toggle for testing
                                state.toggleBadgeManually(badge.name);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEarned 
                                          ? 'Removed ${badge.name} badge' 
                                          : 'Earned ${badge.name} badge!',
                                    ),
                                    duration: const Duration(milliseconds: 800),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isEarned 
                                      ? Colors.white.withOpacity(0.9) 
                                      : Colors.grey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isEarned 
                                        ? badge.gradientColors.first.withOpacity(0.5) 
                                        : Colors.grey.withOpacity(0.2),
                                    width: isEarned ? 2.0 : 1.0,
                                  ),
                                  boxShadow: isEarned ? [
                                    BoxShadow(
                                      color: badge.gradientColors.first.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Badge Icon with Gradient Background
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: isEarned 
                                                  ? LinearGradient(
                                                      colors: badge.gradientColors,
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    )
                                                  : LinearGradient(
                                                      colors: [Colors.grey.shade400, Colors.grey.shade500],
                                                    ),
                                              boxShadow: isEarned ? [
                                                BoxShadow(
                                                  color: badge.gradientColors.first.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                )
                                              ] : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                badge.icon,
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  color: isEarned ? Colors.white : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            badge.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isEarned ? AppColors.onSurface : Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            badge.category,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: isEarned ? AppColors.primary : Colors.grey.shade500,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            badge.description,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: isEarned ? AppColors.onSurfaceVariant : Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isEarned)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(
                                          Icons.lock_outline_rounded,
                                          size: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    if (isEarned)
                                      const Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.check,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        const Divider(),
                        const SizedBox(height: 8),

                        // Tester / Simulating Actions
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '⚙️ Simulator Controls (For Grading & Testing)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  state.incrementStreakManually();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: const Icon(Icons.bolt, size: 16),
                                label: const Text('Simulate +1 Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  state.resetStreakAndBadges();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reset All', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '💡 Note: Tapping individual badges toggles their locked/unlocked state directly.',
                          style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
