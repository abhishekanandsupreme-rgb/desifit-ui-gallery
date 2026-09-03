import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/openrouter_service.dart';
import '../../../../core/ads/ad_service.dart';

class CalorieCounterScreen extends StatefulWidget {
  const CalorieCounterScreen({super.key});

  @override
  State<CalorieCounterScreen> createState() => _CalorieCounterScreenState();
}

class _CalorieCounterScreenState extends State<CalorieCounterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _aiController = TextEditingController();
  
  String _selectedSlot = 'Breakfast'; // Breakfast, Lunch, Dinner, Snack
  double _portionMultiplier = 1.0;
  FoodNutrition? _selectedFood;
  
  bool _isEstimatingAI = false;
  Map<String, dynamic>? _aiEstimatedNutrition;
  String? _aiErrorMessage;
  
  List<FoodNutrition> _searchResults = [];

  @override
  void initState() {
    super.initState();
    AdService.loadRewardedAd();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, AppState state) {
    setState(() {
      _searchResults = state.searchFoodDatabase(query);
    });
  }

  Future<void> _estimateCalorieWithAI() async {
    final foodDesc = _aiController.text.trim();
    if (foodDesc.isEmpty) return;

    final state = Provider.of<AppState>(context, listen: false);
    if (state.isAiCalorieLimitReached) {
      _showCalorieAdModal(context, state);
      return;
    }

    setState(() {
      _isEstimatingAI = true;
      _aiEstimatedNutrition = null;
      _aiErrorMessage = null;
    });

    try {
      final result = await OpenRouterService.estimateFoodCalories(foodDesc);
      if (result != null) {
        setState(() {
          _aiEstimatedNutrition = result;
        });
        state.incrementAiCalorieCount();
      } else {
        setState(() {
          _aiErrorMessage = "Couldn't estimate. Try typing simply (e.g., '1 Egg Roll').";
        });
      }
    } catch (e) {
      setState(() {
        _aiErrorMessage = "Error fetching estimate. Please try again.";
      });
    } finally {
      setState(() {
        _isEstimatingAI = false;
      });
    }
  }

  void _showCalorieAdModal(BuildContext context, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Unlock Calorie Estimator',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Watch a quick video to unlock 3 more custom calorie estimations with Coach Bheem's AI!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          AdService.showRewardedAd(
                            onUserEarnedReward: (reward) {
                              state.unlockAiCalorie();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Congratulations! 3 more AI calorie estimates unlocked!',
                                    style: TextStyle(fontFamily: 'Inter'),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            onAdDismissed: () {},
                          );
                        },
                        child: const Text(
                          'WATCH VIDEO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Back',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Desi Calorie Counter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
        ),
        body: Consumer<AppState>(
          builder: (context, state, child) {
            final now = DateTime.now();
            final todaysMeals = state.meals.where((m) {
              return m.timestamp.year == now.year &&
                  m.timestamp.month == now.month &&
                  m.timestamp.day == now.day;
            }).toList();

            final targetCalories = state.dailyCalorieTarget ?? 2000.0;
            final remainingCalories = state.caloriesRemaining;
            final consumedCalories = state.caloriesConsumed;

            // Macro details
            final targetProtein = state.proteinGoal;
            final consumedProtein = state.proteinHit;

            // Approximate Carb/Fat targets based on 50% Carb, 25% Fat, 25% Protein split
            final targetCarbs = (targetCalories * 0.50) / 4.0;
            final consumedCarbs = state.carbsConsumed;

            final targetFat = (targetCalories * 0.25) / 9.0;
            final consumedFat = state.fatConsumed;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.03),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.isGuest) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Guest Mode Active',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Your logged calories are saved locally but won\'t sync. Sign in with Google to track permanently!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await state.loginWithGoogle();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Login failed: $e')),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'SIGN IN',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Sattu Streak Display
                      if (state.sattuStreak > 0)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  'Streak: ${state.sattuStreak} ${state.sattuStreak == 1 ? 'Day' : 'Days'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Calorie Ring Gauge Card
                      _buildCalorieGaugeCard(
                        context: context,
                        target: targetCalories,
                        consumed: consumedCalories,
                        remaining: remainingCalories,
                      ),
                      const SizedBox(height: 20),

                      // Macro Progress Bars
                      _buildMacrosCard(
                        context: context,
                        targetProtein: targetProtein,
                        consumedProtein: consumedProtein,
                        targetCarbs: targetCarbs,
                        consumedCarbs: consumedCarbs,
                        targetFat: targetFat,
                        consumedFat: consumedFat,
                      ),
                      const SizedBox(height: 24),

                      // Log Food Title
                      Text(
                        'LOG YOUR MEALS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Meal Slot Segmented Control
                      _buildMealSlotSelector(),
                      const SizedBox(height: 16),

                      // Search Card
                      _buildSearchCard(context, state),
                      const SizedBox(height: 16),

                      // Quick Log Section
                      _buildQuickLogSection(context, state),
                      const SizedBox(height: 24),

                      // AI Estimation Section
                      _buildAIEstimationCard(context, state),
                      const SizedBox(height: 24),

                      // Today's Meals Section
                      Text(
                        'TODAY\'S LOGGED MEALS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 12),

                      _buildTodaysMealsList(context, state, todaysMeals),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalorieGaugeCard({
    required BuildContext context,
    required double target,
    required double consumed,
    required double remaining,
  }) {
    final double percent = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress ring
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100),
                ),
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        remaining.toInt().toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                              height: 1.1,
                            ),
                      ),
                      Text(
                        'kcal left',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Statistics
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCalorieStatRow(
                  context,
                  icon: Icons.flag_rounded,
                  iconColor: Colors.grey.shade600,
                  label: 'Target',
                  value: '${target.toInt()} kcal',
                ),
                const SizedBox(height: 12),
                _buildCalorieStatRow(
                  context,
                  icon: Icons.restaurant_rounded,
                  iconColor: AppColors.primary,
                  label: 'Consumed',
                  value: '${consumed.toInt()} kcal',
                ),
                const SizedBox(height: 12),
                _buildCalorieStatRow(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Status',
                  value: percent >= 1.0 ? 'Goal Hit! 🏆' : '${(percent * 100).toInt()}% Done',
                  valueColor: percent >= 1.0 ? AppColors.secondary : AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStatRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosCard({
    required BuildContext context,
    required double targetProtein,
    required double consumedProtein,
    required double targetCarbs,
    required double consumedCarbs,
    required double targetFat,
    required double consumedFat,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          // Protein
          _buildMacroProgressBar(
            context,
            label: 'Protein (Dum)',
            consumed: consumedProtein,
            target: targetProtein,
            unit: 'g',
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          // Carbs
          _buildMacroProgressBar(
            context,
            label: 'Carbohydrates',
            consumed: consumedCarbs,
            target: targetCarbs,
            unit: 'g',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 16),
          // Fat
          _buildMacroProgressBar(
            context,
            label: 'Fats',
            consumed: consumedFat,
            target: targetFat,
            unit: 'g',
            color: Colors.amber.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgressBar(
    BuildContext context, {
    required String label,
    required double consumed,
    required double target,
    required String unit,
    required Color color,
  }) {
    final double percent = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            Text(
              '${consumed.toInt()} / ${target.toInt()} $unit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSlotSelector() {
    final slots = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    return Row(
      children: slots.map((slot) {
        final isSelected = _selectedSlot == slot;
        return Expanded(
          child: Semantics(
            button: true,
            selected: isSelected,
            label: slot + (isSelected ? ' selected' : '. Select meal slot'),
            child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSlot = slot;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text field
          TextField(
            controller: _searchController,
            onChanged: (val) => _onSearchChanged(val, state),
            decoration: InputDecoration(
              hintText: 'Search 100+ Indian foods (Roti, Eggs, Sattu...)',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('', state);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
              ),
            ),
          ),

          // Search results
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final food = _searchResults[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${food.servingSize} • ${food.calories.toInt()} kcal • P: ${food.protein.toInt()}g',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    trailing: const Icon(Icons.add_circle, color: AppColors.secondary, size: 22),
                    onTap: () {
                      setState(() {
                        _selectedFood = food;
                        _portionMultiplier = 1.0;
                        _searchResults = [];
                        _searchController.text = food.name;
                      });
                    },
                  );
                },
              ),
            ),
          ],

          // Portion controls and log button if selected
          if (_selectedFood != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFood!.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Category: ${_selectedFood!.category} • Serving: ${_selectedFood!.servingSize}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove selected food',
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedFood = null;
                            _searchController.clear();
                          });
                        },
                      )
                    ],
                  ),
                  const Divider(height: 16),
                  // Portion multiplier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Portion Size:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Decrease portion',
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              if (_portionMultiplier > 0.25) {
                                setState(() {
                                  _portionMultiplier -= 0.25;
                                });
                              }
                            },
                          ),
                          Text(
                            '${_portionMultiplier.toStringAsFixed(2)}x',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          IconButton(
                            tooltip: 'Increase portion',
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                _portionMultiplier += 0.25;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  Slider(
                    value: _portionMultiplier,
                    min: 0.25,
                    max: 4.0,
                    divisions: 15,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (val) {
                      setState(() {
                        _portionMultiplier = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Current selection macros preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroPreview('Calories', '${(_selectedFood!.calories * _portionMultiplier).toInt()} kcal'),
                      _buildMacroPreview('Protein', '${(_selectedFood!.protein * _portionMultiplier).toStringAsFixed(1)}g'),
                      _buildMacroPreview('Carbs', '${(_selectedFood!.carbs * _portionMultiplier).toStringAsFixed(1)}g'),
                      _buildMacroPreview('Fat', '${(_selectedFood!.fat * _portionMultiplier).toStringAsFixed(1)}g'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Log Meal Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final name = '${_selectedFood!.name} (${_portionMultiplier.toStringAsFixed(2)}x)';
                      final double calories = _selectedFood!.calories * _portionMultiplier;
                      final double protein = _selectedFood!.protein * _portionMultiplier;
                      final double carbs = _selectedFood!.carbs * _portionMultiplier;
                      final double fat = _selectedFood!.fat * _portionMultiplier;
                      
                      // Hostel quick calculation: estimate cost based on database category averages or ₹0 if custom
                      double cost = 0.0;
                      if (_selectedFood!.category == 'Protein') {
                        cost = 15.0 * _portionMultiplier;
                      } else if (_selectedFood!.category == 'Dairy') {
                        cost = 12.0 * _portionMultiplier;
                      } else if (_selectedFood!.category == 'Grain') {
                        cost = 5.0 * _portionMultiplier;
                      } else if (_selectedFood!.category == 'Meal') {
                        cost = 30.0 * _portionMultiplier;
                      } else {
                        cost = 10.0 * _portionMultiplier;
                      }

                      state.addFoodWithCalories(
                        name,
                        _selectedSlot,
                        cost.roundToDouble(),
                        protein.roundToDouble(),
                        calories.roundToDouble(),
                        carbs.roundToDouble(),
                        fat.roundToDouble(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged: $name to $_selectedSlot!')),
                      );

                      setState(() {
                        _selectedFood = null;
                        _searchController.clear();
                      });
                    },
                    child: const Text('Add to Log', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroPreview(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildQuickLogSection(BuildContext context, AppState state) {
    final quickItems = [
      {'name': 'Roti/Chapati', 'cal': 120.0, 'pro': 3.5, 'carb': 20.0, 'fat': 3.5, 'cost': 3.0},
      {'name': 'Boiled Egg', 'cal': 78.0, 'pro': 6.0, 'carb': 0.5, 'fat': 5.0, 'cost': 6.0},
      {'name': 'Sattu Drink', 'cal': 120.0, 'pro': 7.0, 'carb': 18.0, 'fat': 2.0, 'cost': 5.0},
      {'name': 'Rice (cooked)', 'cal': 210.0, 'pro': 4.0, 'carb': 45.0, 'fat': 0.5, 'cost': 4.0},
      {'name': 'Dal Tadka', 'cal': 180.0, 'pro': 12.0, 'carb': 28.0, 'fat': 2.0, 'cost': 10.0},
      {'name': 'Soya Chunks', 'cal': 170.0, 'pro': 26.0, 'carb': 13.0, 'fat': 0.5, 'cost': 8.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Log presets (Single tap to log)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickItems.length,
            itemBuilder: (context, index) {
              final item = quickItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  elevation: 0,
                  pressElevation: 2,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2), width: 1.2),
                  ),
                  avatar: const Text('⚡', style: TextStyle(fontSize: 12)),
                  label: Text(
                    '${item['name']} (${(item['pro'] as num).toInt()}g Protein)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  onPressed: () {
                    state.addFoodWithCalories(
                      item['name'] as String,
                      _selectedSlot,
                      (item['cost'] as double).roundToDouble(),
                      (item['pro'] as double).roundToDouble(),
                      (item['cal'] as double).roundToDouble(),
                      (item['carb'] as double).roundToDouble(),
                      (item['fat'] as double).roundToDouble(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged ${item['name']} to $_selectedSlot!')),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReportCalorieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Report AI Calorie Estimate?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to report this AI calorie and macro estimation as inaccurate or misleading?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                debugPrint('AI Calorie estimate reported for: "${_aiController.text.trim()}"');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Thank you. Estimate reported for correction review.', style: TextStyle(fontFamily: 'Inter')),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: const Text('REPORT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIEstimationCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Coach Bheem Calorie Estimator',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Type custom meals or hostel creations to estimate calories/macros using Llama-3 AI.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aiController,
                  decoration: InputDecoration(
                    hintText: 'e.g., 2 egg rolls + half cup milk',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(80, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isEstimatingAI ? null : _estimateCalorieWithAI,
                child: _isEstimatingAI
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Ask AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          if (_aiErrorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _aiErrorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
          if (_aiEstimatedNutrition != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.12), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _aiEstimatedNutrition!['food_name'] ?? 'Estimated Item',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            Text(
                              'Portion: ${_aiEstimatedNutrition!['serving_size'] ?? '1 serving'}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 18),
                            tooltip: 'Report Inaccurate AI Estimate',
                            onPressed: () => _showReportCalorieDialog(context),
                          ),
                          IconButton(
                            tooltip: 'Dismiss AI estimate',
                            icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                            onPressed: () {
                              setState(() {
                                _aiEstimatedNutrition = null;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroPreview('Calories', '${(_aiEstimatedNutrition!['calories'] as num?)?.toInt() ?? 200} kcal'),
                      _buildMacroPreview('Protein', '${((_aiEstimatedNutrition!['protein_g'] ?? _aiEstimatedNutrition!['protein']) as num?)?.toStringAsFixed(1) ?? '8'}g'),
                      _buildMacroPreview('Carbs', '${((_aiEstimatedNutrition!['carbs_g'] ?? _aiEstimatedNutrition!['carbs']) as num?)?.toStringAsFixed(1) ?? '25'}g'),
                      _buildMacroPreview('Fat', '${((_aiEstimatedNutrition!['fat_g'] ?? _aiEstimatedNutrition!['fat']) as num?)?.toStringAsFixed(1) ?? '5'}g'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // AI Disclaimer Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2), width: 0.8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.orange, size: 12),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Warning: Values are AI-generated approximations. Verify if tracking precise medical diets.',
                            style: TextStyle(fontSize: 9, color: Colors.black54, fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final name = '${_aiEstimatedNutrition!['food_name'] ?? _aiController.text.trim()} (AI Estimate)';
                      final double calories = ((_aiEstimatedNutrition!['calories'] as num?)?.toDouble() ?? 200.0);
                      final double protein = (((_aiEstimatedNutrition!['protein_g'] ?? _aiEstimatedNutrition!['protein']) as num?)?.toDouble() ?? 8.0);
                      final double carbs = (((_aiEstimatedNutrition!['carbs_g'] ?? _aiEstimatedNutrition!['carbs']) as num?)?.toDouble() ?? 25.0);
                      final double fat = (((_aiEstimatedNutrition!['fat_g'] ?? _aiEstimatedNutrition!['fat']) as num?)?.toDouble() ?? 5.0);

                      state.addFoodWithCalories(
                        name,
                        _selectedSlot,
                        15.0, // Default moderate cost estimation
                        protein.roundToDouble(),
                        calories.roundToDouble(),
                        carbs.roundToDouble(),
                        fat.roundToDouble(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged AI Estimate: $name!')),
                      );

                      setState(() {
                        _aiEstimatedNutrition = null;
                        _aiController.clear();
                      });
                    },
                    child: const Text('Log AI Estimate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysMealsList(
    BuildContext context,
    AppState state,
    List<MealLog> todaysMeals,
  ) {
    if (todaysMeals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12), width: 1.2),
        ),
        child: Center(
          child: Column(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                'No meals logged yet today.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todaysMeals.length,
      itemBuilder: (context, index) {
        final meal = todaysMeals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1), width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              meal.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${meal.slot} • ₹${meal.cost.toInt()}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniBadge('kcal', meal.calories.toInt().toString(), Colors.grey.shade100, Colors.grey.shade700),
                    const SizedBox(width: 4),
                    _buildMiniBadge('P', '${meal.protein.toInt()}g', AppColors.primary.withValues(alpha: 0.08), AppColors.primary),
                    const SizedBox(width: 4),
                    _buildMiniBadge('C', '${meal.carbs.toInt()}g', Colors.blue.withValues(alpha: 0.08), Colors.blue.shade700),
                    const SizedBox(width: 4),
                    _buildMiniBadge('F', '${meal.fat.toInt()}g', Colors.amber.withValues(alpha: 0.08), Colors.amber.shade700),
                  ],
                )
              ],
            ),
            trailing: IconButton(
              tooltip: 'Delete meal',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () {
                // Delete meal
                setState(() {
                  state.deleteMeal(meal.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed: ${meal.title}')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniBadge(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
