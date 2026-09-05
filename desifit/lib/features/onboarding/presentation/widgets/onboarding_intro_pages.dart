import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';

// State-free onboarding page content, extracted from onboarding_screen.dart.
// Everything here renders from its arguments/context only - no page state.

/// Builds the intro page (page 0) shown at the start of onboarding.
Widget buildOnboardingIntroPage(BuildContext context) {
  final state = Provider.of<AppState>(context);
    return buildOnboardingPageLayout(
      context: context,
      badgeText: state.translate('SWADESHI STRENGTH'),
      badgeColor: AppColors.primary.withValues(alpha: 0.12),
      badgeTextColor: AppColors.primary,
      titleRich: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
          children: [
            TextSpan(text: '${state.translate("India's First Desi Workout")}\n'),
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
      visual: buildOnboardingIntroVisual(context, state),
    );
  }

  Widget buildOnboardingIntroVisual(BuildContext context, AppState state) {
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
                color: AppColors.primary.withValues(alpha: 0.08),
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
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
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
                  buildOnboardingIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.brightness_high_outlined,
                    iconBg: Colors.amber.withValues(alpha: 0.12),
                    iconColor: Colors.amber[800]!,
                    title: 'Desi Workouts',
                    desc: 'Hanuman Dand, Sapate, Gada Swings & more',
                  ),
                  const SizedBox(height: 8),
                  buildOnboardingIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.accessibility_new,
                    iconBg: AppColors.secondaryContainer.withValues(alpha: 0.4),
                    iconColor: AppColors.secondary,
                    title: 'Dorm Calisthenics',
                    desc: 'Zero-cost bodyweight progression guides',
                  ),
                  const SizedBox(height: 8),
                  buildOnboardingIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.fitness_center,
                    iconBg: Colors.red.withValues(alpha: 0.1),
                    iconColor: Colors.red[800]!,
                    title: 'Gym Workout Split',
                    desc: 'Organized routines in separate categories',
                  ),
                  const SizedBox(height: 8),
                  buildOnboardingIntroFeatureRow(
                    context,
                    state,
                    icon: Icons.onetwothree,
                    iconBg: Colors.blue.withValues(alpha: 0.1),
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

  Widget buildOnboardingIntroFeatureRow(
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


  Widget buildOnboardingPage1(BuildContext context) {
    return buildOnboardingPageLayout(
      context: context,
      badgeText: 'Fueling India',
      badgeColor: AppColors.secondaryContainer.withValues(alpha: 0.6),
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
      visual: buildOnboardingCardMock(
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

  Widget buildOnboardingPage2(BuildContext context) {
    return buildOnboardingPageLayout(
      context: context,
      badgeText: 'Hostel Cooking',
      badgeColor: AppColors.primaryContainer.withValues(alpha: 0.1),
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
      visual: buildOnboardingCardMock(
        context,
        icon: Icons.bolt,
        iconBg: AppColors.primaryContainer.withValues(alpha: 0.15),
        iconColor: AppColors.primary,
        tag: 'Hostel Hack',
        title: 'Kettle Soy Pulao in 10 mins',
        imagePlaceholder: 'Electric Kettle cooking soya chunks',
      ),
    );
  }

  Widget buildOnboardingPage3(BuildContext context) {
    return buildOnboardingPageLayout(
      context: context,
      badgeText: 'AI Coach',
      badgeColor: Colors.blue.withValues(alpha: 0.1),
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

  Widget buildOnboardingPage4(BuildContext context) {
    return buildOnboardingPageLayout(
      context: context,
      badgeText: 'Jugaad Core',
      badgeColor: AppColors.secondaryContainer.withValues(alpha: 0.6),
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
      visual: buildOnboardingCardMock(
        context,
        icon: Icons.people_outline,
        iconBg: AppColors.secondaryContainer.withValues(alpha: 0.3),
        iconColor: AppColors.secondary,
        tag: 'Trending Hack',
        title: '"Hostel Oats with Desi Jaggery"',
        imagePlaceholder: 'Indian students sharing food hacks',
      ),
    );
  }

  // Page 5: Height & Weight Input

/// Shared page scaffolding: logo, visual, badge, title, description.
  Widget buildOnboardingPageLayout({
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


/// Card-mock visual used by pages 1, 2 and 4.
  Widget buildOnboardingCardMock(
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
            child: Icon(icon, size: 80, color: iconColor.withValues(alpha: 0.2)),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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


