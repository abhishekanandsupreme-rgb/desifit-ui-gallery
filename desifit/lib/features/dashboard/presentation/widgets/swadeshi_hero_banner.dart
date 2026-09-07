import 'package:flutter/material.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/theme/theme.dart';

/// Pulsing-glow hero banner for the Swadeshi strength pitch.
class SwadeshiHeroBanner extends StatefulWidget {
  final AppState state;
  const SwadeshiHeroBanner({super.key, required this.state});

  @override
  State<SwadeshiHeroBanner> createState() => _SwadeshiHeroBannerState();
}

class _SwadeshiHeroBannerState extends State<SwadeshiHeroBanner> with SingleTickerProviderStateMixin {
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


