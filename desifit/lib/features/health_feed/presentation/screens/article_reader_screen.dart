import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/analytics_service.dart';
import '../../domain/models/article.dart';

class ArticleReaderScreen extends StatefulWidget {
  final DesiArticle article;
  final VoidCallback onBookmarkToggle;

  const ArticleReaderScreen({
    super.key,
    required this.article,
    required this.onBookmarkToggle,
  });

  @override
  State<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends State<ArticleReaderScreen> {
  late bool _isBookmarked;
  int? _selectedQuizIndex;
  bool _quizAnswered = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.isBookmarked;
    AnalyticsService.logEvent('screen_view', {
      'screen_name': 'article_reader',
      'article_id': widget.article.id,
      'article_title': widget.article.title,
    });
  }

  void _handleBookmarkTap() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    widget.onBookmarkToggle();
  }

  List<String> _generateDynamicRecapPoints(DesiArticle article) {
    if (article.id == 'art_1') {
      return [
        'Sattu is ₹10 vs Whey is ₹100. Sattu is slow digesting, whey is fast. Milk completes Sattu\'s amino acids!',
        'Use it as a pre-workout fuel or meal replacement. It digests slowly and keeps you full for lectures.',
        'Shake it in a peanut butter jar with cardamom, cold milk, and honey. Easy hostel hack!'
      ];
    } else if (article.id == 'art_2') {
      return [
        'Phytoestrogens in soya are 1,000x weaker than estrogen. Normal soy intake (50-100g) has zero testosterone impact.',
        'Soya chunks are 50% protein and super cheap. Avoid Whatsapp University fears; soy is your muscle friend!',
        'Soak chunks in a kettle for 5 mins, add chaat masala and lemon. Ready under ₹10!'
      ];
    } else if (article.id == 'art_3') {
      return [
        'Ashwagandha reduces cortisol by up to 30%, which stops muscle breakdown and accelerates recovery.',
        'It doubles strength gains and improves deep sleep cycles. Have 1/2 tsp with warm milk at night.',
        'Choose standard root extract. It keeps you in a recovery state even on hostel stress.'
      ];
    }

    final List<String> points = [];
    final sections = article.sections;

    String getFirstSentence(String text) {
      if (text.isEmpty) return '';
      int endIdx = -1;
      for (int i = 0; i < text.length; i++) {
        final char = text[i];
        if (char == '.' || char == '!' || char == '?') {
          endIdx = i;
          break;
        }
      }
      if (endIdx == -1) {
        return text.trim();
      }
      return text.substring(0, endIdx + 1).trim();
    }

    for (int i = 0; i < 3; i++) {
      if (i < sections.length && sections[i].text.isNotEmpty) {
        final sentence = getFirstSentence(sections[i].text);
        if (sentence.isNotEmpty) {
          points.add(sentence);
        }
      }
    }

    if (points.length < 3 && article.hostelHack.isNotEmpty) {
      final sentence = getFirstSentence(article.hostelHack);
      if (sentence.isNotEmpty && !points.contains(sentence)) {
        points.add(sentence);
      }
    }

    if (points.length < 3 && article.subtitle.isNotEmpty) {
      final sentence = getFirstSentence(article.subtitle);
      if (sentence.isNotEmpty && !points.contains(sentence)) {
        points.add(sentence);
      }
    }

    while (points.length < 3) {
      if (points.isEmpty) {
        points.add(article.title);
      } else {
        points.add(points[0]);
      }
    }

    return points;
  }

  void _showAiRecapBottomSheet(BuildContext context) {
    final points = _generateDynamicRecapPoints(widget.article);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryContainer,
                    ),
                    child: const Center(
                      child: Text('💪', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COACH BHEEM',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const Text(
                        'AI Desi Dietitian • Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Inter',
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Yo Champ! Here is your quick AI recap of the article:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildBulletPoint(
                context,
                '1',
                points[0],
              ),
              const SizedBox(height: 12),
              _buildBulletPoint(
                context,
                '2',
                points[1],
              ),
              const SizedBox(height: 12),
              _buildBulletPoint(
                context,
                '3',
                points[2],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('GOT IT, COACH!'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(BuildContext context, String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryContainer,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.4,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Collapsible Image Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? AppColors.primaryContainer : Colors.white,
                        size: 20,
                      ),
                      onPressed: _handleBookmarkTap,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.article.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Article Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Read Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.article.category == 'Gym Hacks'
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : (widget.article.category == 'Ayurvedic'
                                      ? AppColors.secondary.withValues(alpha: 0.1)
                                      : Colors.blue.shade900.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.article.category.toUpperCase(),
                              style: TextStyle(
                                color: widget.article.category == 'Gym Hacks'
                                    ? AppColors.primary
                                    : (widget.article.category == 'Ayurvedic'
                                        ? AppColors.secondary
                                        : Colors.blue.shade800),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            widget.article.readTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        widget.article.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              height: 1.25,
                              color: AppColors.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Text(
                        widget.article.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Inter',
                              color: AppColors.onSurfaceVariant,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Divider line using background shift instead of 1px border lines
                      Container(
                        width: double.infinity,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Sections
                      ...widget.article.sections.map((sec) => _buildSection(context, sec)),
                      
                      const SizedBox(height: 12),
                      
                      // Hostel Hack Alert Box
                      _buildHostelHackBox(context),
                      
                      const SizedBox(height: 32),
                      
                      // Interactive Quiz/Poll Widget
                      _buildQuizWidget(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Floating Quick Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomQuickActionBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, ArticleSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.heading != null) ...[
          Text(
            section.heading!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          section.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                fontSize: 15,
                height: 1.6,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHostelHackBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'HOSTEL ROOM HACK',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.article.hostelHack,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizWidget(BuildContext context) {
    final quiz = widget.article.quiz;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'SCIENCE-BACKED TRIVIA',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quiz.question,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1.3,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Options List
          ...List.generate(quiz.options.length, (idx) {
            final option = quiz.options[idx];
            
            Color optionBg = AppColors.surfaceContainerLow;
            Color optionBorder = Colors.transparent;
            Color textOptionColor = AppColors.onSurface;
            IconData? optionIcon;
            
            if (_quizAnswered) {
              if (idx == quiz.correctAnswerIndex) {
                optionBg = AppColors.secondary.withValues(alpha: 0.12);
                optionBorder = AppColors.secondary.withValues(alpha: 0.4);
                textOptionColor = AppColors.secondary;
                optionIcon = Icons.check_circle_outline;
              } else if (_selectedQuizIndex == idx) {
                optionBg = const Color(0xFFBA1A1A).withValues(alpha: 0.1);
                optionBorder = const Color(0xFFBA1A1A).withValues(alpha: 0.3);
                textOptionColor = const Color(0xFFBA1A1A);
                optionIcon = Icons.error_outline;
              }
            } else if (_selectedQuizIndex == idx) {
              optionBg = AppColors.primary.withValues(alpha: 0.1);
              optionBorder = AppColors.primary.withValues(alpha: 0.4);
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: _quizAnswered 
                    ? null 
                    : () {
                        setState(() {
                          _selectedQuizIndex = idx;
                          _quizAnswered = true;
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: optionBorder, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: _selectedQuizIndex == idx || (_quizAnswered && idx == quiz.correctAnswerIndex)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: textOptionColor,
                          ),
                        ),
                      ),
                      if (optionIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(optionIcon, color: textOptionColor, size: 18),
                      ]
                    ],
                  ),
                ),
              ),
            );
          }),
          
          // Explanation section with Fade/Size Animation
          if (_quizAnswered) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedQuizIndex == quiz.correctAnswerIndex
                            ? Icons.thumb_up
                            : Icons.info_outline,
                        color: _selectedQuizIndex == quiz.correctAnswerIndex
                            ? AppColors.secondary
                            : Colors.orange[800],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedQuizIndex == quiz.correctAnswerIndex
                            ? 'CORRECT!'
                            : 'FACT CHECK',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _selectedQuizIndex == quiz.correctAnswerIndex
                              ? AppColors.secondary
                              : Colors.orange[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quiz.explanation,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomQuickActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back shortcut
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              
              // Bookmark
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? AppColors.primary : Colors.grey,
                  size: 24,
                ),
                onPressed: _handleBookmarkTap,
              ),
              
              // Share
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.grey, size: 24),
                onPressed: () {
                  AnalyticsService.logEvent('article_shared', {
                    'article_id': widget.article.id,
                    'article_title': widget.article.title,
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sharing link copied to clipboard!', style: TextStyle(fontFamily: 'Inter')),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              
              // Coach Recap Button
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAiRecapBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(140, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  label: const Text(
                    'AI RECAP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
