import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/routing/routing.dart';
import '../../../planner/presentation/screens/planner_screen.dart';

class ToolboxGrid extends StatelessWidget {
  const ToolboxGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth > 600;
        final int crossAxisCount = isWide ? 4 : 3;

        return Semantics(
          container: true,
          label: '${state.translate('SWADESHI TOOLBOX')}. ${state.translate('Nine tools')}',
          child: Column(
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
                AestheticToolCard(
                  label: state.translate('Sasta Protein'),
                  sublabel: state.translate('Cost/g meter'),
                  icon: Icons.calculate_rounded,
                  themeColor: AppColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.sastaCalculator);
                  },
                  index: 0,
                ),
                AestheticToolCard(
                  label: state.translate('Grocery Plan'),
                  sublabel: state.translate('Weekly ₹100/d'),
                  icon: Icons.shopping_basket_rounded,
                  themeColor: AppColors.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.groceryPlanner);
                  },
                  index: 1,
                ),
                AestheticToolCard(
                  label: state.translate('Akhada Sandbox'),
                  sublabel: state.translate('Swing Gada'),
                  icon: Icons.sports_martial_arts,
                  themeColor: Colors.orange.shade800,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.akhadaSandbox);
                  },
                  index: 2,
                ),
                AestheticToolCard(
                  label: state.translate('AI Calorie Log'),
                  sublabel: state.translate('Llama-3 logger'),
                  icon: Icons.fastfood_rounded,
                  themeColor: Colors.amber.shade800,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.calorieCounter);
                  },
                  index: 3,
                ),
                AestheticToolCard(
                  label: state.translate('AI Body Scan'),
                  sublabel: state.translate('Pose & Symmetry'),
                  icon: Icons.center_focus_strong_rounded,
                  themeColor: Colors.teal,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.progressScan);
                  },
                  index: 4,
                ),
                AestheticToolCard(
                  label: state.translate('Calisthenics'),
                  sublabel: state.translate('Dorm workout'),
                  icon: Icons.sports_gymnastics,
                  themeColor: Colors.blue.shade800,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.workout, arguments: 'Home');
                  },
                  index: 5,
                ),
                AestheticToolCard(
                  label: state.translate('Health Feed'),
                  sublabel: state.translate('Hacks & Ayurveda'),
                  icon: Icons.menu_book_rounded,
                  themeColor: Colors.brown.shade700,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.healthFeed);
                  },
                  index: 6,
                ),
                AestheticToolCard(
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
                AestheticToolCard(
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
        ),
        );
      },
    );
  }
}

class AestheticToolCard extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color themeColor;
  final VoidCallback onTap;
  final int index;

  const AestheticToolCard({
    super.key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.themeColor,
    required this.onTap,
    required this.index,
  });

  @override
  State<AestheticToolCard> createState() => _AestheticToolCardState();
}

class _AestheticToolCardState extends State<AestheticToolCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _entryController;
  late Animation<double> _hoverScale;
  late Animation<double> _entryOpacity;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _hoverScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entrySlide,
        child: MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          child: ScaleTransition(
            scale: _hoverScale,
            child: Semantics(
              button: true,
              label: '${widget.label}. ${widget.sublabel}. Double tap to open',
              child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.themeColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.themeColor, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.sublabel,
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
