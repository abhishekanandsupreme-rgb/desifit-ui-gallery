import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/network/analytics_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String? _selectedModality;
  String? _selectedSplit;
  String? _selectedSubTab;

  void _initializeSubTab(AppState state) {
    final split = _selectedSplit;
    if (split == 'Push/Pull/Legs') {
      _selectedSubTab = 'Push';
    } else if (split == 'Upper/Lower') {
      _selectedSubTab = 'Upper';
    } else if (split == 'Bro Split') {
      _selectedSubTab = 'Chest';
    } else if (split == 'Full Body') {
      _selectedSubTab = 'Full Body';
    } else { // 'All'
      _selectedSubTab = 'All';
    }
  }

  List<String> _getSubTabsForSplit(String split) {
    if (split == 'Push/Pull/Legs') {
      return ['Push', 'Pull', 'Legs'];
    } else if (split == 'Upper/Lower') {
      return ['Upper', 'Lower'];
    } else if (split == 'Bro Split') {
      return ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs'];
    } else { // 'All'
      return ['All', 'Chest', 'Shoulders', 'Back', 'Biceps', 'Triceps', 'Legs', 'Core'];
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent('screen_view', {'screen_name': 'workout'});
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is String && _selectedModality == null) {
      _selectedModality = args;
    } else if (_selectedModality == null) {
      _selectedModality = 'All';
    }
    
    if (_selectedSplit == null) {
      _selectedSplit = state.selectedWorkoutSplit ?? 'Push/Pull/Legs';
      _initializeSubTab(state);
    }

    final mediaQueryData = MediaQuery.of(context);
    final clampedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
    final clampedTextScaler = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mediaQueryData.copyWith(
        // ignore: deprecated_member_use
        textScaleFactor: clampedTextScaleFactor,
        textScaler: clampedTextScaler,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            tooltip: 'Back',
            onPressed: () {
              state.cancelWorkout();
              Navigator.pop(context);
            },
          ),
          title: Text(
            state.activeWorkout != null ? 'Active Workout Session' : 'Desi Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: state.activeWorkout != null
            ? _buildActiveSessionView(context, state)
            : _buildWorkoutGuideView(context, state),
      ),
    );
  }

  // View 1: Workout Guide List
  Widget _buildWorkoutGuideView(BuildContext context, AppState state) {
    final filteredWorkouts = state.workouts.where((workout) {
      if (_selectedModality == 'Home' && workout.category != 'Calisthenics') return false;
      if (_selectedModality == 'Gym' && workout.category != 'Gym') return false;
      if (_selectedModality == 'Desi' && workout.category != 'Desi') return false;

      if (_selectedSplit == 'All') {
        if (_selectedSubTab == 'All') return true;
        return workout.bodyPart == _selectedSubTab;
      } else if (_selectedSplit == 'Push/Pull/Legs') {
        return workout.splits.contains(_selectedSubTab);
      } else if (_selectedSplit == 'Upper/Lower') {
        return workout.splits.contains(_selectedSubTab);
      } else if (_selectedSplit == 'Bro Split') {
        return workout.splits.contains(_selectedSubTab);
      } else if (_selectedSplit == 'Full Body') {
        return workout.splits.contains('Full Body');
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Header Greeting Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build Pure Steel',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'No membership? No problem. Free bodyweight calisthenics designed for small hostel rooms.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Training Category Modality Selector Chips Row
        Text(
          state.translate('TRAINING CATEGORY'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              {'id': 'All', 'label': 'All Categories', 'icon': Icons.all_inclusive},
              {'id': 'Desi', 'label': 'Desi Workouts', 'icon': Icons.flash_on},
              {'id': 'Home', 'label': 'Dorm Calisthenics', 'icon': Icons.home},
              {'id': 'Gym', 'label': 'Gym Workouts', 'icon': Icons.fitness_center},
            ].map((mod) {
              final modId = mod['id'] as String;
              final isSelected = _selectedModality == modId;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  avatar: Icon(mod['icon'] as IconData, size: 16, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
                  label: Text(state.translate(mod['label'] as String)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer.withOpacity(0.2),
                  backgroundColor: AppColors.surfaceContainerLow,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedModality = modId;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Workout Split Title
        Text(
          state.translate('WORKOUT SPLIT'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),

        // Split Selector Chips Row
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              'Push/Pull/Legs',
              'Upper/Lower',
              'Bro Split',
              'Full Body',
              'All',
            ].map((splitName) {
              final isSelected = _selectedSplit == splitName;
              final isRecommended = state.selectedWorkoutSplit == splitName;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Row(
                    children: [
                      Text(state.translate(splitName)),
                      if (isRecommended) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('REC', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer.withOpacity(0.2),
                  backgroundColor: AppColors.surfaceContainerLow,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSplit = splitName;
                        _initializeSubTab(state);
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Sub-navigation / Bodypart Selector Chips Row
        if (_selectedSplit != 'Full Body') ...[
          Text(
            _selectedSplit == 'All'
                ? state.translate('FILTER BY BODYPART')
                : state.translate('SELECT SPLIT DAY'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getSubTabsForSplit(_selectedSplit!).map((subTabName) {
                final isSelected = _selectedSubTab == subTabName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(state.translate(subTabName)),
                    selected: isSelected,
                    selectedColor: AppColors.secondaryContainer.withOpacity(0.2),
                    backgroundColor: AppColors.surfaceContainerLow,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.secondary : AppColors.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSubTab = subTabName;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        Text(
          state.translate('SELECT ROUTINE'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),

        // Workouts List
        filteredWorkouts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        state.translate('No workouts found for this filter.'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: List.generate(filteredWorkouts.length, (idx) {
                  final workout = filteredWorkouts[idx];
                  return Semantics(
                    button: true,
                    label: state.translate(
                      'Routine: {name} ({type} Workout). Goal is {targetSets} sets of {targetReps} reps. Difficulty is {difficulty}. Double tap to view details.',
                      name: workout.name,
                    )
                    .replaceFirst('{type}', workout.isGym ? 'Gym' : 'Home')
                    .replaceFirst('{targetSets}', workout.targetSets.toString())
                    .replaceFirst('{targetReps}', workout.targetReps.toString())
                    .replaceFirst('{difficulty}', workout.difficulty),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          _showWorkoutDetailDialog(context, state, workout);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryContainer.withOpacity(0.1),
                                child: Icon(workout.icon, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  workout.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Semantics(
                                                button: true,
                                                label: 'View brief description for ${workout.name}',
                                                child: IconButton(
                                                  icon: const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  tooltip: 'View brief description',
                                                  onPressed: () {
                                                    _showBriefDescriptionDialog(context, state, workout);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: workout.category == 'Gym'
                                                ? AppColors.primary.withOpacity(0.15)
                                                : (workout.category == 'Desi'
                                                    ? Colors.amber.withOpacity(0.15)
                                                    : AppColors.secondary.withOpacity(0.15)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            workout.category == 'Gym'
                                                ? 'Gym'
                                                : (workout.category == 'Desi' ? 'Desi' : 'Dorm'),
                                            style: TextStyle(
                                              color: workout.category == 'Gym'
                                                  ? AppColors.primary
                                                  : (workout.category == 'Desi'
                                                      ? Colors.amber[800]
                                                      : AppColors.secondary),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Goal: ${workout.targetSets} sets x ${workout.targetReps} reps  •  🔥 ${workout.estimatedCalories.round()} kcal',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: workout.difficulty == 'Hard'
                                      ? Colors.red.withOpacity(0.1)
                                      : (workout.difficulty == 'Medium'
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  workout.difficulty,
                                  style: TextStyle(
                                    color: workout.difficulty == 'Hard'
                                        ? Colors.red
                                        : (workout.difficulty == 'Medium'
                                            ? Colors.orange
                                            : Colors.green),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
        const SizedBox(height: 24),
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
    );
  }

  // View 2: Live Rep Counter Session Screen
  Widget _buildActiveSessionView(BuildContext context, AppState state) {
    final workout = state.activeWorkout!;
    final double completionPercent = workout.targetReps > 0
        ? (state.currentReps / workout.targetReps)
        : 0;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    workout.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'View brief description for ${workout.name}',
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, size: 22, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'View brief description',
                    onPressed: () {
                      _showBriefDescriptionDialog(context, state, workout);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set ${state.currentSet} of ${workout.targetSets}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 48),

            // Rep counter progress circle
            Semantics(
              button: true,
              label: 'Rep counter. Current count is ${state.currentReps} of ${workout.targetReps} reps, for set ${state.currentSet} of ${workout.targetSets}. Double tap to log a rep.',
              child: GestureDetector(
                onTap: () {
                  state.incrementRep();
                  if (state.activeWorkout == null) {
                    // Workout finished!
                    _showWorkoutCompleteDialog(context, workout);
                  }
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Ring Painter
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: completionPercent,
                          strokeWidth: 12,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          color: AppColors.primary,
                        ),
                      ),
                      // Tap Action Button Area
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${state.currentReps}',
                                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                                Text(
                                  '/ ${workout.targetReps} REPS',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'TAP TO COUNT',
                                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Follow Tempo Pacing: ${workout.tempo}',
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TempoPacerWidget(tempo: workout.tempo),
            const SizedBox(height: 40),

            // Cancel Button
            Semantics(
              button: true,
              label: 'Cancel current workout session',
              child: OutlinedButton(
                onPressed: () {
                  state.cancelWorkout();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('CANCEL SESSION', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBriefDescriptionDialog(BuildContext context, AppState state, WorkoutItem workout) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(workout.icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  workout.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.translate('Description:'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                workout.desc,
                style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category: ${workout.category}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
                    'Est. Calories: ${workout.estimatedCalories.round()} kcal',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                state.translate('Close'),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Detailed instruction pop-up
  void _showWorkoutDetailDialog(BuildContext context, AppState state, WorkoutItem workout) {
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
                      workout.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Exercise pace simulation animation (Pulsing graphic card)
                Center(
                  child: Semantics(
                    label: 'Visual pacing guide. Pulses slowly to match standard repetition rate.',
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer.withOpacity(0.15),
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: Icon(
                              workout.icon,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'PACING CYCLE (UP/DOWN)',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.desc,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),

                // Targets summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSpecCol('SETS', '${workout.targetSets}'),
                    _buildSpecCol('REPS', '${workout.targetReps}'),
                    _buildSpecCol('DIFF', workout.difficulty),
                    _buildSpecCol('CALORIES', '${workout.estimatedCalories.round()} kcal'),
                  ],
                ),
                const Divider(height: 24),
                Semantics(
                  container: true,
                  label: 'Scientific training metrics: Target Intensity is ${workout.intensity}, Tempo control pacing is ${workout.tempo}, and target Heart Rate Zone is ${workout.targetHeartRateZone}.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scientific Training Metrics:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.speed, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Intensity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(workout.intensity, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Tempo Control:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(workout.tempo, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Eccentric - Isometric Pause - Concentric - Reset',
                            child: Icon(Icons.info_outline, color: Colors.grey[400], size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Text('Target Heart Rate:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(workout.targetHeartRateZone, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                const Text(
                  'Search External Reference Sites:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildWebLinkButton(
                      context, 
                      'YouTube Search', 
                      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(workout.name + " tutorial")}',
                      Icons.play_circle_outline,
                      Colors.red,
                    ),
                    _buildWebLinkButton(
                      context, 
                      'ExRx.net Search', 
                      'https://exrx.net/Search.html?q=${Uri.encodeComponent(workout.name)}',
                      Icons.menu_book,
                      Colors.blue,
                    ),
                    _buildWebLinkButton(
                      context, 
                      'Bodybuilding.com Search', 
                      'https://www.bodybuilding.com/exercises/search?query=${Uri.encodeComponent(workout.name)}',
                      Icons.fitness_center,
                      Colors.orange,
                    ),
                    _buildWebLinkButton(
                      context, 
                      'Muscle & Strength Search', 
                      'https://www.muscleandstrength.com/exercises',
                      Icons.flash_on,
                      Colors.green,
                    ),
                    if (workout.category == 'Calisthenics' || workout.category == 'Desi') ...[
                      _buildWebLinkButton(
                        context, 
                        'Hybrid Calisthenics', 
                        'https://www.hybridcalisthenics.com/exercises',
                        Icons.self_improvement,
                        Colors.teal,
                      ),
                      _buildWebLinkButton(
                        context, 
                        'Reddit BWF Wiki', 
                        'https://reddit.com/r/bodyweightfitness/wiki/kb/recommended_routine',
                        Icons.forum,
                        Colors.deepOrange,
                      ),
                    ] else ...[
                      _buildWebLinkButton(
                        context, 
                        'StrengthLog Search', 
                        'https://www.strengthlog.com/exercise-directory/',
                        Icons.analytics,
                        Colors.indigo,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Legal Disclaimer: The above links direct to external third-party search results. DesiFit does not host, own, or license this external content, and has no official affiliation or endorsement with these entities.',
                  style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic, height: 1.3),
                ),
                const Divider(height: 24),

                // Start button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    state.startWorkout(workout);
                  },
                  child: const Text('START SESSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecCol(String label, String val) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface),
        ),
      ],
    );
  }

  // Session completion dialog
  void _showWorkoutCompleteDialog(BuildContext context, WorkoutItem workout) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Session Complete!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.star, color: AppColors.secondary, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations! You have completed all sets of ${workout.name} and logged your progress.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                AdService.showInterstitialAd(() {
                  _showShareDialog(
                    context,
                    'Workout Achievement',
                    ShareMockGenerator.generateWorkoutCard(
                      workoutName: workout.name,
                      sets: workout.targetSets,
                      reps: workout.targetReps,
                      difficulty: workout.difficulty,
                    ),
                  );
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.share, color: AppColors.primary, size: 18),
              label: const Text('SHARE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AdService.showInterstitialAd(() {});
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
              child: const Text('GREAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, String title, String cardText) {
    AnalyticsService.logEvent('share_card_generated', {
      'card_type': title,
      'card_content': cardText,
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Here is your shareable text card. Copy it to share with friends or post on social media!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: SelectableText(
                  cardText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cardText));
                AnalyticsService.logEvent('social_shared', {
                  'card_type': title,
                  'card_content': cardText,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card copied to clipboard!')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
              ),
              icon: const Icon(Icons.copy, color: Colors.white, size: 18),
              label: const Text('COPY & SHARE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebLinkButton(
    BuildContext context, 
    String label, 
    String url, 
    IconData icon, 
    Color color,
  ) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () => _launchURL(context, url),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening link: $e')),
      );
    }
  }
}

class TempoPacerWidget extends StatefulWidget {
  final String tempo;
  const TempoPacerWidget({Key? key, required this.tempo}) : super(key: key);

  @override
  State<TempoPacerWidget> createState() => _TempoPacerWidgetState();
}

class _TempoPacerWidgetState extends State<TempoPacerWidget> {
  Timer? _timer;
  late List<int> _durations;
  int _currentPhaseIdx = 0;
  int _secondsLeft = 0;
  
  final List<String> _phaseNames = [
    'ECCENTRIC (Slowly Down)',
    'PAUSE (Hold Tension)',
    'CONCENTRIC (Push Fast!)',
    'RESET (Rest/Pause)'
  ];
  
  final List<Color> _phaseColors = [
    AppColors.secondary, // Leaf Green
    Colors.orange,
    AppColors.primary, // Baked Saffron
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _parseTempo();
    _startPacer();
  }

  @override
  void didUpdateWidget(covariant TempoPacerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tempo != widget.tempo) {
      _parseTempo();
      _startPacer();
    }
  }

  void _parseTempo() {
    final parts = widget.tempo.split('-');
    if (parts.length == 4) {
      _durations = parts.map((p) => int.tryParse(p) ?? 0).toList();
    } else {
      _durations = [3, 0, 1, 0];
    }
    _currentPhaseIdx = 0;
    _findNextActivePhase();
  }

  void _findNextActivePhase() {
    int startIdx = _currentPhaseIdx;
    while (_durations[_currentPhaseIdx] == 0) {
      _currentPhaseIdx = (_currentPhaseIdx + 1) % 4;
      if (_currentPhaseIdx == startIdx) {
        _durations = [3, 0, 1, 0];
        _currentPhaseIdx = 0;
        break;
      }
    }
    _secondsLeft = _durations[_currentPhaseIdx];
  }

  void _startPacer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _currentPhaseIdx = (_currentPhaseIdx + 1) % 4;
          _findNextActivePhase();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseColor = _phaseColors[_currentPhaseIdx];
    final phaseName = _phaseNames[_currentPhaseIdx];
    final maxDuration = _durations[_currentPhaseIdx];
    final percent = maxDuration > 0 ? _secondsLeft / maxDuration : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
              backgroundColor: phaseColor.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phaseName,
                style: TextStyle(
                  color: phaseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$_secondsLeft seconds remaining',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
