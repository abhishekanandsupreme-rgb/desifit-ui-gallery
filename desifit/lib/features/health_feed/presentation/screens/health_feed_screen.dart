import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../domain/models/article.dart';
import 'article_reader_screen.dart';
import '../../../../core/ads/banner_ad_widget.dart';

class HealthFeedScreen extends StatefulWidget {
  const HealthFeedScreen({Key? key}) : super(key: key);

  @override
  State<HealthFeedScreen> createState() => _HealthFeedScreenState();
}

class _HealthFeedScreenState extends State<HealthFeedScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  void _toggleBookmark(String id) {
    final state = Provider.of<AppState>(context, listen: false);
    state.toggleDesiArticleBookmark(id);
    
    final article = state.desiArticles.firstWhere((a) => a.id == id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          article.isBookmarked ? 'Article bookmarked!' : 'Bookmark removed.',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: article.isBookmarked ? AppColors.secondary : Colors.grey[800],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final state = Provider.of<AppState>(context);
    final List<DesiArticle> articles = state.desiArticles;
    
    // Filtered list
    final filtered = articles.where((article) {
      final matchesCategory = _selectedCategory == 'All' || 
          (_selectedCategory == 'Bookmarked' ? article.isBookmarked : article.category == _selectedCategory);
      final matchesSearch = article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
    
    // Find featured article
    final DesiArticle? featuredArticle = _searchQuery.isEmpty && _selectedCategory == 'All'
        ? articles.firstWhere((a) => a.isFeatured, orElse: () => articles.first)
        : null;
        
    // List of articles without the featured one if showing featured
    final displayArticles = featuredArticle != null
        ? filtered.where((a) => a.id != featuredArticle.id).toList()
        : filtered;


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Desi Health Feed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.onSurfaceVariant),
            onPressed: () {
              // Show filter for bookmarked articles only
              setState(() {
                if (_selectedCategory == 'Bookmarked') {
                  _selectedCategory = 'All';
                } else {
                  _selectedCategory = 'Bookmarked';
                }
              });
            },
            color: _selectedCategory == 'Bookmarked' ? AppColors.primary : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            
            // Set margins depending on screen size
            final double horizontalPadding = maxWidth > 900 ? 48.0 : (maxWidth > 600 ? 32.0 : 20.0);
            
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding, 
                right: horizontalPadding, 
                top: 8, 
                bottom: 40
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search & Filter header
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  
                  // Category chips
                  _buildCategorySelector(),
                  const SizedBox(height: 24),

                  // If showing Bookmarked category and none exist
                  if (_selectedCategory == 'Bookmarked' && _filteredBookmarkedArticles().isEmpty)
                    _buildEmptyState('No bookmarked articles yet. Keep exploring!')
                  else if (filtered.isEmpty)
                    _buildEmptyState('No articles found matching your query.')
                  else ...[
                    // Featured Article (only if no query and showing 'All' or appropriate category)
                    if (featuredArticle != null && _selectedCategory != 'Bookmarked') ...[
                      Text(
                        'FEATURED STORY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeaturedCard(context, featuredArticle),
                      const SizedBox(height: 32),
                    ],

                    // Latest / Feed Section Header
                    Text(
                      _selectedCategory == 'Bookmarked' 
                          ? 'YOUR BOOKMARKS' 
                          : 'LATEST KNOWLEDGE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 12),

                    _buildResponsiveFeed(context, displayArticles, maxWidth),
                  ],
                  const SizedBox(height: 28),
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
              ),
            );
          },
        ),
      ),
    );
  }

  List<DesiArticle> _filteredBookmarkedArticles() {
    final state = Provider.of<AppState>(context, listen: false);
    return state.desiArticles.where((a) => a.isBookmarked).toList();
  }


  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: AppColors.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Inter',
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (_selectedCategory == 'Bookmarked') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('EXPLORE ARTICLES'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search gym hacks, ayurveda, myths...',
          hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Inter'),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['All', 'Gym Hacks', 'Ayurvedic', 'Mythbusters', 'Bookmarked'];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _AnimatedCategoryChip(
              label: cat,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, DesiArticle article) {
    return _ScalePressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleReaderScreen(
            article: article,
            onBookmarkToggle: () => _toggleBookmark(article.id),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.15),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          article.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.readTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      _AnimatedBookmarkButton(
                        isBookmarked: article.isBookmarked,
                        onTap: () => _toggleBookmark(article.id),
                        lightBg: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: article.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    article.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Read action indicator
                  Row(
                    children: [
                      Text(
                        'Read Full Article',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveFeed(BuildContext context, List<DesiArticle> articles, double maxWidth) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Determine column count based on width
    int columns = 1;
    if (maxWidth > 950) {
      columns = 3;
    } else if (maxWidth > 600) {
      columns = 2;
    }

    if (columns == 1) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildFeedCard(context, articles[index]);
        },
      );
    } else {
      // Calculate responsive spacing and aspect ratio
      final double spacing = maxWidth > 950 ? 20.0 : 16.0;
      final double childAspectRatio = maxWidth > 950 ? 0.76 : 0.82;
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return _buildFeedGridCard(context, articles[index]);
        },
      );
    }
  }

  Widget _buildFeedCard(BuildContext context, DesiArticle article) {
    return _ScalePressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleReaderScreen(
            article: article,
            onBookmarkToggle: () => _toggleBookmark(article.id),
          ),
        ),
      ),
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left: Thumbnail
            Stack(
              children: [
                Container(
                  width: 110,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: article.category == 'Gym Hacks'
                          ? AppColors.primary.withOpacity(0.9)
                          : (article.category == 'Ayurvedic'
                              ? AppColors.secondary.withOpacity(0.9)
                              : Colors.blue.shade800.withOpacity(0.9)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Right: Content details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article.readTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Read more',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _toggleBookmark(article.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: article.isBookmarked ? AppColors.primary : Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedGridCard(BuildContext context, DesiArticle article) {
    return _ScalePressable(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleReaderScreen(
            article: article,
            onBookmarkToggle: () => _toggleBookmark(article.id),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.15),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Category Tag
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: article.category == 'Gym Hacks'
                            ? AppColors.primary
                            : (article.category == 'Ayurvedic'
                                ? AppColors.secondary
                                : Colors.blue.shade800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.readTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _AnimatedBookmarkButton(
                      isBookmarked: article.isBookmarked,
                      onTap: () => _toggleBookmark(article.id),
                      lightBg: false,
                      size: 28,
                    ),
                  )
                ],
              ),
            ),
            
            // Text Details
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.onSurface,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                            fontSize: 12,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Text(
                          'Read article',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// HELPER ANIMATED COMPONENT WIDGETS
// ----------------------------------------------------

class _AnimatedCategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedCategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AnimatedCategoryChip> createState() => _AnimatedCategoryChipState();
}

class _AnimatedCategoryChipState extends State<_AnimatedCategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : AppColors.outlineVariant.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScalePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScalePressable({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ScalePressable> createState() => _ScalePressableState();
}

class _ScalePressableState extends State<_ScalePressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedBookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;
  final bool lightBg;
  final double size;

  const _AnimatedBookmarkButton({
    Key? key,
    required this.isBookmarked,
    required this.onTap,
    this.lightBg = true,
    this.size = 36,
  }) : super(key: key);

  @override
  State<_AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<_AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = widget.isBookmarked ? AppColors.primary : (widget.lightBg ? Colors.grey[700]! : Colors.white);
    
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.lightBg
                ? AppColors.surfaceContainerLow
                : Colors.black.withOpacity(0.5),
            border: widget.lightBg
                ? Border.all(color: AppColors.outlineVariant.withOpacity(0.15), width: 1)
                : null,
          ),
          child: Icon(
            widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: buttonColor,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}
