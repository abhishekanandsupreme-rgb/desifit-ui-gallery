import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class AkhadaSandboxScreen extends StatefulWidget {
  const AkhadaSandboxScreen({super.key});

  @override
  State<AkhadaSandboxScreen> createState() => _AkhadaSandboxScreenState();
}

class _AkhadaSandboxScreenState extends State<AkhadaSandboxScreen>
    with TickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  late AnimationController _dholController;
  bool _isPlayingBeats = false;

  // Sandbox weights options
  final List<Map<String, dynamic>> _equipments = [
    {
      'name': 'Sattu Shaker',
      'weightKg': 1.0,
      'emoji': '🌾',
      'desc': 'Hostel shaker cup filled with thick sattu fuel.',
      'rank': 'Sattu Shishya',
      'color': Colors.amber,
    },
    {
      'name': 'Clay Matka',
      'weightKg': 10.0,
      'emoji': '🏺',
      'desc': 'Earthen clay water pot. Good for front carries and overhead lifts.',
      'rank': 'Ghat Malla',
      'color': const Color(0xFFD27D56),
    },
    {
      'name': 'Mud Mugdar',
      'weightKg': 20.0,
      'emoji': '💪',
      'desc': 'Traditional wooden club built from cement & soil. Swings enhance shoulder flexibility.',
      'rank': 'Mugdar Malla',
      'color': Colors.brown,
    },
    {
      'name': 'Iron Gada',
      'weightKg': 40.0,
      'emoji': '👑',
      'desc': 'Lord Hanuman\'s mace. Heavy round stone on a bamboo pole. Reclaims raw warrior posture.',
      'rank': 'Akhada Samrat',
      'color': Colors.orange,
    },
  ];

  int _selectedEquipmentIdx = 2; // Default: Mugdar
  int _completedSwingsCount = 0;

  @override
  void initState() {
    super.initState();
    // Swing rotation animation setup
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Double 360 swing rotation back and forth
    _swingAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOutBack),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _completedSwingsCount++;
          });
          _swingController.reset();
        }
      });

    // Dhol beat pulsation controller
    _dholController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _swingController.dispose();
    _dholController.dispose();
    super.dispose();
  }

  void _triggerGadaSwing() {
    if (!_swingController.isAnimating) {
      _swingController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final eq = _equipments[_selectedEquipmentIdx];
    final double userWeight = state.userWeight ?? 70.0;
    final double protein = state.proteinHit;

    // Calculate Pahlwan Warrior Score
    // Formula: (Protein * 1.5) + (Equipped Weight * 3) + (User Weight * 0.5)
    final double pahlwanScore = (protein * 1.5) + (eq['weightKg'] * 3.0) + (userWeight * 0.5);

    // Dynamic warning if protein is low
    final bool lowFuel = protein < 30.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          state.translate('Hostel Akhada Sandbox'),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.primaryContainer,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Card
            _buildIntroductionCard(state),
            const SizedBox(height: 20),

            // Pahlwan Rank Status Badge
            _buildWarriorBadgeCard(state, eq, pahlwanScore, lowFuel),
            const SizedBox(height: 20),

            // Interactive Gym Sandbox Display Panel
            Card(
              color: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      state.translate('Interactive Swing Area'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.translate('Tap equipment to swing and train shoulder flexibility'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // interactive custom painter area
                    GestureDetector(
                      onTap: _triggerGadaSwing,
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // pulsing dhol beat ripple circles
                            if (_isPlayingBeats)
                              AnimatedBuilder(
                                animation: _dholController,
                                builder: (context, child) {
                                  final double val = _dholController.value;
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 130 + (80 * val),
                                        height: 130 + (80 * val),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary.withValues(alpha: 1.0 - val),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 80 + (50 * val),
                                        height: 80 + (50 * val),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.secondary.withValues(alpha: 1.0 - val),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                            // Earthen wrestling ground background circle
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  eq['emoji'],
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),

                            // rotating equipment custom painter
                            AnimatedBuilder(
                              animation: _swingAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _swingAnimation.value,
                                  child: CustomPaint(
                                    size: const Size(120, 200),
                                    painter: AkhadaEquipmentPainter(
                                      type: eq['name'],
                                      color: eq['color'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // swing counter and training sound beats button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.translate('Swings completed'),
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_completedSwingsCount Reps',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isPlayingBeats = !_isPlayingBeats;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPlayingBeats ? AppColors.secondary : AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: Icon(
                            _isPlayingBeats ? Icons.volume_up : Icons.music_note,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            _isPlayingBeats
                                ? state.translate('STOP DHOL BEAT')
                                : state.translate('PLAY DHOL BEAT'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Equipment Selector Grid
            Text(
              state.translate('CHOOSE YOUR EQUIPMENTS'),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _equipments.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, idx) {
                final item = _equipments[idx];
                final isSelected = idx == _selectedEquipmentIdx;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEquipmentIdx = idx;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item['color'].withValues(alpha: 0.08)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? item['color'] : AppColors.outlineVariant.withValues(alpha: 0.2),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['emoji'], style: const TextStyle(fontSize: 22)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item['color'].withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item['weightKg'].toInt()} kg',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? item['color'] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.translate(item['name']),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? item['color'] : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.translate(item['rank']),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard(AppState state) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.translate('🔥 HOSTEL HACK'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.translate('Akhada Equipment Sandbox'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Plus Jakarta Sans',
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.translate(
                      'Build high-performance joints and raw wrestling strength inside your dorm. Equip custom clay and wood tools to calculate your warrior ranking score.'
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarriorBadgeCard(
      AppState state, Map<String, dynamic> eq, double score, bool lowFuel) {
    return Card(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: eq['color'].withValues(alpha: 0.12),
                  radius: 28,
                  child: Text(eq['emoji'], style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate('PAHALWAN RANKING'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.translate(eq['rank']),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: eq['color'],
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.toInt()} Pts',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.translate(eq['desc']),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3),
                  ),
                ),
              ],
            ),
            if (lowFuel) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.translate(
                          '"Bhai, daily protein counter is low. Fuel up with sattu or boiled eggs to maximize your Akhada score!"'
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AkhadaEquipmentPainter extends CustomPainter {
  final String type;
  final Color color;

  AkhadaEquipmentPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final linePaint = Paint()
      ..color = const Color(0xFF6B4C35) // Wooden handle color
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    if (type.contains('Gada')) {
      // Draw Bamboo handle
      canvas.drawLine(Offset(w / 2, h * 0.95), Offset(w / 2, h * 0.25), linePaint);
      
      // Draw handle wraps (grips)
      final gripPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 6.0;
      canvas.drawLine(Offset(w / 2, h * 0.95), Offset(w / 2, h * 0.75), gripPaint);

      // Draw Lord Hanuman's Gada Head (Golden Mace)
      final headCenter = Offset(w / 2, h * 0.25);
      const radius = 32.0;
      canvas.drawCircle(headCenter, radius, headPaint);

      // Draw spiked metallic bands (horizontal/vertical arcs)
      final bandPaint = Paint()
        ..color = const Color(0xFFD2B48C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawArc(
        Rect.fromCircle(center: headCenter, radius: radius - 2),
        0,
        pi,
        false,
        bandPaint,
      );

      // Draw mace top spike
      final spikePath = Path()
        ..moveTo(w / 2 - 8, h * 0.25 - radius)
        ..lineTo(w / 2, h * 0.25 - radius - 15)
        ..lineTo(w / 2 + 8, h * 0.25 - radius)
        ..close();
      canvas.drawPath(spikePath, headPaint);
      canvas.drawPath(spikePath, outlinePaint);

      // Draw head outline
      canvas.drawCircle(headCenter, radius, outlinePaint);

      // Draw shine
      canvas.drawCircle(Offset(w / 2 - 10, h * 0.25 - 10), 8.0, glossPaint);
    } else if (type.contains('Mugdar')) {
      // Mugdar is a cylindrical wooden bat
      // Draw handle grip
      canvas.drawLine(Offset(w / 2, h * 0.95), Offset(w / 2, h * 0.65), linePaint);

      // Draw bloated cylinder head
      final headPath = Path()
        ..moveTo(w * 0.35, h * 0.65)
        ..lineTo(w * 0.25, h * 0.2) // Flaring outwards
        ..quadraticBezierTo(w * 0.5, h * 0.12, w * 0.75, h * 0.2) // Rounded top
        ..lineTo(w * 0.65, h * 0.65)
        ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.35, h * 0.65) // Rounded bottom neck
        ..close();

      canvas.drawPath(headPath, headPaint);
      canvas.drawPath(headPath, outlinePaint);

      // Draw wood ring detail lines
      final ringPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(w * 0.3, h * 0.45), Offset(w * 0.7, h * 0.45), ringPaint);
      canvas.drawLine(Offset(w * 0.28, h * 0.3), Offset(w * 0.72, h * 0.3), ringPaint);

      // Draw gloss reflection
      final glossPath = Path()
        ..moveTo(w * 0.32, h * 0.35)
        ..lineTo(w * 0.3, h * 0.25)
        ..quadraticBezierTo(w * 0.35, h * 0.22, w * 0.4, h * 0.25)
        ..lineTo(w * 0.36, h * 0.35)
        ..close();
      canvas.drawPath(glossPath, glossPaint);
    } else if (type.contains('Matka')) {
      // Earthen pot drawing
      // Draw neck
      final neckPath = Path()
        ..moveTo(w * 0.4, h * 0.75)
        ..lineTo(w * 0.3, h * 0.4)
        ..quadraticBezierTo(w * 0.5, h * 0.35, w * 0.7, h * 0.4)
        ..lineTo(w * 0.6, h * 0.75)
        ..close();
      canvas.drawPath(neckPath, headPaint);
      canvas.drawPath(neckPath, outlinePaint);

      // Bloated body
      final potBody = Path()
        ..moveTo(w * 0.3, h * 0.4)
        ..cubicTo(w * 0.1, h * 0.45, w * 0.1, h * 0.85, w * 0.5, h * 0.95)
        ..cubicTo(w * 0.9, h * 0.85, w * 0.9, h * 0.45, w * 0.7, h * 0.4)
        ..close();
      canvas.drawPath(potBody, headPaint);
      canvas.drawPath(potBody, outlinePaint);
    } else {
      // Sattu shaker cup
      final shakerPath = Path()
        ..moveTo(w * 0.35, h * 0.8)
        ..lineTo(w * 0.3, h * 0.3) // Tapered body
        ..lineTo(w * 0.7, h * 0.3)
        ..lineTo(w * 0.65, h * 0.8)
        ..close();
      canvas.drawPath(shakerPath, headPaint);
      canvas.drawPath(shakerPath, outlinePaint);

      // Draw shaker lid cap
      final lidPaint = Paint()
        ..color = Colors.blueGrey
        ..style = PaintingStyle.fill;
      final lidPath = Path()
        ..moveTo(w * 0.28, h * 0.3)
        ..lineTo(w * 0.28, h * 0.23)
        ..lineTo(w * 0.72, h * 0.23)
        ..lineTo(w * 0.72, h * 0.3)
        ..close();
      canvas.drawPath(lidPath, lidPaint);
      canvas.drawPath(lidPath, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AkhadaEquipmentPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
