import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';

class HealthProfileCard extends StatefulWidget {
  const HealthProfileCard({super.key});

  @override
  State<HealthProfileCard> createState() => _HealthProfileCardState();
}

class _HealthProfileCardState extends State<HealthProfileCard> {
  bool _isProfileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.userWeight == null) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Semantics(
              button: true,
              label: '${state.translate('Setup Health Profile')}. ${state.translate('Calculate BMI, targets & sasta diet')}',
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
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
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

        return Semantics(
          container: true,
          label: '${state.translate('MY FITNESS PROFILE')}. ${state.translate('Weight')}: ${state.userWeight!.round()} kg. ${state.translate('Height')}: ${state.userHeight!.round()} cm. ${state.translate('BMI')}: ${bmi.toStringAsFixed(1)}',
          child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: state.translate(_isProfileExpanded ? 'Collapse profile details' : 'Expand profile details'),
                  child: GestureDetector(
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
                              color: AppColors.secondary.withValues(alpha: 0.12),
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
                                color: bmiColor.withValues(alpha: 0.15),
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
                      Semantics(
                        button: true,
                        label: '${state.translate('VIEW DIET')}. ${state.translate('Show sasta protein diet plan')}',
                        child: TextButton(
                        onPressed: () {
                          _showSastaDietDialog(context, state);
                        },
                        child: Text(state.translate('VIEW DIET')),
                      ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        );
      },
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
              ],
            ),
          ),
        );
      },
    );
  }
}
