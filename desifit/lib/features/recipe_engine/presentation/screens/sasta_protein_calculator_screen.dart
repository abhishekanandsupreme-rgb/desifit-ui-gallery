import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/analytics_service.dart';

class StapleIngredient {
  final String id;
  final String name;
  final String hinglishName;
  final double proteinPer100g;
  final double costPer100g;
  final double caloriesPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double minVal;
  final double maxVal;
  final double step;
  final bool isNonVeg;
  final String unitName;

  const StapleIngredient({
    required this.id,
    required this.name,
    required this.hinglishName,
    required this.proteinPer100g,
    required this.costPer100g,
    required this.caloriesPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.minVal,
    required this.maxVal,
    required this.step,
    required this.isNonVeg,
    this.unitName = 'g',
  });
}

class SastaProteinCalculatorScreen extends StatefulWidget {
  const SastaProteinCalculatorScreen({super.key});

  @override
  State<SastaProteinCalculatorScreen> createState() => _SastaProteinCalculatorScreenState();
}

class _SastaProteinCalculatorScreenState extends State<SastaProteinCalculatorScreen> with SingleTickerProviderStateMixin {
  bool _isVegOnly = true;
  final Map<String, double> _quantities = {};

  static const List<StapleIngredient> _ingredients = [
    StapleIngredient(
      id: 'sattu',
      name: 'Sattu',
      hinglishName: 'Sasta Superfood',
      proteinPer100g: 20.0,
      costPer100g: 12.0,
      caloriesPer100g: 360.0,
      carbsPer100g: 58.0,
      fatPer100g: 5.0,
      minVal: 0.0,
      maxVal: 200.0,
      step: 10.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'soya',
      name: 'Soya Chunks',
      hinglishName: 'Protein Beast',
      proteinPer100g: 52.0,
      costPer100g: 15.0,
      caloriesPer100g: 345.0,
      carbsPer100g: 33.0,
      fatPer100g: 0.5,
      minVal: 0.0,
      maxVal: 150.0,
      step: 10.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'peanuts',
      name: 'Peanuts',
      hinglishName: 'Moongfali Power',
      proteinPer100g: 26.0,
      costPer100g: 14.0,
      caloriesPer100g: 567.0,
      carbsPer100g: 16.0,
      fatPer100g: 49.0,
      minVal: 0.0,
      maxVal: 100.0,
      step: 5.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'paneer',
      name: 'Paneer',
      hinglishName: 'Classic Gainz',
      proteinPer100g: 18.0,
      costPer100g: 45.0,
      caloriesPer100g: 265.0,
      carbsPer100g: 3.5,
      fatPer100g: 20.0,
      minVal: 0.0,
      maxVal: 250.0,
      step: 10.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'milk',
      name: 'Double Toned Milk',
      hinglishName: 'Glass of Strength',
      proteinPer100g: 3.3,
      costPer100g: 6.0,
      caloriesPer100g: 58.0,
      carbsPer100g: 4.8,
      fatPer100g: 1.5,
      minVal: 0.0,
      maxVal: 500.0,
      step: 50.0,
      isNonVeg: false,
      unitName: 'ml',
    ),
    StapleIngredient(
      id: 'curd',
      name: 'Curd (Dahi)',
      hinglishName: 'Cooling Digestion',
      proteinPer100g: 3.5,
      costPer100g: 6.0,
      caloriesPer100g: 60.0,
      carbsPer100g: 4.0,
      fatPer100g: 3.0,
      minVal: 0.0,
      maxVal: 300.0,
      step: 50.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'chana',
      name: 'Kabuli Chana',
      hinglishName: 'Boiled Chickpeas',
      proteinPer100g: 19.0,
      costPer100g: 10.0,
      caloriesPer100g: 360.0,
      carbsPer100g: 60.0,
      fatPer100g: 6.0,
      minVal: 0.0,
      maxVal: 200.0,
      step: 10.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'moong',
      name: 'Moong Dal',
      hinglishName: 'Sprouts / Lentils',
      proteinPer100g: 24.0,
      costPer100g: 11.0,
      caloriesPer100g: 348.0,
      carbsPer100g: 59.0,
      fatPer100g: 1.2,
      minVal: 0.0,
      maxVal: 150.0,
      step: 10.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'almonds',
      name: 'Almonds (Badam)',
      hinglishName: 'Brain & Recovery',
      proteinPer100g: 21.0,
      costPer100g: 90.0,
      caloriesPer100g: 579.0,
      carbsPer100g: 22.0,
      fatPer100g: 50.0,
      minVal: 0.0,
      maxVal: 50.0,
      step: 5.0,
      isNonVeg: false,
    ),
    StapleIngredient(
      id: 'whey',
      name: 'Whey Protein',
      hinglishName: 'Supplement Scoop',
      proteinPer100g: 75.0, // 25g per 33g scoop
      costPer100g: 363.0,  // ~₹120 per scoop
      caloriesPer100g: 363.0,
      carbsPer100g: 9.0,
      fatPer100g: 4.5,
      minVal: 0.0,
      maxVal: 66.0, // max 2 scoops
      step: 33.0,
      isNonVeg: false,
    ),
    // Non-Veg Section
    StapleIngredient(
      id: 'eggs',
      name: 'Boiled Eggs',
      hinglishName: 'Anda Power',
      proteinPer100g: 12.0, // 6g per egg (1 egg ~50g)
      costPer100g: 20.0,   // ₹10 per egg
      caloriesPer100g: 156.0, // 78 kcal per egg
      carbsPer100g: 1.0,
      fatPer100g: 10.0,
      minVal: 0.0,
      maxVal: 6.0,
      step: 1.0,
      isNonVeg: true,
      unitName: 'pc',
    ),
    StapleIngredient(
      id: 'chicken',
      name: 'Chicken Breast',
      hinglishName: 'Murga Lean Gainz',
      proteinPer100g: 31.0,
      costPer100g: 28.0,
      caloriesPer100g: 165.0,
      carbsPer100g: 0.0,
      fatPer100g: 3.6,
      minVal: 0.0,
      maxVal: 300.0,
      step: 25.0,
      isNonVeg: true,
    ),
    StapleIngredient(
      id: 'fish',
      name: 'Fish (Machhli)',
      hinglishName: 'Omega-3 Booster',
      proteinPer100g: 20.0,
      costPer100g: 35.0,
      caloriesPer100g: 110.0,
      carbsPer100g: 0.0,
      fatPer100g: 3.0,
      minVal: 0.0,
      maxVal: 200.0,
      step: 25.0,
      isNonVeg: true,
    ),
    StapleIngredient(
      id: 'keema',
      name: 'Mutton Keema',
      hinglishName: 'Red Meat Fuel',
      proteinPer100g: 20.0,
      costPer100g: 70.0,
      caloriesPer100g: 250.0,
      carbsPer100g: 0.0,
      fatPer100g: 18.0,
      minVal: 0.0,
      maxVal: 200.0,
      step: 25.0,
      isNonVeg: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize all quantities to 0
    for (var ing in _ingredients) {
      _quantities[ing.id] = 0.0;
    }
    AnalyticsService.logEvent('screen_view', {'screen_name': 'sasta_protein_calculator'});
  }

  void _resetSliders() {
    setState(() {
      for (var key in _quantities.keys) {
        _quantities[key] = 0.0;
      }
    });
  }

  void _onCategoryChanged(bool isVegOnly) {
    setState(() {
      _isVegOnly = isVegOnly;
      if (_isVegOnly) {
        // Set all non-veg items to 0
        for (var ing in _ingredients) {
          if (ing.isNonVeg) {
            _quantities[ing.id] = 0.0;
          }
        }
      }
    });
    AnalyticsService.logEvent('calculator_diet_type_toggled', {'veg_only': isVegOnly});
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Calculations
    double totalProtein = 0.0;
    double totalCost = 0.0;
    double totalCalories = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (var ing in _ingredients) {
      final qty = _quantities[ing.id] ?? 0.0;
      if (qty > 0) {
        double multiplier = ing.unitName == 'pc' ? qty : (qty / 100.0);
        totalProtein += ing.proteinPer100g * multiplier;
        totalCost += ing.costPer100g * multiplier;
        totalCalories += ing.caloriesPer100g * multiplier;
        totalCarbs += ing.carbsPer100g * multiplier;
        totalFat += ing.fatPer100g * multiplier;
      }
    }

    double costPerGram = totalProtein > 0 ? (totalCost / totalProtein) : 0.0;

    // Sasta Score calculation (1.0 to 10.0 scale)
    // Cost per gram of protein: Soya chunks ~₹0.29/g (ultra cheap), Sattu ~₹0.60/g, Paneer ~₹2.50/g
    // If costPerGram <= ₹0.35 -> Score is 10.0
    // If costPerGram >= ₹2.50 -> Score is 1.0
    double sastaScore = 1.0;
    if (totalProtein > 0) {
      sastaScore = (10.0 - (costPerGram - 0.35) * 4.0).clamp(1.0, 10.0);
    }

    // Filter ingredients list based on Veg Only toggle
    final visibleIngredients = _ingredients.where((ing) => !_isVegOnly || !ing.isNonVeg).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          Provider.of<AppState>(context).translate('Sasta Protein Meter'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _resetSliders,
            tooltip: 'Reset Calculator',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TOP METER & METRICS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // VEG / NON-VEG SLOTS SELECTOR
                      _buildDietTypeSelector(),
                      const SizedBox(height: 16),
                      
                      // Dial and Cost statistics row
                      Row(
                        children: [
                          // Efficiency Dial Gauge
                          SizedBox(
                            width: 130,
                            height: 90,
                            child: CustomPaint(
                              painter: _SastaScoreDialPainter(
                                score: totalProtein > 0 ? sastaScore : 0.0,
                                primaryColor: AppColors.primary,
                                secondaryColor: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Key Costs Text Box
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  totalProtein > 0 ? _getSastaLabel(sastaScore) : 'Add protein inputs below',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: totalProtein > 0 ? _getSastaColor(sastaScore) : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text('Efficiency: ', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                    Text(
                                      totalProtein > 0 ? '₹${costPerGram.toStringAsFixed(2)}/g' : '₹0.00/g',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalProtein > 0
                                      ? 'Cost per gram of protein'
                                      : 'Use sliders to calculate diet budget',
                                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Metrics Cards Grid
                      Row(
                        children: [
                          _buildMetricItem('Protein', '${totalProtein.toStringAsFixed(1)}g', Icons.fitness_center),
                          const SizedBox(width: 8),
                          _buildMetricItem('Total Cost', '₹${totalCost.toStringAsFixed(1)}', Icons.payments),
                          const SizedBox(width: 8),
                          _buildMetricItem('Calories', '${totalCalories.toStringAsFixed(0)} kcal', Icons.local_fire_department),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // COACH BHEEM'S ADVICE BUBBLE
            if (totalProtein > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: _buildBheemAdvice(totalProtein, totalCost, totalCalories),
              ),

            // SCROLLABLE LIST OF STAPLES
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: visibleIngredients.length,
                itemBuilder: (context, index) {
                  final ing = visibleIngredients[index];
                  final qty = _quantities[ing.id] ?? 0.0;
                  return _buildIngredientCard(ing, qty);
                },
              ),
            ),

            // BOTTOM ACTION BAR
            _buildBottomActionBar(context, totalProtein, totalCost, totalCalories, totalCarbs, totalFat),
          ],
        ),
      ),
    );
  }

  Widget _buildDietTypeSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                selected: _isVegOnly,
                label: 'Veg Only diet',
                child: GestureDetector(
                onTap: () => _onCategoryChanged(true),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isVegOnly ? AppColors.surfaceContainerLowest : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: _isVegOnly
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green.shade600,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Veg Only',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ),
            Expanded(
              child: Semantics(
                button: true,
                selected: !_isVegOnly,
                label: 'Include Non-Veg diet',
                child: GestureDetector(
                onTap: () => _onCategoryChanged(false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isVegOnly ? AppColors.surfaceContainerLowest : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: !_isVegOnly
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.red.shade600,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Include Non-Veg',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
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
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBheemAdvice(double protein, double cost, double calories) {
    // Dynamic dialog advice from Bheem
    String adviceText = "Sattu aur soya chunks best combos hain, tabhi protein solid milega, Bhai!";

    double maxQty = 0;
    String dominantIng = '';

    for (var entry in _quantities.entries) {
      if (entry.value > maxQty) {
        maxQty = entry.value;
        dominantIng = entry.key;
      }
    }

    if (dominantIng == 'soya' && maxQty > 40) {
      adviceText = "Soya chunks ko boil karke pani nichod dena, Bhai! Smell chali jayegi aur protein ekdum mast digest hoga.";
    } else if (dominantIng == 'sattu' && maxQty > 50) {
      adviceText = "Sattu drink me thoda namak, nimbu aur jeera powder dalo, college classes ke beech solid energy dega!";
    } else if (dominantIng == 'eggs' && maxQty >= 3) {
      adviceText = "Anda (boiled) classic mass builder hai! Pura yellow mat khana agar weight control me rakhna hai.";
    } else if (dominantIng == 'chicken' && maxQty > 100) {
      adviceText = "Lean chicken breast se fat-free recovery milegi. Par sath me salad aur curd zaroor khana, digestion clear rahega!";
    } else if (dominantIng == 'whey' && maxQty >= 33) {
      adviceText = "Whey protein heavy weapon hai scope aur recovery ke liye. Budget allow kare tabhi chalana, nahi to Soya chunks zindabad!";
    } else if (dominantIng == 'paneer' && maxQty > 100) {
      adviceText = "Paneer me badhiya fat aur casein protein hota hai. Thoda costly hai, but weight gainz ke liye best hai!";
    } else if (protein > 50 && (cost / protein) < 0.6) {
      adviceText = "Maza aa gaya! Mast sasta aur powerful protein blend banaya hai tune. Haddi lohe jaisi majboot banegi, Bhai!";
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=100',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coach Bheem Bhasin',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 3),
                Text(
                  '"$adviceText"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurface),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIngredientCard(StapleIngredient ing, double qty) {
    double currentProtein = qty * (ing.proteinPer100g / (ing.unitName == 'pc' ? 1.0 : 100.0));
    double currentCost = qty * (ing.costPer100g / (ing.unitName == 'pc' ? 1.0 : 100.0));

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon and Names
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ing.isNonVeg
                              ? Colors.red.shade50.withValues(alpha: 0.6)
                              : Colors.green.shade50.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ing.isNonVeg ? Icons.kebab_dining : Icons.grass,
                          size: 18,
                          color: ing.isNonVeg ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ing.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                            ),
                            Text(
                              ing.hinglishName,
                              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                // Active Quantity text box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: qty > 0 ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${qty.toStringAsFixed(0)} ${ing.unitName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: qty > 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            
            // Slider with precise buttons
            Row(
              children: [
                IconButton(
                  tooltip: 'Decrease quantity',
                  onPressed: () {
                    if (qty > ing.minVal) {
                      setState(() {
                        _quantities[ing.id] = (qty - ing.step).clamp(ing.minVal, ing.maxVal);
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: qty > 0 ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.12),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      value: qty,
                      min: ing.minVal,
                      max: ing.maxVal,
                      divisions: ing.maxVal > 0 ? (ing.maxVal - ing.minVal) ~/ ing.step : 1,
                      onChanged: (val) {
                        setState(() {
                          _quantities[ing.id] = val;
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Increase quantity',
                  onPressed: () {
                    if (qty < ing.maxVal) {
                      setState(() {
                        _quantities[ing.id] = (qty + ing.step).clamp(ing.minVal, ing.maxVal);
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            // Individual metrics breakdown
            if (qty > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 32, right: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Protein: ${currentProtein.toStringAsFixed(1)}g',
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Cost: ₹${currentCost.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Calories: ${(qty * (ing.caloriesPer100g / (ing.unitName == 'pc' ? 1.0 : 100.0))).toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    double protein,
    double cost,
    double calories,
    double carbs,
    double fat,
  ) {
    final bool hasSelection = protein > 0;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: hasSelection
                  ? () => _showLogPickerSheet(context, protein, cost, calories, carbs, fat)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                disabledForegroundColor: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_task),
                  SizedBox(width: 12),
                  Text(
                    'Log Custom Mix',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogPickerSheet(
    BuildContext context,
    double protein,
    double cost,
    double calories,
    double carbs,
    double fat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Log Custom Mix to Diet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a meal slot to add these protein inputs:',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Meal Slots Grid
              Row(
                children: [
                  _buildSlotButton(sheetContext, 'Breakfast', Icons.wb_sunny, protein, cost, calories, carbs, fat),
                  const SizedBox(width: 12),
                  _buildSlotButton(sheetContext, 'Lunch', Icons.light_mode, protein, cost, calories, carbs, fat),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSlotButton(sheetContext, 'Dinner', Icons.nights_stay, protein, cost, calories, carbs, fat),
                  const SizedBox(width: 12),
                  _buildSlotButton(sheetContext, 'Snack', Icons.cookie, protein, cost, calories, carbs, fat),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotButton(
    BuildContext sheetContext,
    String slot,
    IconData icon,
    double protein,
    double cost,
    double calories,
    double carbs,
    double fat,
  ) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          final appState = Provider.of<AppState>(context, listen: false);
          
          // Determine if veg or non-veg custom mix
          bool hasNonVeg = false;
          for (var ing in _ingredients) {
            final qty = _quantities[ing.id] ?? 0;
            if (ing.isNonVeg && qty > 0) {
              hasNonVeg = true;
              break;
            }
          }

          final String tag = hasNonVeg ? '[NON-VEG] Sasta Mix' : '[VEG] Sasta Mix';
          
          // Log meal with macros
          appState.addFoodWithCalories(
            tag,
            slot,
            cost,
            protein,
            calories,
            carbs,
            fat,
          );

          Navigator.pop(sheetContext); // Close sheet
          
          // Show Toast/Snackbar confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully logged custom $tag to $slot!'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );

          // Reset quantities after logging
          _resetSliders();
          
          // Track telemetry event
          AnalyticsService.logEvent('calculator_logged_custom_mix', {
            'slot': slot,
            'is_non_veg': hasNonVeg,
            'protein_g': protein,
            'cost_inr': cost,
            'calories_kcal': calories,
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          foregroundColor: AppColors.onSurface,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(slot, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _getSastaLabel(double score) {
    if (score >= 9.0) return 'Sasta Level: Bahut Tej! 🚀';
    if (score >= 7.0) return 'Budget King: Badhiya! 👑';
    if (score >= 5.0) return 'Average: Theek-Thaak 😐';
    if (score >= 3.0) return 'Expensive: Thoda Mehanga! 💸';
    return 'Mehanga Padega! ⚠️';
  }

  Color _getSastaColor(double score) {
    if (score >= 7.0) return Colors.green.shade600;
    if (score >= 4.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

class _SastaScoreDialPainter extends CustomPainter {
  final double score; // 0.0 to 10.0
  final Color primaryColor;
  final Color secondaryColor;

  _SastaScoreDialPainter({
    required this.score,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, size.height - 10);

    // Draw background arc (gray half circle)
    final Paint bgPaint = Paint()
      ..color = AppColors.surfaceContainerHighest.withValues(alpha: 0.4)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      pi,
      pi,
      false,
      bgPaint,
    );

    if (score > 0) {
      // Draw active efficiency progress arc
      // Choose color based on sasta efficiency score
      Color arcColor = Colors.red.shade600;
      if (score >= 7.0) {
        arcColor = Colors.green.shade600;
      } else if (score >= 4.5) {
        arcColor = Colors.orange.shade600;
      }

      final Paint activePaint = Paint()
        ..color = arcColor
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      double sweepAngle = (score / 10.0) * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        pi,
        sweepAngle,
        false,
        activePaint,
      );

      // Draw needle / indicator dial
      final Paint needlePaint = Paint()
        ..color = AppColors.onSurface
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final Paint centerHubPaint = Paint()
        ..color = AppColors.onSurface
        ..style = PaintingStyle.fill;

      // Draw hub center circle
      canvas.drawCircle(center, 6, centerHubPaint);

      // Draw needle line pointing to the angle
      double needleAngle = pi + sweepAngle;
      double needleLength = radius - 18;
      double needleEndX = center.dx + needleLength * cos(needleAngle);
      double needleEndY = center.dy + needleLength * sin(needleAngle);

      canvas.drawLine(center, Offset(needleEndX, needleEndY), needlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SastaScoreDialPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
