import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

class QuickAddGrid extends StatelessWidget {
  const QuickAddGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth > 600;
        final int crossAxisCount = isWide ? 4 : 2;

        return Semantics(
          container: true,
          label: '${state.translate('Quick Add')}. ${state.translate("Add food to today's log")}',
          child: GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.1 : 1.35,
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
        );
      },
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
      // Built directly (not via translate): the {name} template placeholder is only
      // substituted for keys containing 'Champ', so it would otherwise be read aloud.
      label: 'Quick Add $name. Cost is ₹${cost.toInt()}. Protein is ${protein.toInt()} grams. Double tap to add to today\'s log.',
      child: GestureDetector(
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
}
