import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../widgets/affiliate_banner.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/greeting_header.dart';
import '../widgets/matka_hydration_widget.dart';
import '../widgets/diet_tracker_card.dart';
import '../widgets/budget_tracker_card.dart';
import '../widgets/health_profile_card.dart';
import '../widgets/toolbox_grid.dart';
import '../widgets/quick_add_grid.dart';
import '../widgets/stories_tray.dart';
import '../widgets/swadeshi_hero_banner.dart';
import '../../../../core/ads/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTrackerIndex = 0;

  Widget _buildTrackerTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
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
                      color: Colors.black.withValues(alpha: 0.05),
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












  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final clampedTextScaler = mediaQueryData.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: clampedTextScaler,
      ),
      child: Consumer<AppState>(
        builder: (context, state, child) {
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
                GreetingHeader(state: state),
                const SizedBox(height: 24),
                SwadeshiHeroBanner(state: state),
                const SizedBox(height: 24),

                StoriesTray(state: state),
                const SizedBox(height: 24),

                // 2. Combined Daily Tracker Hub
                _buildTrackerTabs(context),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTrackerIndex == 0
                      ? const DietTrackerCard()
                      : _selectedTrackerIndex == 1
                          ? const BudgetTrackerCard()
                          : const MatkaHydrationWidget(key: ValueKey('hydration')),
                ),
                const SizedBox(height: 24),

                // 3. Expandable My Health Profile Card
                const HealthProfileCard(),
                const SizedBox(height: 24),

                // 4. Swadeshi Toolbox
                const ToolboxGrid(),
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
                const QuickAddGrid(),
                const SizedBox(height: 32),

                const AffiliateBanner(),
                const SizedBox(height: 24),
                // Sponsor Ad Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
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
