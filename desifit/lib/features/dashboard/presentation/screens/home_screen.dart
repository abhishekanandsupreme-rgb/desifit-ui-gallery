import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/badges_dialog.dart';
import '../widgets/matka_hydration_widget.dart';
import 'story_viewer_screen.dart';
import '../../../planner/presentation/screens/planner_screen.dart';
import '../../../../core/ads/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTrackerIndex = 0;
  bool _isProfileExpanded = false;

  void _showLogoutConfirmation(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Hey ${state.currentUser!.displayName}, do you want to log out of your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                state.logout();
                Navigator.pop(context);
              },
              child: const Text('LOG OUT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSastaDietDialog(BuildContext context, AppState state) {
    final goal = state.bodyGoal ?? 'Muscle Gain';
    List<Map<String, String>> dietPlan = [];
    if (goal == 'Muscle Gain') {
      dietPlan = [
        {'item': '3 tbsp Sattu + 250ml Milk', 'cost': '₹15', 'prot': '15g Protein'},
        {'item': '50g Soya Chunks boiled', 'cost': '₹10', 'prot': '26g Protein'},
        {'item': '4 Whole Eggs boiled', 'cost': '₹28', 'prot': '24g Protein'},
        {'item': '50g Peanuts roasted', 'cost': '₹5', 'prot': '13g Protein'},
        {'item': '100g Paneer cubes', 'cost': '₹40', 'prot': '18g Protein'},
      ];
    } else if (goal == 'Fat Loss') {
      dietPlan = [
        {'item': '3 tbsp Sattu in Cold Water', 'cost': '₹5', 'prot': '9g Protein'},
        {'item': '60g Soya Chunks (air fried)', 'cost': '₹12', 'prot': '31g Protein'},
        {'item': '6 Egg Whites', 'cost': '₹30', 'prot': '22g Protein'},
        {'item': '200g Curd / Dahi', 'cost': '₹25', 'prot': '12g Protein'},
        {'item': '50g Roasted Chana snack', 'cost': '₹8', 'prot': '11g Protein'},
      ];
    } else {
      dietPlan = [
        {'item': '3 tbsp Sattu in Milk', 'cost': '₹15', 'prot': '15g Protein'},
        {'item': '40g Soya Chunks pulao', 'cost': '₹8', 'prot': '20g Protein'},
        {'item': '3 Whole Eggs', 'cost': '₹21', 'prot': '18g Protein'},
        {'item': '100g Paneer / Tofu', 'cost': '₹35', 'prot': '16g Protein'},
        {'item': '30g Roasted Chana', 'cost': '₹5', 'prot': '6g Protein'},
      ];
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.translate('Sasta Protein Diet'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recommended Daily Nutrition Sources:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...dietPlan.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item['item']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          Row(
                            children: [
                              Text(item['prot']!, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(item['cost']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.directions_run, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.translate('"Bhai, is high-protein diet ka total cost under ₹100/day hai. Hostel kitchen/mess food ke sath body goal hit ho jayega!"'),
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackerTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildTabButton(0, '🔥 Diet', AppColors.primary),
          _buildTabButton(1, '💰 Budget', AppColors.primary),
          _buildTabButton(2, '💧 Hydration', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, Color activeColor) {
    final isSelected = _selectedTrackerIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTrackerIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : Colors.grey[600],
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDietTabContent(BuildContext context, AppState state) {
    final targetCal = state.dailyCalorieTarget ?? 2000.0;
    final consumedCal = state.caloriesConsumed;
    final remainingCal = state.caloriesRemaining;
    final calPercent = targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0;

    final targetProt = state.proteinGoal;
    final hitProt = state.proteinHit;
    final protPercent = targetProt > 0 ? (hitProt / targetProt).clamp(0.0, 1.0) : 0.0;

    return Container(
      key: const ValueKey('diet'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate('Nutrition Tracker'),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryContainer,
                ),
              ),
              _BouncingScaleWidget(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.calorieCounter);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        state.translate('Log Food'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 7,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surfaceContainerHigh),
                          ),
                          CircularProgressIndicator(
                            value: calPercent,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                          const Center(
                            child: Text('🔥', style: TextStyle(fontSize: 20)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.translate('Calories'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Plus Jakarta Sans'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${consumedCal.toInt()} / ${targetCal.toInt()} kcal',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${remainingCal.toInt()} kcal left',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(height: 80, width: 1, color: Colors.grey.withOpacity(0.2)),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 7,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surfaceContainerHigh),
                          ),
                          CircularProgressIndicator(
                            value: protPercent,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                          const Center(
                            child: Text('💪', style: TextStyle(fontSize: 20)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.translate('Protein'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Plus Jakarta Sans'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hitProt.toInt()} / ${targetProt.toInt()}g',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(targetProt - hitProt).clamp(0, 999).toInt()}g left',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTabContent(BuildContext context, AppState state) {
    final limit = state.dailyBudgetLimit;
    final spent = limit - state.budgetLeft;
    final left = state.budgetLeft;
    final percent = limit > 0 ? (left / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      key: const ValueKey('budget'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.15),
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
                      painter: _ProgressRingPainter(
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
                _BouncingScaleWidget(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.progressReport);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxSection(BuildContext context, AppState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600;
    final int crossAxisCount = isWide ? 4 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate('SWADESHI TOOLBOX'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            _AestheticToolCard(
              label: state.translate('Sasta Protein'),
              sublabel: state.translate('Cost/g meter'),
              icon: Icons.calculate_rounded,
              themeColor: AppColors.primary,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.sastaCalculator);
              },
              index: 0,
            ),
            _AestheticToolCard(
              label: state.translate('Grocery Plan'),
              sublabel: state.translate('Weekly ₹100/d'),
              icon: Icons.shopping_basket_rounded,
              themeColor: AppColors.secondary,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.groceryPlanner);
              },
              index: 1,
            ),
            _AestheticToolCard(
              label: state.translate('Akhada Sandbox'),
              sublabel: state.translate('Swing Gada'),
              icon: Icons.sports_martial_arts,
              themeColor: Colors.orange.shade800,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.akhadaSandbox);
              },
              index: 2,
            ),
            _AestheticToolCard(
              label: state.translate('AI Calorie Log'),
              sublabel: state.translate('Llama-3 logger'),
              icon: Icons.fastfood_rounded,
              themeColor: Colors.amber.shade800,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.calorieCounter);
              },
              index: 3,
            ),
            _AestheticToolCard(
              label: state.translate('AI Body Scan'),
              sublabel: state.translate('Pose & Symmetry'),
              icon: Icons.center_focus_strong_rounded,
              themeColor: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.progressScan);
              },
              index: 4,
            ),
            _AestheticToolCard(
              label: state.translate('Calisthenics'),
              sublabel: state.translate('Dorm workout'),
              icon: Icons.sports_gymnastics,
              themeColor: Colors.blue.shade800,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.workout, arguments: 'Home');
              },
              index: 5,
            ),
            _AestheticToolCard(
              label: state.translate('Health Feed'),
              sublabel: state.translate('Hacks & Ayurveda'),
              icon: Icons.menu_book_rounded,
              themeColor: Colors.brown.shade700,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.healthFeed);
              },
              index: 6,
            ),
            _AestheticToolCard(
              label: state.translate('Meal Planner'),
              sublabel: state.translate('Plan daily diet'),
              icon: Icons.calendar_month_rounded,
              themeColor: Colors.teal.shade800,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlannerScreen()),
                );
              },
              index: 7,
            ),
            _AestheticToolCard(
              label: state.translate('Weekly Reports'),
              sublabel: state.translate('Budget & Macro'),
              icon: Icons.bar_chart_rounded,
              themeColor: Colors.deepOrange,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.progressReport);
              },
              index: 8,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMyHealthCard(BuildContext context, AppState state) {
    if (state.userWeight == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.onboarding);
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  radius: 24,
                  child: const Icon(Icons.favorite, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate('Setup Health Profile'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.translate('Calculate BMI, targets & sasta diet!'),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    }

    final bmi = state.userBmi ?? 0.0;
    final bmiCat = state.bmiCategory ?? 'Normal';
    final cal = state.dailyCalorieTarget ?? 2000.0;
    final prot = state.proteinGoal;
    final split = state.selectedWorkoutSplit ?? 'Push/Pull/Legs';
    final goal = state.bodyGoal ?? 'Muscle Gain';

    final bmiColor = bmiCat == 'Normal'
        ? Colors.green
        : (bmiCat == 'Underweight' ? Colors.orange : Colors.red);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isProfileExpanded = !_isProfileExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        state.translate('MY FITNESS PROFILE'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          state.translate(goal),
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isProfileExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('WEIGHT', '${state.userWeight!.round()} kg'),
                _buildStatItem('HEIGHT', '${state.userHeight!.round()} cm'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI',
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: bmiColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            state.translate(bmiCat),
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: bmiColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (_isProfileExpanded) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('CALORIES TARGET', '${cal.round()} kcal/day'),
                  _buildStatItem('PROTEIN TARGET', '${prot.round()}g/day'),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.translate('Recommended split: {name}', name: split),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.translate('Tap to view sasta protein diet outline'),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showSastaDietDialog(context, state);
                    },
                    child: Text(state.translate('VIEW DIET')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddCard(
    BuildContext context, {
    required String name,
    required double cost,
    required double protein,
    required IconData icon,
    required AppState state,
  }) {
    return Semantics(
      button: true,
      label: state.translate(
        'Quick Add {name}. Cost is ₹{cost}. Protein is {protein} grams. Double tap to add to today\'s log.',
        name: name,
      ).replaceFirst('{cost}', cost.toInt().toString()).replaceFirst('{protein}', protein.toInt().toString()),
      child: _BouncingScaleWidget(
        onTap: () {
          state.addQuickFood(name, cost, protein);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $name (+₹${cost.toInt()}, +${protein.toInt()}g protein)'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(icon, size: 40, color: Colors.black),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${cost.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${protein.toInt()}g protein',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final clampedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
    final clampedTextScaler = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mediaQueryData.copyWith(
        // ignore: deprecated_member_use
        textScaleFactor: clampedTextScaleFactor,
        textScaler: clampedTextScaler,
      ),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          final displayName = state.isLoggedIn ? state.currentUser!.displayName.split(' ')[0] : 'Champ';
          final photoUrl = state.isLoggedIn ? state.currentUser!.photoUrl : '';
          final screenWidth = mediaQueryData.size.width;
          final bool isWide = screenWidth > 600;
          final int crossAxisCount = isWide ? 4 : 2;
          final double textScale = clampedTextScaleFactor;
          final double baseAspectRatio = isWide ? 1.1 : 1.35;
          final double adjustedAspectRatio = baseAspectRatio / textScale;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header Logo
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Greeting Section & Profile Logout Trigger
                Row(
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
                                    color: Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange.withOpacity(0.35), width: 1.2),
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
                            _showLogoutConfirmation(context, state);
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
                ),
                const SizedBox(height: 24),
                _SwadeshiHeroBanner(state: state),
                const SizedBox(height: 24),

                // 1. Fitness Stories Tray
                Text(
                  state.translate('FITNESS STORIES'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.stories.length,
                    itemBuilder: (context, idx) {
                      final story = state.stories[idx];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Semantics(
                          button: true,
                          label: state.translate(
                            story.isRead ? 'Read fitness story: {title}' : 'Unread fitness story: {title}',
                            name: story.title,
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StoryViewerScreen(initialIndex: idx),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: story.isRead
                                          ? [Colors.grey.shade400, Colors.grey.shade600]
                                          : [AppColors.primary, AppColors.primaryContainer],
                                    ),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      story.avatarText,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                story.title,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: story.isRead ? Colors.grey : AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Combined Daily Tracker Hub
                _buildTrackerTabs(context),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTrackerIndex == 0
                      ? _buildDietTabContent(context, state)
                      : _selectedTrackerIndex == 1
                          ? _buildBudgetTabContent(context, state)
                          : const MatkaHydrationWidget(key: ValueKey('hydration')),
                ),
                const SizedBox(height: 24),

                // 3. Expandable My Health Profile Card
                _buildMyHealthCard(context, state),
                const SizedBox(height: 24),

                // 4. Swadeshi Toolbox
                _buildToolboxSection(context, state),
                const SizedBox(height: 24),

                // 5. Daily Mythbuster
                Text(
                  state.translate('DAILY MYTHBUSTER'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                const FlashcardWidget(),
                const SizedBox(height: 24),

                // 6. Quick Add Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      state.translate('Quick Add'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: adjustedAspectRatio,
                  children: [
                    _buildQuickAddCard(
                      context,
                      name: '1 Glass Sattu',
                      cost: 10,
                      protein: 10,
                      icon: Icons.local_drink,
                      state: state,
                    ),
                    _buildQuickAddCard(
                      context,
                      name: '50g Soya Chunks',
                      cost: 8,
                      protein: 25,
                      icon: Icons.fitness_center,
                      state: state,
                    ),
                    _buildQuickAddCard(
                      context,
                      name: '2 Roti',
                      cost: 6,
                      protein: 6,
                      icon: Icons.bakery_dining,
                      state: state,
                    ),
                    _buildQuickAddCard(
                      context,
                      name: 'Handful Peanuts',
                      cost: 5,
                      protein: 8,
                      icon: Icons.grain,
                      state: state,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 7. Affiliate & Ad Banner Section
                Container(
                  width: double.infinity,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Amazon Deal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Buy 1kg Premium Peanut Butter on Amazon',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          button: true,
                          label: 'Shop Now on Amazon. Open Affiliate Link.',
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening Amazon Affiliate Link...')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SHOP NOW',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sponsor Ad Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: const BannerAdWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class _AestheticToolCard extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color themeColor;
  final VoidCallback onTap;
  final int index;

  const _AestheticToolCard({
    Key? key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.themeColor,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  State<_AestheticToolCard> createState() => _AestheticToolCardState();
}

class _AestheticToolCardState extends State<_AestheticToolCard> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  late AnimationController _hoverController;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverRotateAnimation;
  late Animation<double> _hoverGlowAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _entryController.forward();
      }
    });

    _bobController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400 + Random().nextInt(800)),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverRotateAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _hoverGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _bobController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _opacityAnimation, _hoverScaleAnimation, _hoverRotateAnimation]),
      builder: (context, child) {
        final entryScale = _scaleAnimation.value;
        final hoverScale = _hoverScaleAnimation.value;
        final hoverRotate = _hoverRotateAnimation.value;

        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: entryScale * hoverScale,
            child: Transform.rotate(
              angle: hoverRotate,
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: _BouncingScaleWidget(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _hoverGlowAnimation,
            builder: (context, innerChild) {
              final glowVal = _hoverGlowAnimation.value;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color.lerp(
                      AppColors.outlineVariant.withOpacity(0.12),
                      widget.themeColor.withOpacity(0.5),
                      glowVal,
                    )!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        Colors.black.withOpacity(0.015),
                        widget.themeColor.withOpacity(0.12),
                        glowVal,
                      )!,
                      blurRadius: 8.0 + 10.0 * glowVal,
                      offset: Offset(0, 3.0 + 5.0 * glowVal),
                    ),
                  ],
                ),
                child: innerChild,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_bobAnimation, _hoverGlowAnimation]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(100, 100),
                          painter: _CardPatternPainter(
                            index: widget.index,
                            bobValue: _bobAnimation.value,
                            hoverValue: _hoverGlowAnimation.value,
                            themeColor: widget.themeColor,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _bobAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bobAnimation.value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeColor.withOpacity(0.05),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(widget.icon, size: 24, color: widget.themeColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: -0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.sublabel,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  final int index;
  final double bobValue; // -2.0 to 2.0
  final double hoverValue; // 0.0 to 1.0
  final Color themeColor;

  _CardPatternPainter({
    required this.index,
    required this.bobValue,
    required this.hoverValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withOpacity(0.04 + 0.05 * hoverValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 + 0.4 * hoverValue
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = themeColor.withOpacity(0.015 + 0.025 * hoverValue)
      ..style = PaintingStyle.fill;

    switch (index) {
      case 0:
        _drawSastaProtein(canvas, size, paint, fillPaint);
        break;
      case 1:
        _drawGroceryPlan(canvas, size, paint, fillPaint);
        break;
      case 2:
        _drawAkhadaSandbox(canvas, size, paint, fillPaint);
        break;
      case 3:
        _drawCalorieLog(canvas, size, paint, fillPaint);
        break;
      case 4:
        _drawBodyScan(canvas, size, paint, fillPaint);
        break;
      case 5:
        _drawCalisthenics(canvas, size, paint, fillPaint);
        break;
      case 6:
        _drawHealthFeed(canvas, size, paint, fillPaint);
        break;
      case 7:
        _drawMealPlanner(canvas, size, paint, fillPaint);
        break;
      case 8:
        _drawWeeklyReports(canvas, size, paint, fillPaint);
        break;
    }
  }

  void _drawSastaProtein(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path();
    path.moveTo(50, 25);
    path.lineTo(70, 25);
    path.lineTo(70, 30);
    path.lineTo(82, 58);
    path.lineTo(38, 58);
    path.lineTo(50, 30);
    path.close();

    final liquidPath = Path();
    liquidPath.moveTo(44, 45);
    liquidPath.lineTo(76, 45);
    liquidPath.lineTo(80, 55);
    liquidPath.lineTo(40, 55);
    liquidPath.close();

    canvas.drawPath(liquidPath, fillPaint);
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(55, 38 - bobValue * 1.5), 1.5, paint);
    canvas.drawCircle(Offset(66, 33 - bobValue * 1.2), 2.0, paint);
    canvas.drawCircle(Offset(60, 42 - bobValue * 1.8), 1.2, paint);
  }

  void _drawGroceryPlan(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final stemPath = Path();
    stemPath.moveTo(35, 65);
    stemPath.quadraticBezierTo(50, 40, 75, 25);
    canvas.drawPath(stemPath, paint);

    void drawLeaf(double x, double y, double rotation) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final leaf = Path();
      leaf.moveTo(0, 0);
      leaf.quadraticBezierTo(10, -6, 20, 0);
      leaf.quadraticBezierTo(10, 6, 0, 0);
      canvas.drawPath(leaf, fillPaint);
      canvas.drawPath(leaf, paint);
      canvas.restore();
    }

    drawLeaf(75, 25, -pi / 4 + bobValue * 0.03);
    drawLeaf(58, 38, -3 * pi / 4 - bobValue * 0.03);
    drawLeaf(48, 48, pi / 8 + bobValue * 0.02);
  }

  void _drawAkhadaSandbox(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    canvas.drawCircle(Offset(65, 35), 11, fillPaint);
    canvas.drawCircle(Offset(65, 35), 11, paint);
    canvas.drawLine(Offset(65, 35), Offset(45, 65), paint);
    canvas.drawCircle(Offset(45, 65), 2.5, fillPaint);
    canvas.drawCircle(Offset(45, 65), 2.5, paint);

    final rect1 = Rect.fromCircle(center: Offset(65, 35), radius: 18);
    final rect2 = Rect.fromCircle(center: Offset(65, 35), radius: 25);
    final startAngle = bobValue * 0.05;
    canvas.drawArc(rect1, startAngle, pi * 0.8, false, paint);
    canvas.drawArc(rect2, startAngle + pi, pi * 0.6, false, paint);
  }

  void _drawCalorieLog(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    canvas.drawLine(Offset(40, 20), Offset(48, 20), paint);
    canvas.drawLine(Offset(40, 20), Offset(40, 28), paint);
    canvas.drawLine(Offset(80, 20), Offset(72, 20), paint);
    canvas.drawLine(Offset(80, 20), Offset(80, 28), paint);
    canvas.drawLine(Offset(40, 60), Offset(48, 60), paint);
    canvas.drawLine(Offset(40, 60), Offset(40, 52), paint);
    canvas.drawLine(Offset(80, 60), Offset(72, 60), paint);
    canvas.drawLine(Offset(80, 60), Offset(80, 52), paint);

    final y = 40.0 + bobValue * 5.0;
    final laserPaint = Paint()
      ..color = themeColor.withOpacity(0.12 + 0.15 * hoverValue)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(36, y), Offset(84, y), laserPaint);
    canvas.drawCircle(Offset(60, 40), 2.0, paint);
  }

  void _drawBodyScan(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final gridPaint = Paint()
      ..color = themeColor.withOpacity(0.02 + 0.03 * hoverValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(50, 15), Offset(50, 65), gridPaint);
    canvas.drawLine(Offset(70, 15), Offset(70, 65), gridPaint);
    canvas.drawLine(Offset(35, 30), Offset(85, 30), gridPaint);
    canvas.drawLine(Offset(35, 50), Offset(85, 50), gridPaint);

    canvas.drawCircle(Offset(60, 25), 4, paint);
    canvas.drawLine(Offset(60, 29), Offset(60, 50), paint);
    canvas.drawLine(Offset(60, 35), Offset(48, 42 + bobValue * 0.5), paint);
    canvas.drawLine(Offset(60, 35), Offset(72, 38 - bobValue * 0.5), paint);
    canvas.drawLine(Offset(60, 50), Offset(52, 62), paint);
    canvas.drawLine(Offset(60, 50), Offset(68, 62), paint);

    final scanY = 15.0 + (bobValue + 2.0) * 12.5;
    canvas.drawLine(Offset(30, scanY), Offset(90, scanY), paint..strokeWidth = 1.5);
  }

  void _drawCalisthenics(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final center = Offset(70, 30);
    canvas.drawCircle(center, 12 + (bobValue + 2.0) * 3, paint);
    canvas.drawCircle(center, 24 + (bobValue + 2.0) * 3, paint);
    canvas.drawCircle(center, 36 + (bobValue + 2.0) * 3, paint);

    canvas.drawLine(Offset(58, 0), Offset(58, 30 + bobValue), paint);
    canvas.drawLine(Offset(82, 0), Offset(82, 30 - bobValue), paint);
    canvas.drawCircle(Offset(58, 33 + bobValue), 4, paint);
    canvas.drawCircle(Offset(82, 33 - bobValue), 4, paint);
  }

  void _drawHealthFeed(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final leftPage = Path()
      ..moveTo(60, 52)
      ..quadraticBezierTo(48, 52, 40, 48)
      ..lineTo(40, 34)
      ..quadraticBezierTo(48, 38, 60, 38)
      ..close();
    final rightPage = Path()
      ..moveTo(60, 52)
      ..quadraticBezierTo(72, 52, 80, 48)
      ..lineTo(80, 34)
      ..quadraticBezierTo(72, 38, 60, 38)
      ..close();
    canvas.drawPath(leftPage, fillPaint);
    canvas.drawPath(leftPage, paint);
    canvas.drawPath(rightPage, fillPaint);
    canvas.drawPath(rightPage, paint);

    void drawSparkle(double x, double y, double sz) {
      final path = Path()
        ..moveTo(x, y - sz)
        ..quadraticBezierTo(x, y, x + sz, y)
        ..quadraticBezierTo(x, y, x, y + sz)
        ..quadraticBezierTo(x, y, x - sz, y)
        ..quadraticBezierTo(x, y, x, y - sz)
        ..close();
      canvas.drawPath(path, paint);
    }

    drawSparkle(45, 25 - bobValue, 3 + hoverValue * 2);
    drawSparkle(75, 20 + bobValue, 4 + hoverValue * 2);
    drawSparkle(60, 18 - bobValue * 0.5, 2 + hoverValue * 1);
  }

  void _drawMealPlanner(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final calRect = Rect.fromLTRB(45, 20, 75, 50);
    canvas.drawRect(calRect, paint);
    canvas.drawLine(Offset(55, 20), Offset(55, 50), paint);
    canvas.drawLine(Offset(65, 20), Offset(65, 50), paint);
    canvas.drawLine(Offset(45, 30), Offset(75, 30), paint);
    canvas.drawLine(Offset(45, 40), Offset(75, 40), paint);

    final checkPath = Path()
      ..moveTo(57, 34)
      ..lineTo(59.5, 37)
      ..lineTo(63, 32);
    final checkPaint = Paint()
      ..color = themeColor.withOpacity(0.6 + 0.4 * hoverValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + 0.5 * hoverValue
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawWeeklyReports(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final linePath = Path()
      ..moveTo(40, 48)
      ..lineTo(52, 38 + bobValue)
      ..lineTo(64, 42 - bobValue)
      ..lineTo(76, 22);
    canvas.drawPath(linePath, paint);

    canvas.drawCircle(Offset(40, 48), 2, paint);
    canvas.drawCircle(Offset(52, 38 + bobValue), 2, paint);
    canvas.drawCircle(Offset(64, 42 - bobValue), 2, paint);
    canvas.drawCircle(Offset(76, 22), 2, paint);

    if (hoverValue > 0) {
      final barPaint = Paint()
        ..color = themeColor.withOpacity(0.04 * hoverValue)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTRB(38, 48, 42, 55), barPaint);
      canvas.drawRect(Rect.fromLTRB(50, 38 + bobValue, 54, 55), barPaint);
      canvas.drawRect(Rect.fromLTRB(62, 42 - bobValue, 66, 55), barPaint);
      canvas.drawRect(Rect.fromLTRB(74, 22, 78, 55), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) {
    return oldDelegate.index != index ||
        oldDelegate.bobValue != bobValue ||
        oldDelegate.hoverValue != hoverValue ||
        oldDelegate.themeColor != themeColor;
  }
}


class _ProgressRingPainter extends CustomPainter {
  final double percentage;
  final Color baseColor;
  final Color progressColor;
  final List<Color>? gradient;
  final double strokeWidth;

  _ProgressRingPainter({
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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _SwadeshiHeroBanner extends StatefulWidget {
  final AppState state;
  const _SwadeshiHeroBanner({Key? key, required this.state}) : super(key: key);

  @override
  State<_SwadeshiHeroBanner> createState() => _SwadeshiHeroBannerState();
}

class _SwadeshiHeroBannerState extends State<_SwadeshiHeroBanner> with SingleTickerProviderStateMixin {
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
                AppColors.primary.withOpacity(0.1),
                Colors.orange.withOpacity(0.04),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25 * glowVal),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04 * glowVal),
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
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

class _BouncingScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _BouncingScaleWidget({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  State<_BouncingScaleWidget> createState() => _BouncingScaleWidgetState();
}

class _BouncingScaleWidgetState extends State<_BouncingScaleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap == null ? null : () {},
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _HeartbeatStreakWidget extends StatefulWidget {
  final Widget child;
  const _HeartbeatStreakWidget({Key? key, required this.child}) : super(key: key);

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
