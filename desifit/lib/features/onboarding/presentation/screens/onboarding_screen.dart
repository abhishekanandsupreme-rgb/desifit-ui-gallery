import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/routing/routing.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/analytics_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoadingAuth = false;

  final int _numPages = 9;
  double _weightInput = 70.0;
  double _heightInput = 170.0;
  String _selectedGoalInput = 'Muscle Gain';

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent('screen_view', {'screen_name': 'onboarding'});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.currentUser != null && !state.isGuest) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      if (_currentPage == 6) {
        // Transitioning from Page 7 (Goal Selection) to Page 8 (Anabolic Report)
        Provider.of<AppState>(context, listen: false)
            .updateBodyMetrics(_weightInput, _heightInput, _selectedGoalInput);
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.userWeight == null) {
        state.updateBodyMetrics(_weightInput, _heightInput, _selectedGoalInput);
      }
      AnalyticsService.logEvent('onboarding_complete', {'method': 'guest'});
      state.loginAsGuest();
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background blur / decor
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),
            
            // Page view contents
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Force clicks to ensure metrics update
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildIntroPage(context),
                      _buildPage1(context),
                      _buildPage2(context),
                      _buildPage3(context),
                      _buildPage4(context),
                      _buildPage5(context), // New: Height & Weight
                      _buildPage6(context), // New: Goal Selection
                      _buildPage7(context), // New: Calculations / Report
                      _buildPage8(context), // Final: Auth / Guest
                    ],
                  ),
                ),
                
                // Fixed Footer Actions
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress Dots
                      Row(
                        children: List.generate(_numPages, (index) {
                          final bool isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 6.0,
                            width: isActive ? 32.0 : 8.0,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          );
                        }),
                      ),
                      
                      // Next Button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _numPages - 1 ? 'Start' : 'Next',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
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
  }

  Widget _buildIntroPage(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return _buildPageLayout(
      context: context,
      badgeText: state.translate('SWADESHI STRENGTH'),
      badgeColor: AppColors.primary.withOpacity(0.12),
      badgeTextColor: AppColors.primary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: [
            TextSpan(text: state.translate("India's First Desi Workout") + "\n"),
            TextSpan(
              text: state.translate("& Calisthenics App"),
              style: const TextStyle(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: [
            TextSpan(
              text: state.translate(
                'Reclaiming traditional Indian strength fused with modern calisthenics. Build steel muscle anywhere with no expensive gear.'
              ),
            ),
          ],
        ),
      ),
      visual: _buildIntroVisual(context, state),
    );
  }

  Widget _buildIntroVisual(BuildContext context, AppState state) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Stack(
        children: [
          // Background deco / grain / orange circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.fitness_center, size: 280, color: AppColors.primary),
            ),
          ),
          // Glassmorphic features card
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        state.translate('SPECIAL FEATURES'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.brightness_high_outlined,
                    iconBg: Colors.amber.withOpacity(0.12),
                    iconColor: Colors.amber[800]!,
                    title: 'Desi Workouts',
                    desc: 'Hanuman Dand, Sapate, Gada Swings & more',
                  ),
                  const SizedBox(height: 8),
                  _buildIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.accessibility_new,
                    iconBg: AppColors.secondaryContainer.withOpacity(0.4),
                    iconColor: AppColors.secondary,
                    title: 'Dorm Calisthenics',
                    desc: 'Zero-cost bodyweight progression guides',
                  ),
                  const SizedBox(height: 8),
                  _buildIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.fitness_center,
                    iconBg: Colors.red.withOpacity(0.1),
                    iconColor: Colors.red[800]!,
                    title: 'Gym Workout Split',
                    desc: 'Organized routines in separate categories',
                  ),
                  const SizedBox(height: 8),
                  _buildIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.onetwothree,
                    iconBg: Colors.blue.withOpacity(0.1),
                    iconColor: Colors.blue[800]!,
                    title: 'Reps & Calories Counter',
                    desc: 'Track reps and estimate calorie burn live',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroFeatureRow(
    BuildContext context,
    AppState state, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.translate(title),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                state.translate(desc),
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage1(BuildContext context) {
    return _buildPageLayout(
      context: context,
      badgeText: 'Fueling India',
      badgeColor: AppColors.secondaryContainer.withOpacity(0.6),
      badgeTextColor: AppColors.secondary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: const [
            TextSpan(text: 'Vedic Wisdom,\n'),
            TextSpan(
              text: "Scientific Gains",
              style: TextStyle(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: const [
            TextSpan(text: 'Track protein and cost for every meal. Stay '),
            TextSpan(
              text: 'under ₹100/day',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            TextSpan(text: ' utilizing ancestral nutrition hacks verified by modern sports science.'),
          ],
        ),
      ),
      visual: _buildCardMock(
        context,
        icon: Icons.restaurant,
        iconBg: AppColors.secondaryContainer,
        iconColor: AppColors.secondary,
        tag: 'Budget Hack',
        title: '25g Protein for ₹15',
        imagePlaceholder: 'Sattu Protein Drink illustration',
      ),
    );
  }

  Widget _buildPage2(BuildContext context) {
    return _buildPageLayout(
      context: context,
      badgeText: 'Hostel Cooking',
      badgeColor: AppColors.primaryContainer.withOpacity(0.1),
      badgeTextColor: AppColors.primary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: const [
            TextSpan(text: 'The Electric\n'),
            TextSpan(
              text: 'Kettle Chef',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: const [
            TextSpan(text: 'Recipes curated for hostel living.\n'),
            TextSpan(
              text: 'No stove? No problem.',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
          ],
        ),
      ),
      visual: _buildCardMock(
        context,
        icon: Icons.bolt,
        iconBg: AppColors.primaryContainer.withOpacity(0.15),
        iconColor: AppColors.primary,
        tag: 'Hostel Hack',
        title: 'Kettle Soy Pulao in 10 mins',
        imagePlaceholder: 'Electric Kettle cooking soya chunks',
      ),
    );
  }

  Widget _buildPage3(BuildContext context) {
    return _buildPageLayout(
      context: context,
      badgeText: 'AI Coach',
      badgeColor: Colors.blue.withOpacity(0.1),
      badgeTextColor: Colors.blue,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: const [
            TextSpan(text: 'Meet '),
            TextSpan(
              text: 'Coach Bheem',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: const [
            TextSpan(text: 'Your AI Desi Dietitian. Ask anything about your mess food or local snacks.'),
          ],
        ),
      ),
      visual: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User bubble
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12, right: 32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '"Bhai, is 250g Paneer Butter Masala too much protein?"',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            // Coach bubble
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(left: 32),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.directions_run, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"Focus on the rotis first! Swap 2 Maida Naans for 1 Bajra Roti for better macros."',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildPage4(BuildContext context) {
    return _buildPageLayout(
      context: context,
      badgeText: 'Jugaad Core',
      badgeColor: AppColors.secondaryContainer.withOpacity(0.6),
      badgeTextColor: AppColors.secondary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: const [
            TextSpan(text: 'Jugaad '),
            TextSpan(
              text: 'Community',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: const [
            TextSpan(text: 'Share your budget hacks and see what others are cooking in their dorms.'),
          ],
        ),
      ),
      visual: _buildCardMock(
        context,
        icon: Icons.people_outline,
        iconBg: AppColors.secondaryContainer.withOpacity(0.3),
        iconColor: AppColors.secondary,
        tag: 'Trending Hack',
        title: '"Hostel Oats with Desi Jaggery"',
        imagePlaceholder: 'Indian students sharing food hacks',
      ),
    );
  }

  // Page 5: Height & Weight Input
  Widget _buildPage5(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'HEALTH STATS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tell Us About Yourself',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We use height and weight to calculate your BMI, BMR, and recommended protein and calorie needs.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          // Height Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HEIGHT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      '${_heightInput.round()} cm',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _heightInput,
                  min: 100,
                  max: 220,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceContainerHighest,
                  onChanged: (val) {
                    setState(() {
                      _heightInput = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Weight Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WEIGHT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      '${_weightInput.round()} kg',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _weightInput,
                  min: 30,
                  max: 150,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceContainerHighest,
                  onChanged: (val) {
                    setState(() {
                      _weightInput = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 6: Goal Selection
  Widget _buildPage6(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {
        'title': 'Fat Loss',
        'desc': 'Burn fat, build lean definition. Deficit caloric target.',
        'icon': Icons.trending_down,
        'badge': 'Sasta Deficit',
      },
      {
        'title': 'Muscle Gain',
        'desc': 'Build size, strength and power. Surplus caloric target.',
        'icon': Icons.trending_up,
        'badge': 'Anabolic Bulk',
      },
      {
        'title': 'General Fitness',
        'desc': 'Stay fit, improve stamina. Maintenance target.',
        'icon': Icons.favorite_border,
        'badge': 'Fit & Lean',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'GOAL SELECTOR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What is your target, Champ?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We customize your daily budget calories, protein objectives, and suggested splits matching this goal.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          
          ...goals.map((g) {
            final isSelected = _selectedGoalInput == g['title'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGoalInput = g['title']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer.withOpacity(0.08) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
                      child: Icon(g['icon'] as IconData, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                g['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  g['badge']!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            g['desc']!,
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: g['title']!,
                      groupValue: _selectedGoalInput,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _selectedGoalInput = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Page 7: Calculations & Custom Recommendations
  Widget _buildPage7(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final bmi = state.userBmi ?? 0.0;
    final bmiCat = state.bmiCategory ?? 'Normal';
    final cal = state.dailyCalorieTarget ?? 2000.0;
    final prot = state.proteinGoal;
    final split = state.selectedWorkoutSplit ?? 'Push/Pull/Legs';

    final bmiColor = bmiCat == 'Normal'
        ? Colors.green
        : (bmiCat == 'Underweight' ? Colors.orange : Colors.red);

    List<Map<String, String>> dietPlan = [];
    if (_selectedGoalInput == 'Muscle Gain') {
      dietPlan = [
        {'item': '3 tbsp Sattu + 250ml Milk', 'cost': '₹15', 'prot': '15g Protein'},
        {'item': '50g Soya Chunks boiled', 'cost': '₹10', 'prot': '26g Protein'},
        {'item': '4 Whole Eggs boiled', 'cost': '₹28', 'prot': '24g Protein'},
        {'item': '50g Peanuts roasted', 'cost': '₹5', 'prot': '13g Protein'},
        {'item': '100g Paneer cubes', 'cost': '₹40', 'prot': '18g Protein'},
      ];
    } else if (_selectedGoalInput == 'Fat Loss') {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'YOUR ANABOLIC REPORT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plan Ready, Champ!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 24),

          // Row for BMI & Calories
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BMI SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: bmiColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bmiCat,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bmiColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CALORIC GOAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(
                        '${cal.round()}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      const Text('kcal / day', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Workout Split & Protein Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECOMMENDED SPLIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        split,
                        style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: AppColors.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protein Target: ${prot.round()}g / day',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            split == 'Push/Pull/Legs'
                                ? 'Chest/Shoulders/Triceps (Push) -> Back/Biceps (Pull) -> Legs/Core.'
                                : 'Upper Body (Chest/Back/Arms) -> Lower Body (Legs/Core).',
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Affordable Diet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RECOMMENDED SASTA PROTEIN DIET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                ...dietPlan.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['item']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                          children: const [
                            TextSpan(
                              text: 'Coach Bheem: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            TextSpan(text: '"Bhai, sattu milkshake aur soya chunks se fast recovery hogi. Roti-daal ke sath ye high-protein sources target meet kar denge under ₹100/day!"'),
                          ],
                        ),
                      ),
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

  // Page 8: Sign in with Google or Guest checkout
  Widget _buildPage8(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return _buildPageLayout(
      context: context,
      badgeText: 'FitCraft',
      badgeColor: AppColors.primaryContainer.withOpacity(0.1),
      badgeTextColor: AppColors.primary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: const [
            TextSpan(text: 'FitCraft\n'),
            TextSpan(
              text: 'Sattu Samrat',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      descriptionRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
          children: const [
            TextSpan(text: 'Your journey to legendary strength starts here. Join the '),
            TextSpan(
              text: 'Sattu Samrats',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary),
            ),
            TextSpan(text: ' today.'),
          ],
        ),
      ),
      visual: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.workspace_premium, size: 160, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.emoji_events, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoadingAuth)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoadingAuth = true;
                        });
                        try {
                          if (state.userWeight == null) {
                            state.updateBodyMetrics(_weightInput, _heightInput, _selectedGoalInput);
                          }
                          await state.loginWithGoogle();
                          if (mounted) {
                            AnalyticsService.logEvent('onboarding_complete', {'method': 'google'});
                            Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
                          }
                        } catch (e) {
                          setState(() {
                            _isLoadingAuth = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.onSurface,
                        elevation: 1,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: AppColors.outlineVariant.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                              width: 18,
                              height: 18,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.g_mobiledata,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sign In with Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'or continue as Guest below',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      footerTerms: GestureDetector(
        onTap: () => _showTermsAndPrivacyDialog(context),
        child: const Text(
          'By continuing, you agree to our Terms of Power & Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showTermsAndPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
              maxWidth: 450,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Legal & Privacy Policy',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Privacy Policy',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Information We Collect:\n'
                          '• Google Sign-in: We access your display name, email address, and profile picture to customize your user profile and sync your database records.\n'
                          '• Fitness Data: Weight, height, water intake, calorie logs, and budget entries are tracked. These are stored locally in secure Hive containers and synced to Firebase Firestore if you are logged in.\n'
                          '• Local Progress Photos: Body progress photos are processed locally on your device to run calculations. We do not upload your images to remote servers without explicit permission.\n'
                          '• AI Input: Chats, ingredients, or food logs sent to Coach Bheem/AI Recipe Builder are sent to secure OpenRouter completion endpoints. Conversations are not sold or reused.\n\n'
                          '2. Data Security:\n'
                          'All database operations are encrypted on device and synced over secure HTTPS channels.',
                          style: TextStyle(fontSize: 11.5, height: 1.4, color: Colors.black87),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Terms of Power (Terms of Service)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. App Purpose:\n'
                          'DesiFit provides traditional Indian workout, calisthenics, and budget nutrition suggestions. This content is for general education.\n\n'
                          '2. Medical & Injury Disclaimer:\n'
                          '• Coach Bheem is an AI assistant, not a doctor or a certified physical therapist. Recommendations are generated automatically.\n'
                          '• Perform calisthenics, Akhada swings, and exercises at your own risk. Always perform dynamic warmups and maintain correct posture. DesiFit, its developers, and affiliates are not responsible for any injury, muscle pull, sprain, or health complications.\n\n'
                          '3. Safe Sattu & Soya Consumption:\n'
                          'Always verify diet recommendations with a registered dietitian, especially if you have pre-existing health conditions or food allergies.',
                          style: TextStyle(fontSize: 11.5, height: 1.4, color: Colors.black87),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'I UNDERSTAND, CHAMP',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageLayout({
    required BuildContext context,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required Widget titleRich,
    required Widget descriptionRich,
    required Widget visual,
    Widget? footerTerms,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Top Visual Section
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: visual,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: badgeTextColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          titleRich,
          const SizedBox(height: 12),
          // Description
          descriptionRich,
          const SizedBox(height: 16),
          if (footerTerms != null) ...[
            Center(child: footerTerms),
            const SizedBox(height: 8),
          ],
          const Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCardMock(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String tag,
    required String title,
    required String imagePlaceholder,
  }) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.grain, size: 300, color: AppColors.primary),
            ),
          ),
          Center(
            child: Icon(icon, size: 80, color: iconColor.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
