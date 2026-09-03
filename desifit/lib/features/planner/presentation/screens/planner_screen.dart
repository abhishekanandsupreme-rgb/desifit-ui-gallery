import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _selectedDayIndex = 1; // Default to Tuesday (13th) to match Figma mock

  final List<Map<String, String>> _weekDays = [
    {'day': 'MON', 'date': '12'},
    {'day': 'TUE', 'date': '13'},
    {'day': 'WED', 'date': '14'},
    {'day': 'THU', 'date': '15'},
    {'day': 'FRI', 'date': '16'},
    {'day': 'SAT', 'date': '17'},
    {'day': 'SUN', 'date': '18'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final meals = state.meals;

    // Calculate totals
    double totalCost = 0;
    double totalProtein = 0;
    for (var meal in meals) {
      totalCost += meal.cost;
      totalProtein += meal.protein;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Jugaad Planner',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Budget protein hacks for the modern Desi.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Horizontal Week Days Slider
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  final day = _weekDays[index];
                  final bool isSelected = _selectedDayIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                          border: isSelected
                              ? const Border(bottom: BorderSide(color: AppColors.primary, width: 4))
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day['day']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day['date']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Daily Summary Bento Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Projected Cost',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${totalCost.toInt()}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Spent',
                              style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Projected Protein',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${totalProtein.toInt()}g',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Goal Hit',
                              style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Hacks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Hacks",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${meals.length} Slots Filled',
                    style: TextStyle(color: Colors.grey[800], fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List of Meal Slots
            if (meals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'No meals planned for today. Tap Auto-Fill or Add Meal below!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return _buildMealSlotItem(context, meal);
                },
              ),
            const SizedBox(height: 24),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () => _showAddMealSheet(context, state),
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text('Add Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                state.autoFillBudgetHacks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto-filled standard budget hacks!')),
                );
              },
              icon: const Icon(Icons.bolt, color: AppColors.secondary),
              label: const Text('Auto-Fill with Budget Hacks'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary, width: 2),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSlotItem(BuildContext context, MealLog meal) {
    Color slotColor = AppColors.primary;
    IconData slotIcon = Icons.restaurant;
    Color slotBg = AppColors.primaryContainer.withValues(alpha: 0.12);

    if (meal.slot == 'Lunch') {
      slotColor = AppColors.secondary;
      slotIcon = Icons.lunch_dining;
      slotBg = AppColors.secondaryContainer.withValues(alpha: 0.3);
    } else if (meal.slot == 'Dinner') {
      slotColor = Colors.blue;
      slotIcon = Icons.dinner_dining;
      slotBg = Colors.blue.withValues(alpha: 0.12);
    } else if (meal.slot == 'Snack') {
      slotColor = Colors.amber[800]!;
      slotIcon = Icons.cookie;
      slotBg = Colors.amber[100]!.withValues(alpha: 0.5);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: slotBg,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(slotIcon, color: slotColor, size: 24),
                const SizedBox(height: 2),
                Text(
                  meal.slot.toUpperCase(),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: slotColor, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${meal.cost.toInt()}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${meal.protein.toInt()}g Protein',
                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMealSheet(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final proteinController = TextEditingController();
    String selectedSlot = 'Breakfast';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Log Custom Meal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Meal Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Meal Slot Selector
                  DropdownButtonFormField<String>(
                    initialValue: selectedSlot,
                    decoration: InputDecoration(
                      labelText: 'Meal Slot',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((slot) {
                      return DropdownMenuItem(value: slot, child: Text(slot));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedSlot = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Cost
                      Expanded(
                        child: TextField(
                          controller: costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cost (₹)',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLowest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Protein
                      Expanded(
                        child: TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLowest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final cost = double.tryParse(costController.text) ?? 0.0;
                      final protein = double.tryParse(proteinController.text) ?? 0.0;

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a meal name.')),
                        );
                        return;
                      }

                      state.addCustomMeal(name, selectedSlot, cost, protein);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged $name successfully!')),
                      );
                    },
                    child: const Text('Save Meal'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
