import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/analytics_service.dart';
import '../widgets/guest_prompt_widget.dart';

class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent('screen_view', {'screen_name': 'progress_report'});
  }

  void _showShareDialog(BuildContext context, String title, String cardText) {
    AnalyticsService.logEvent('share_card_generated', {
      'card_type': title,
      'card_content': cardText,
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Here is your shareable text card. Copy it to share with friends or post on social media!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: SelectableText(
                  cardText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cardText));
                AnalyticsService.logEvent('social_shared', {
                  'card_type': title,
                  'card_content': cardText,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card copied to clipboard!')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
              ),
              icon: const Icon(Icons.copy, color: Colors.white, size: 18),
              label: const Text('COPY & SHARE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final progress = state.weeklyProgress;

    // Compute sums
    double avgProtein = 0;
    double totalBudget = 0;
    int totalWorkouts = 0;
    for (var p in progress) {
      avgProtein += p.proteinGrams;
      totalBudget += p.budgetSpent;
      totalWorkouts += p.workoutsCompleted;
    }
    if (progress.isNotEmpty) {
      avgProtein /= progress.length;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Progress & Reports',
          style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Macro summaries
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Avg Protein',
                    val: '${avgProtein.toInt()}g',
                    sub: 'Target: ${state.proteinGoal.toInt()}g',
                    color: AppColors.secondary,
                    icon: Icons.egg_alt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Total Budget',
                    val: '₹${totalBudget.toInt()}',
                    sub: 'Average: ₹${(totalBudget / (progress.isNotEmpty ? progress.length : 1)).toInt()}',
                    color: AppColors.primary,
                    icon: Icons.wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Line Chart: Protein Trend
            Text(
              'WEEKLY PROTEIN TREND (G)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: CustomPaint(
                  painter: _LineChartPainter(
                    data: progress.map((e) => e.proteinGrams).toList(),
                    labels: progress.map((e) => e.dayName).toList(),
                    lineColor: AppColors.secondary,
                    targetValue: state.proteinGoal,
                  ),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bar Chart: Budget Trend
            Text(
              'WEEKLY BUDGET EXPENDITURE (₹)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              child: Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: CustomPaint(
                  painter: _BarChartPainter(
                    data: progress.map((e) => e.budgetSpent).toList(),
                    labels: progress.map((e) => e.dayName).toList(),
                    barColor: AppColors.primary,
                    targetValue: state.dailyBudgetLimit,
                  ),
                  child: Container(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Summary Stats Card: Workouts
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.fitness_center, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Workout Volume',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed $totalWorkouts sessions. Keep backing up gains!',
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final cardText = ShareMockGenerator.generateStreakCard(
                  streakDays: state.sattuStreak > 0 ? state.sattuStreak : 7,
                  proteinGrams: state.proteinHit > 0 ? state.proteinHit : 60,
                  cost: state.budgetSpent > 0 ? state.budgetSpent : 25,
                );
                _showShareDialog(context, 'Sattu Streak Card', cardText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.secondary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.share, color: AppColors.secondary, size: 18),
              label: const Text('SHARE SATTU STREAK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      if (state.isGuest)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(24.0),
            child: const Center(
              child: GuestPromptWidget(
                title: '🔒 Unlock Progress Tracking',
                description: 'Track your consecutive Sattu Streak, log your daily protein intake, check budget spends, and view your visual performance reports. Sign in with Google to get started!',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String val,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: color.withValues(alpha: 0.4), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            val,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Line Chart Painter using CustomPaint
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;
  final double targetValue;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
    required this.targetValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double paddingX = size.width / (data.length - 1);
    final double maxVal = max(data.reduce(max), targetValue) * 1.25;

    // Draw grid horizontal lines
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw target reference line
    final targetY = size.height - (targetValue / maxVal) * size.height;
    final targetPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, targetY), Offset(size.width, targetY), targetPaint);

    // Compute coordinates
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final double x = i * paddingX;
      final double y = size.height - (data[i] / maxVal) * size.height;
      points.add(Offset(x, y));
    }

    // Draw curved fill path
    final fillPath = Path()
      ..moveTo(0, size.height);
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final controlX1 = prev.dx + (curr.dx - prev.dx) / 2;
        final controlY1 = prev.dy;
        final controlX2 = prev.dx + (curr.dx - prev.dx) / 2;
        final controlY2 = curr.dy;
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, curr.dx, curr.dy);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()
      ..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final controlX1 = prev.dx + (curr.dx - prev.dx) / 2;
      final controlY1 = prev.dy;
      final controlX2 = prev.dx + (curr.dx - prev.dx) / 2;
      final controlY2 = curr.dy;
      linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, curr.dx, curr.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (var pt in points) {
      canvas.drawCircle(pt, 6, dotPaint);
      canvas.drawCircle(pt, 3, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.targetValue != targetValue ||
        !_listEquals(oldDelegate.data, data) ||
        !_listEquals(oldDelegate.labels, labels);
  }
}

// Bar Chart Painter using CustomPaint
class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color barColor;
  final double targetValue;

  _BarChartPainter({
    required this.data,
    required this.labels,
    required this.barColor,
    required this.targetValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = max(data.reduce(max), targetValue) * 1.25;
    final double spacing = size.width / data.length;
    final double barWidth = spacing * 0.45;

    // Draw target line
    final targetY = size.height - (targetValue / maxVal) * size.height;
    final targetPaint = Paint()
      ..color = barColor.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, targetY), Offset(size.width, targetY), targetPaint);

    // Draw bars
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final double left = i * spacing + (spacing - barWidth) / 2;
      final double top = size.height - (data[i] / maxVal) * size.height;
      final double right = left + barWidth;
      final double bottom = size.height;

      // Curved corners at top
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTRB(left, top, right, bottom),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.barColor != barColor ||
        oldDelegate.targetValue != targetValue ||
        !_listEquals(oldDelegate.data, data) ||
        !_listEquals(oldDelegate.labels, labels);
  }
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
