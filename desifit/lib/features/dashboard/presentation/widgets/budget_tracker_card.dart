import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';

class BudgetTrackerCard extends StatelessWidget {
  const BudgetTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final limit = state.dailyBudgetLimit;
        final spent = limit - state.budgetLeft;
        final left = state.budgetLeft;
        final percent = limit > 0 ? (left / limit).clamp(0.0, 1.0) : 0.0;

        return Semantics(
          container: true,
          label: '${state.translate('Daily Budget')}. ${state.translate('Budget left')}: ₹${left.toInt()} of ₹${limit.toInt()}',
          child: Container(
          key: const ValueKey('budget'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: ProgressRingPainter(
                            percentage: percent,
                            baseColor: AppColors.surfaceContainerHigh,
                            progressColor: AppColors.primary,
                            gradient: AppColors.saffronGradient,
                            strokeWidth: 8,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '₹${left.toInt()}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.translate('Daily Budget Left'),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.translate('Spent')}: ₹${spent.toInt()} • ${state.translate('Limit')}: ₹${limit.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      button: true,
                      label: '${state.translate('Weekly Reports')}. ${state.translate('Open progress report')}',
                      child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.progressReport);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bar_chart, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              state.translate('Weekly Reports'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double percentage;
  final Color baseColor;
  final Color progressColor;
  final List<Color>? gradient;
  final double strokeWidth;

  ProgressRingPainter({
    required this.percentage,
    required this.baseColor,
    required this.progressColor,
    this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, basePaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null && gradient!.length >= 2) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = SweepGradient(
        colors: gradient!,
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
