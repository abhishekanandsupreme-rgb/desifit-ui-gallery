import 'package:flutter/material.dart';

import '../../../../core/routing/routing.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/theme.dart';
import 'badges_dialog.dart';
import 'logout_confirm_dialog.dart';

/// Greeting row of the home dashboard: translated hello + streak badge +
/// profile avatar that logs out (logged in) or opens onboarding (guest).
class GreetingHeader extends StatelessWidget {
  final AppState state;
  const GreetingHeader({super.key, required this.state});

  @override  Widget build(BuildContext context) {
    final displayName = state.isLoggedIn ? state.currentUser!.displayName.split(' ')[0] : 'Champ';
    final photoUrl = state.isLoggedIn ? state.currentUser!.photoUrl : '';
    return Row(
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
                LogoutConfirmDialog.show(context, state);
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
