import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class GroceryPlannerScreen extends StatefulWidget {
  const GroceryPlannerScreen({Key? key}) : super(key: key);

  @override
  State<GroceryPlannerScreen> createState() => _GroceryPlannerScreenState();
}

class _GroceryPlannerScreenState extends State<GroceryPlannerScreen> {
  double _targetProtein = 80.0; // Default protein goal

  Map<String, dynamic> _calculateGrocery(double target) {
    // Starting minimum quantities for a balanced nutrition base
    double eggQty = 1.0;     // pcs (6g P, cost ₹6)
    double dahiQty = 200.0;   // grams (7g P, cost ₹12)
    double peanutQty = 30.0;  // grams (7.5g P, cost ₹3.6)
    double chanaQty = 30.0;   // grams (6.6g P, cost ₹2.7)
    double soyaQty = 20.0;    // grams (10.4g P, cost ₹2)
    double sattuQty = 30.0;   // grams (6g P, cost ₹2.4)

    double currentProtein = (eggQty * 6.0) +
        (dahiQty * 0.035) +
        (peanutQty * 0.25) +
        (chanaQty * 0.22) +
        (soyaQty * 0.52) +
        (sattuQty * 0.20);

    double remaining = target - currentProtein;

    // Fill using cheapest proteins
    if (remaining > 0) {
      double addSoya = min(60.0, remaining / 0.52);
      soyaQty += addSoya;
      remaining -= addSoya * 0.52;
    }
    if (remaining > 0) {
      double addSattu = min(70.0, remaining / 0.20);
      sattuQty += addSattu;
      remaining -= addSattu * 0.20;
    }
    if (remaining > 0) {
      double addEggs = min(5.0, remaining / 6.0);
      eggQty += addEggs;
      remaining -= addEggs * 6.0;
    }
    if (remaining > 0) {
      double addPeanuts = min(40.0, remaining / 0.25);
      peanutQty += addPeanuts;
      remaining -= addPeanuts * 0.25;
    }
    if (remaining > 0) {
      double addChana = min(40.0, remaining / 0.22);
      chanaQty += addChana;
      remaining -= addChana * 0.22;
    }

    // Costs
    double eggCost = eggQty * 6.0;
    double dahiCost = (dahiQty / 1000.0) * 60.0; // ₹60/kg
    double peanutCost = (peanutQty / 1000.0) * 120.0; // ₹120/kg
    double chanaCost = (chanaQty / 1000.0) * 90.0; // ₹90/kg
    double soyaCost = (soyaQty / 1000.0) * 100.0; // ₹100/kg
    double sattuCost = (sattuQty / 1000.0) * 80.0; // ₹80/kg

    double dailyCost = eggCost + dahiCost + peanutCost + chanaCost + soyaCost + sattuCost;
    double actualProtein = (eggQty * 6.0) +
        (dahiQty * 0.035) +
        (peanutQty * 0.25) +
        (chanaQty * 0.22) +
        (soyaQty * 0.52) +
        (sattuQty * 0.20);

    return {
      'eggQty': eggQty,
      'dahiQty': dahiQty,
      'peanutQty': peanutQty,
      'chanaQty': chanaQty,
      'soyaQty': soyaQty,
      'sattuQty': sattuQty,
      'dailyCost': dailyCost,
      'actualProtein': actualProtein,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final data = _calculateGrocery(_targetProtein);

    final double dailyCost = data['dailyCost'];
    final double weeklyCost = dailyCost * 7;
    final double actualProtein = data['actualProtein'];
    final double efficiency = dailyCost > 0 ? (actualProtein / dailyCost) : 0.0;

    // Hinglish status rating
    String efficiencyRating = 'Normal';
    if (efficiency >= 1.6) {
      efficiencyRating = 'Sasta Level: Bahut Tej! 🚀';
    } else if (efficiency >= 1.2) {
      efficiencyRating = 'Sasta Level: Sahi Hai 👍';
    } else {
      efficiencyRating = 'Sasta Level: Theek-Thak 🤝';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          state.translate('Sasta Grocery & Budget Planner'),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.primaryContainer,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target selector slider card
            Card(
              color: AppColors.surfaceContainerLowest,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.translate('Daily Protein Target'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        Text(
                          '${_targetProtein.toInt()} g',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _targetProtein,
                      min: 50,
                      max: 150,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey[200],
                      onChanged: (val) {
                        setState(() {
                          _targetProtein = val;
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.translate('Adjust slider to calculate optimal raw shopping list'),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Efficiency Dial & Summary Box
            Row(
              children: [
                // Custom painted cost efficiency dial
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _SastaEfficiencyDialPainter(score: efficiency),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: AppColors.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate(efficiencyRating),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${state.translate('Est. Daily Cost')}: ₹${dailyCost.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '${state.translate('Est. Weekly Cost')}: ₹${weeklyCost.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${efficiency.toStringAsFixed(2)}g protein per rupee',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weekly Shopping List Card
            Card(
              color: AppColors.surfaceContainerLowest,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.translate('Weekly Raw Shopping List'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const Icon(Icons.shopping_cart, color: Colors.grey, size: 20),
                      ],
                    ),
                    const Divider(height: 24),

                    _buildGroceryRow(state, 'Whole Eggs', '${(data['eggQty'] * 7).toInt()} pcs', '₹${(data['eggQty'] * 7 * 6).toInt()}', 'High bioavailability protein source'),
                    _buildGroceryRow(state, 'Sattu Powder', '${(data['sattuQty'] * 7).toInt()} g', '₹${((data['sattuQty'] * 7 / 1000) * 80).toStringAsFixed(1)}', 'Desi pre/post workout energy drink'),
                    _buildGroceryRow(state, 'Soya Chunks', '${(data['soyaQty'] * 7).toInt()} g', '₹${((data['soyaQty'] * 7 / 1000) * 100).toStringAsFixed(1)}', 'Ultra-cheap vegan protein beast'),
                    _buildGroceryRow(state, 'Peanuts (Raw)', '${(data['peanutQty'] * 7).toInt()} g', '₹${((data['peanutQty'] * 7 / 1000) * 120).toStringAsFixed(1)}', 'Clean source of healthy fats & protein'),
                    _buildGroceryRow(state, 'Dahi / Curd', '${(data['dahiQty'] * 7).toInt()} g', '₹${((data['dahiQty'] * 7 / 1000) * 60).toStringAsFixed(1)}', 'Gut friendly digestives & calcium'),
                    _buildGroceryRow(state, 'Roasted Chana', '${(data['chanaQty'] * 7).toInt()} g', '₹${((data['chanaQty'] * 7 / 1000) * 90).toStringAsFixed(1)}', 'Study snack slow-digesting protein'),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        state.setLimits(state.dailyBudgetLimit, _targetProtein);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Synced! Daily Protein Goal updated to ${_targetProtein.toInt()}g',
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'SYNC TO DAILY METRICS TARGET',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroceryRow(AppState state, String name, String qty, String cost, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate(name),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    qty,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cost,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            state.translate(tip),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _SastaEfficiencyDialPainter extends CustomPainter {
  final double score;

  _SastaEfficiencyDialPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = min(w / 2, h / 2) - 8;

    // Score is typically between 0.5 and 2.5 (grams of protein per Rupee)
    // Let's normalize it to sweep angle (from 0 to 180 degrees)
    // 0.5g/₹ -> 0% efficiency rating (start)
    // 2.0g/₹ -> 100% efficiency rating (legendary end)
    final double normalized = ((score - 0.5) / 1.5).clamp(0.0, 1.0);

    // Paints
    final backgroundArcPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final scoreArcPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.orange.shade700,
          Colors.green.shade600,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw background half arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundArcPaint,
    );

    // Draw filled score arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * normalized,
      false,
      scoreArcPaint,
    );

    // Draw score text in center
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: score >= 1.4 ? Colors.green[700] : Colors.orange[800],
        fontFamily: 'Plus Jakarta Sans',
      ),
      text: '${score.toStringAsFixed(2)} P/₹',
    );

    textPainter.text = span;
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 3),
    );

    // Label under score
    final subPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final subSpan = TextSpan(
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
      text: 'SASTA RATING',
    );
    subPainter.text = subSpan;
    subPainter.layout();
    subPainter.paint(
      canvas,
      Offset(center.dx - subPainter.width / 2, center.dy + textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SastaEfficiencyDialPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
