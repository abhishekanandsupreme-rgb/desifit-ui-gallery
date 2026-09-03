import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class MatkaHydrationWidget extends StatefulWidget {
  const MatkaHydrationWidget({super.key});

  @override
  State<MatkaHydrationWidget> createState() => _MatkaHydrationWidgetState();
}

class _MatkaHydrationWidgetState extends State<MatkaHydrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final consumed = state.waterConsumed;
    final goal = state.waterGoal;
    final double percentage = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: AppColors.surfaceContainerLowest,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.translate('Desi Hydration'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.translate('Keep cool with earthen matka drinks'),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                  onPressed: () => state.resetWater(),
                  tooltip: 'Reset Water Logs',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Matka Clay Pot Painter & Stats Row
            Row(
              children: [
                // Custom clay pot painter
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(100, 110),
                      painter: MatkaWaterPainter(
                        waterPercentage: percentage,
                        waveValue: _waveController.value,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),

                // Intake Statistics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate('Daily Target'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${consumed.toInt()} / ${goal.toInt()} ml',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2B8CD4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percentage * 100).toInt()}% ${state.translate('Completed')}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: percentage >= 1.0 ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Swadeshi Drinks Logging Chips
            const Text(
              'QUICK ADD DESI REFRESHMENTS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDrinkChip(state, '💧 Water', 250),
                _buildDrinkChip(state, '🥛 Chaas', 250, subtitle: 'Buttermilk'),
                _buildDrinkChip(state, '🥛 Lassi', 300),
                _buildDrinkChip(state, '🌾 Sattu Drink', 300, subtitle: 'Desi Energy'),
                _buildDrinkChip(state, '🥥 Coconut', 250, subtitle: 'Nariyal Pani'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkChip(AppState state, String label, double amount, {String? subtitle}) {
    return GestureDetector(
      onTap: () {
        state.logWater(amount);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged +${amount.toInt()}ml ($label) to your Matka!',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2B8CD4).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '+${amount.toInt()}ml${subtitle != null ? " ($subtitle)" : ""}',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatkaWaterPainter extends CustomPainter {
  final double waterPercentage;
  final double waveValue;

  MatkaWaterPainter({
    required this.waterPercentage,
    required this.waveValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    final clayPaint = Paint()
      ..color = const Color(0xFFD27D56) // Terracotta Clay Color
      ..style = PaintingStyle.fill;

    final clayOutline = Paint()
      ..color = const Color(0xFF8C4C30) // Darker border
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFF3498DB).withValues(alpha: 0.85) // Wave Blue
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Draw clay pot body shape (Matka)
    final matkaPath = Path();
    
    // Neck of the pot
    matkaPath.moveTo(w * 0.3, h * 0.1);
    matkaPath.quadraticBezierTo(w * 0.3, h * 0.03, w * 0.25, h * 0.03); // Top rim left
    matkaPath.lineTo(w * 0.75, h * 0.03); // Rim top
    matkaPath.quadraticBezierTo(w * 0.7, h * 0.03, w * 0.7, h * 0.1); // Top rim right
    
    // Flared Neck curves to bloated body
    matkaPath.cubicTo(w * 0.7, h * 0.2, w * 0.95, h * 0.25, w * 0.95, h * 0.6); // Bloated right
    matkaPath.cubicTo(w * 0.95, h * 0.95, w * 0.05, h * 0.95, w * 0.05, h * 0.6); // Rounded bottom
    matkaPath.cubicTo(w * 0.05, h * 0.25, w * 0.3, h * 0.2, w * 0.3, h * 0.1); // Bloated left
    matkaPath.close();

    // 1. Draw Earthen Matka Backing
    canvas.drawPath(matkaPath, clayPaint);

    // 2. Draw Earthen Rim details
    final rimPath = Path()
      ..moveTo(w * 0.25, h * 0.03)
      ..quadraticBezierTo(w * 0.5, h * 0.07, w * 0.75, h * 0.03)
      ..quadraticBezierTo(w * 0.5, h * 0.0, w * 0.25, h * 0.03);
    canvas.drawPath(rimPath, Paint()..color = const Color(0xFFA65835));
    canvas.drawPath(rimPath, clayOutline);

    // 3. Draw Water inside using clipping to keep within Matka boundaries
    canvas.save();
    canvas.clipPath(matkaPath);

    if (waterPercentage > 0.0) {
      // Calculate water depth
      final double waterHeight = h * 0.92 * (1.0 - waterPercentage);
      final double actualWaterLevel = waterHeight.clamp(h * 0.15, h * 0.92);

      final waterPath = Path();
      waterPath.moveTo(0, h);
      waterPath.lineTo(w, h);
      waterPath.lineTo(w, actualWaterLevel);

      // Waves animation using sine curve
      for (double x = w; x >= 0; x -= 2) {
        final double waveHeight = 4.0 * sin((waveValue * 2 * pi) + (x / 12.0));
        waterPath.lineTo(x, actualWaterLevel + waveHeight);
      }
      waterPath.close();

      canvas.drawPath(waterPath, waterPaint);

      // Add simple bubbles or details inside water
      if (waterPercentage > 0.3) {
        final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
        canvas.drawCircle(Offset(w * 0.3, h * 0.75), 2.5, bubblePaint);
        canvas.drawCircle(Offset(w * 0.7, h * 0.65), 1.5, bubblePaint);
        canvas.drawCircle(Offset(w * 0.55, h * 0.8), 3.0, bubblePaint);
      }
    }

    // 4. Draw glossy 3D clay pot details / reflection gloss
    final glossPath = Path()
      ..moveTo(w * 0.15, h * 0.4)
      ..quadraticBezierTo(w * 0.18, h * 0.6, w * 0.25, h * 0.75)
      ..quadraticBezierTo(w * 0.21, h * 0.6, w * 0.18, h * 0.4);
    canvas.drawPath(glossPath, highlightPaint);

    canvas.restore();

    // 5. Draw Earthen Matka Outline
    canvas.drawPath(matkaPath, clayOutline);

    // Draw clay decorative thread/bands on neck
    final neckBand = Path()
      ..moveTo(w * 0.3, h * 0.18)
      ..quadraticBezierTo(w * 0.5, h * 0.22, w * 0.7, h * 0.18);
    canvas.drawPath(neckBand, clayOutline);
  }

  @override
  bool shouldRepaint(covariant MatkaWaterPainter oldDelegate) {
    return oldDelegate.waterPercentage != waterPercentage ||
        oldDelegate.waveValue != waveValue;
  }
}
