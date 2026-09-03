import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';

class DietTrackerCard extends StatelessWidget {
  const DietTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final targetCal = state.dailyCalorieTarget ?? 2000.0;
        final consumedCal = state.caloriesConsumed;
        final remainingCal = state.caloriesRemaining;
        final calPercent = targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0;

        final targetProt = state.proteinGoal;
        final hitProt = state.proteinHit;
        final protPercent = targetProt > 0 ? (hitProt / targetProt).clamp(0.0, 1.0) : 0.0;

        return Semantics(
          container: true,
          label: '${state.translate('Nutrition Tracker')}. ${state.translate('Calories')}: ${consumedCal.toInt()} of ${targetCal.toInt()} kcal. ${state.translate('Protein')}: ${hitProt.toInt()} of ${targetProt.toInt()}g.',
          child: Container(
          key: const ValueKey('diet'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
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
                  Semantics(
                    button: true,
                    label: '${state.translate('Log Food')}. ${state.translate('Navigate to calorie counter')}',
                    child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.calorieCounter);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const ExcludeSemantics(child: Icon(Icons.add, size: 14, color: AppColors.primary)),
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
                  Container(height: 80, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
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
        ),
        );
      },
    );
  }
}
