import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/openrouter_service.dart';
import '../../../../core/network/analytics_service.dart';
import '../../../../core/ads/ad_service.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'Only Kettle', 'No Cook', 'Under ₹30', 'High Protein'];

  @override
  void initState() {
    super.initState();
    AdService.loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        // Filter logic
        final filteredRecipes = state.recipes.where((recipe) {
          final matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              recipe.desc.toLowerCase().contains(_searchQuery.toLowerCase());
          
          if (!matchesSearch) return false;
          if (_activeFilter == 'All') return true;
          if (_activeFilter == 'Only Kettle') return recipe.isKettle;
          if (_activeFilter == 'No Cook') return recipe.tag.toLowerCase() == 'no cook';
          if (_activeFilter == 'Under ₹30') return recipe.cost <= 30;
          if (_activeFilter == 'High Protein') return recipe.protein >= 15;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hostel Recipe Engine',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // Filter Chips (Horizontal Scroll)
                    _buildFilterChips(),
                    const SizedBox(height: 12),

                    // Featured & Main Recipe Cards
                    if (filteredRecipes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48.0),
                          child: Text(
                            'No recipes found match your search.',
                            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    else ...[
                      // If first element exists, show as large featured card
                      _buildFeaturedCard(context, filteredRecipes[0]),
                      const SizedBox(height: 20),

                      // Rest of the list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredRecipes.length - 1,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index + 1];
                          return _buildRecipeListItem(context, recipe);
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    // Bento Mini Cards
                    _buildBentoMiniGrid(context),
                  ],
                ),
              ),

              // Floating Action Button
              Positioned(
                right: 20,
                bottom: 104, // Height above bottom bar
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (state.isAiRecipeLimitReached) {
                      _showRecipeAdModal(context, state);
                    } else {
                      _showRecipeGeneratorDialog(context, state);
                    }
                  },
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI Recipe Builder'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
          if (val.trim().length >= 3) {
            AnalyticsService.logEvent('recipe_searched', {'query': val.trim()});
          }
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.outline),
          hintText: 'Search budget meals...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.outline),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isActive,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isActive ? Colors.transparent : AppColors.outlineVariant.withOpacity(0.3),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _activeFilter = filter;
                  });
                  AnalyticsService.logEvent('recipe_filter_selected', {'filter': filter});
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, RecipeItem recipe) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                color: AppColors.surfaceContainerHigh,
                child: const Center(
                  child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recipe.tag.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      '₹${recipe.cost.toInt()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.desc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.timeMins} mins',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.protein.toInt()}g Protein',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showRecipeDetailDialog(context, recipe),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Cook Now'),
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

  Widget _buildRecipeListItem(BuildContext context, RecipeItem recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecipeDetailDialog(context, recipe),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fastfood_outlined, color: AppColors.outline),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipe.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${recipe.cost.toInt()}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${recipe.protein.toInt()}g Protein',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoMiniGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.trending_down, size: 14, color: Colors.blue),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Cheapest Choice', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    Text('Boiled Egg Chaat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('₹12 / 10g Protein', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_fire_department, size: 14, color: AppColors.secondary),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('High Calorie', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    Text('Curd Rice Maggi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('₹22 / Quick Energy', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showReportRecipeDialog(BuildContext context, RecipeItem recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Report Recipe?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to report "${recipe.title}" as containing inaccurate ingredients, unsafe cooking methods, or incorrect macros?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                debugPrint('AI Recipe reported: "${recipe.title}"');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Thank you. Recipe reported for quality review.', style: TextStyle(fontFamily: 'Inter')),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: const Text('REPORT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRecipeDetailDialog(BuildContext context, RecipeItem recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.tag,
                        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '₹${recipe.cost.toInt()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, color: Colors.grey),
                      tooltip: 'Report Inaccurate Recipe',
                      onPressed: () => _showReportRecipeDialog(context, recipe),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.desc,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Text('Cook time: ${recipe.timeMins}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    const Icon(Icons.fitness_center, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Text('Protein: ${recipe.protein.toInt()}g', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Step-by-Step Instructions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.steps.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recipe.steps[index],
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // AI Disclaimer Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Recipe and nutrition values are estimated by AI. Verify ingredients for food allergies and consult a health expert if needed.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Log the meal to app state
                    final state = Provider.of<AppState>(context, listen: false);
                    state.addCustomMeal(recipe.title, 'Lunch', recipe.cost, recipe.protein);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged ${recipe.title} to planner!')),
                    );
                  },
                  child: const Text('Log Cooked Meal'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecipeGeneratorDialog(BuildContext context, AppState state) {
    final TextEditingController ingredientsController = TextEditingController();
    bool onlyKettle = false;
    bool under30 = false;
    bool generating = false;

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
                    'AI Hostel Recipe Builder',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                   const Text('Enter the ingredients available in your kitchen or hostel room, and we will generate a high-protein recipe for you! Note: AI recipes are generated automatically and must be verified for safety.'),
                  const SizedBox(height: 16),
                  
                  // Ingredients Input
                  TextField(
                    controller: ingredientsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerHighest,
                      hintText: 'e.g., sattu, banana, oats, peanut butter, egg, maggi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Toggle Switches
                  CheckboxListTile(
                    title: const Text('Limit to Electric Kettle Cooking Only'),
                    value: onlyKettle,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        onlyKettle = val ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Keep Budget strictly under ₹30'),
                    value: under30,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() {
                        under30 = val ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Build Button
                  ElevatedButton(
                    onPressed: generating
                        ? null
                        : () async {
                            final ingredients = ingredientsController.text.trim();
                            if (ingredients.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter at least one ingredient.')),
                              );
                              return;
                            }

                            if (state.isAiRecipeLimitReached) {
                              Navigator.pop(context);
                              _showRecipeAdModal(context, state);
                              return;
                            }

                            setDialogState(() {
                              generating = true;
                            });

                            // Generate recipe via OpenRouter
                            final generated = await OpenRouterService.generateRecipe(
                              ingredients: ingredients,
                              onlyKettle: onlyKettle,
                              under30: under30,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (generated != null) {
                                state.addGeneratedRecipe(generated);
                                state.incrementAiRecipeCount();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Generated ${generated.title} successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to generate recipe. Try again!')),
                                );
                              }
                            }
                          },
                    child: generating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Generate Recipe'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRecipeAdModal(BuildContext context, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Unlock Recipe Builder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Watch a quick video to unlock 3 more custom recipe generations with Coach Bheem's AI!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          AdService.showRewardedAd(
                            onUserEarnedReward: (reward) {
                              state.unlockAiRecipe();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Congratulations! 3 more AI recipe generations unlocked!',
                                    style: TextStyle(fontFamily: 'Inter'),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            onAdDismissed: () {},
                          );
                        },
                        child: const Text(
                          'WATCH VIDEO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
