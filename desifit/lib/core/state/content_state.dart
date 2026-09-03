import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import '../storage/local_storage.dart';
import '../network/analytics_service.dart';
import '../network/openrouter_service.dart';
import '../../features/health_feed/domain/models/article.dart';
import '../../features/health_feed/domain/data/mock_articles.dart';
import 'models.dart';

class ContentState extends ChangeNotifier {
  List<FitnessStory> _stories = [];
  List<HealthFlashcard> _flashcards = [];
  List<HealthArticle> _articles = [];
  List<DesiArticle> _desiArticles = [];
  List<ProgressPhoto> _progressPhotos = [];
  int _currentFlashcardIndex = 0;
  bool _isGeneratingArticle = false;
  bool _isAnalyzingPhoto = false;

  List<FitnessStory> get stories => _stories;
  List<HealthFlashcard> get flashcards => _flashcards;
  List<HealthArticle> get articles => _articles;
  List<DesiArticle> get desiArticles => _desiArticles;
  List<ProgressPhoto> get progressPhotos => _progressPhotos;
  int get currentFlashcardIndex => _currentFlashcardIndex;
  bool get isGeneratingArticle => _isGeneratingArticle;
  bool get isAnalyzingPhoto => _isAnalyzingPhoto;

  // Callbacks
  Function(String, String)? _onCelebration;

  void setCallbacks({required Function(String, String) onCelebration}) {
    _onCelebration = onCelebration;
  }

  void initFromCache({
    required List<HealthArticle> articles,
    required List<ProgressPhoto> progressPhotos,
    required List<DesiArticle> desiArticles,
  }) {
    _articles = articles;
    _progressPhotos = progressPhotos;
    _desiArticles = desiArticles;

    if (_articles.isEmpty) {
      _loadDefaultArticles();
    }
    if (_desiArticles.isEmpty) {
      _desiArticles = List.from(mockArticles);
      LocalStorage.saveCachedDesiArticles(_desiArticles);
    }
    if (_progressPhotos.isEmpty) {
      _loadDefaultProgressPhotos();
    }

    _loadDefaultStories();
    _loadDefaultFlashcards();
    _loadDefaultProgress();
  }

  void flipFlashcard(int index) {
    if (index >= 0 && index < _flashcards.length) {
      final card = _flashcards[index];
      card.isFlipped = !card.isFlipped;
      
      AnalyticsService.logEvent('flashcard_flipped', {
        'flashcard_id': card.id,
        'myth': card.myth,
        'category': card.category,
        'is_flipped_to_fact': card.isFlipped,
      });
      
      notifyListeners();
    }
  }

  void nextFlashcard() {
    _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _flashcards.length;
    for (var f in _flashcards) {
      f.isFlipped = false;
    }
    notifyListeners();
  }

  void markArticleAsRead(String id) {
    final index = _articles.indexWhere((a) => a.id == id);
    if (index != -1) {
      _articles[index].isRead = true;
      LocalStorage.saveCachedArticles(_articles);
      notifyListeners();
    }
  }

  Future<void> generateNewArticle({String? category, String? topic, required bool isAiArticleLimitReached}) async {
    if (isAiArticleLimitReached) {
      debugPrint('Article limit reached, shielding OpenRouter API costs.');
      return;
    }
    _isGeneratingArticle = true;
    notifyListeners();

    try {
      final newArticle = await OpenRouterService.generateHealthArticle(
        category: category,
        topic: topic,
      );
      if (newArticle != null) {
        _articles.insert(0, newArticle);
        LocalStorage.saveCachedArticles(_articles);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isGeneratingArticle = false;
      notifyListeners();
    }
  }

  void toggleDesiArticleBookmark(String id) {
    final idx = _desiArticles.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _desiArticles[idx].isBookmarked = !_desiArticles[idx].isBookmarked;
      LocalStorage.saveCachedDesiArticles(_desiArticles);
      notifyListeners();
    }
  }

  Future<void> captureProgressPhoto(String base64Image) async {
    _isAnalyzingPhoto = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2500));

    double bodyFat = 17.5;
    int symmetry = 82;
    int vascularity = 5;
    int posture = 86;

    if (_progressPhotos.isNotEmpty) {
      final last = _progressPhotos.last;
      bodyFat = (last.bodyFat - 0.1 - Random().nextDouble() * 0.3).clamp(10.0, 30.0);
      symmetry = (last.symmetryScore + 1 + Random().nextInt(3)).clamp(50, 100);
      vascularity = (last.vascularity + (Random().nextDouble() > 0.6 ? 1 : 0)).clamp(1, 10);
      posture = (last.postureScore + 1 + Random().nextInt(2)).clamp(50, 100);
    }

    final feedbacks = [
      'Gains lookin solid, Bhai! Chest line clear ho rahi hai aur posture pehle se kafi stable dikh rha hai. Sattu power chal rahi hai!',
      'Vascularity up hai, Champ! Forearms pe veins pop hona shuru ho gayi hain. Shoulder symmetry is improving, bas drop sets continue rakho.',
      'Symmetric posture is on point! Back alignment deadlifts ki wajah se perfect posture de rahi hai. Fat burn ho rha hai, sasta protein rocks!',
      'Body fat drops are real! Abs section me clarity visible hai. Hostel recipe engine ka soya pulao muscle structure solid kar rha hai!',
    ];
    final selectedFeedback = feedbacks[Random().nextInt(feedbacks.length)];
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year}';

    final newPhoto = ProgressPhoto(
      id: 'photo_${now.millisecondsSinceEpoch}',
      imagePath: base64Image,
      dateStr: formattedDate,
      bodyFat: double.parse(bodyFat.toStringAsFixed(1)),
      symmetryScore: symmetry,
      vascularity: vascularity,
      postureScore: posture,
      feedback: selectedFeedback,
    );

    _progressPhotos.add(newPhoto);
    await LocalStorage.saveCachedProgressPhotos(_progressPhotos);
    _isAnalyzingPhoto = false;

    _onCelebration?.call(
      '📸 Photo Scan Complete!',
      'Daily AI progress scan completed. Body Fat: ${newPhoto.bodyFat}%, symmetry is ${newPhoto.symmetryScore}!',
    );

    notifyListeners();
  }

  Future<void> deleteProgressPhoto(String id) async {
    _progressPhotos.removeWhere((p) => p.id == id);
    await LocalStorage.saveCachedProgressPhotos(_progressPhotos);
    notifyListeners();
  }

  void _loadDefaultStories() {
    _stories = [
      FitnessStory(
        id: 'story_1', title: 'Sattu Fuel', avatarText: '🥛',
        gradient: [const Color(0xFFA43700), const Color(0xFFCD4700)],
        tipTitle: 'Sattu: The Desi Whey',
        tipContent: 'Sattu is roasted chickpea flour. Mixing 4 tbsp (40g) in water gives 9g of pure plant protein for less than ₹5.',
      ),
      FitnessStory(
        id: 'story_2', title: 'Kettle Magic', avatarText: '🔌',
        gradient: [const Color(0xFF1B6D24), const Color(0xFF43A047)],
        tipTitle: 'Hostel Kettle Rules',
        tipContent: 'Clean your electric kettle immediately after boiling soya chunks! Boil a water-vinegar mix for 5 mins.',
      ),
      FitnessStory(
        id: 'story_3', title: 'Sleep Clean', avatarText: '😴',
        gradient: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
        tipTitle: 'Growth Hormone Trigger',
        tipContent: 'For budget muscle growth, sleep is free! Turning off screens 30 mins before bed increases deep sleep cycles.',
      ),
      FitnessStory(
        id: 'story_4', title: 'Peanut power', avatarText: '🥜',
        gradient: [const Color(0xFF6B21A8), const Color(0xFFA855F7)],
        tipTitle: 'Cheap Calorie Bomb',
        tipContent: 'Struggling to gain weight? Peanuts cost just ₹100/kg. A small handful (30g) provides 180 clean calories.',
      ),
    ];
  }

  void _loadDefaultFlashcards() {
    _flashcards = [
      HealthFlashcard(
        id: 'fc_1', category: 'NUTRITION MYTH',
        myth: 'Myth: Vegetarian diet has no complete protein source.',
        fact: 'Fact: Combining cereals (Rice/Roti) with pulses (Daal) or dairy products creates a complete amino acid profile.',
      ),
      HealthFlashcard(
        id: 'fc_2', category: 'HOSTEL COOKING',
        myth: 'Myth: Soya chunks increase estrogen levels in males.',
        fact: 'Fact: Scientific consensus shows normal soy intake has zero impact on testosterone or estrogen levels.',
      ),
      HealthFlashcard(
        id: 'fc_3', category: 'HOME TRAINING',
        myth: 'Myth: You cannot build muscle without heavy gym weights.',
        fact: 'Fact: Mechanical tension builds muscle. Calisthenics performed close to failure trigger identical muscle growth.',
      ),
    ];
  }

  void _loadDefaultProgress() {
    // Progress data is loaded from cache
  }

  void _loadDefaultArticles() {
    _articles = [
      HealthArticle(
        id: 'art_1', title: 'Budget Protein Guide', category: 'Nutrition',
        content: 'Complete guide to hitting your protein targets on a hostel budget.', readTimeMins: 5,
      ),
      HealthArticle(
        id: 'art_2', title: 'Kettle Cooking Hacks', category: 'Cooking',
        content: 'Master the art of hostel kettle cooking with these protein-packed recipes.', readTimeMins: 4,
      ),
      HealthArticle(
        id: 'art_3', title: 'Sleep for Gains', category: 'Recovery',
        content: 'Why 7-8 hours of sleep is the most anabolic thing you can do for free.', readTimeMins: 3,
      ),
    ];
    LocalStorage.saveCachedArticles(_articles);
  }

  void _loadDefaultProgressPhotos() {
    _progressPhotos = [
      ProgressPhoto(
        id: 'photo_init_1',
        imagePath: 'initial_progress',
        dateStr: 'May 10, 2026',
        bodyFat: 18.5,
        symmetryScore: 78,
        vascularity: 4,
        postureScore: 82,
        feedback: 'Ache base level gains hain, Bhai! Abhi thoda flat texture hai chest me. Regular push-ups aur sattu continue rakho.',
      ),
      ProgressPhoto(
        id: 'photo_init_2',
        imagePath: 'initial_progress_2',
        dateStr: 'May 18, 2026',
        bodyFat: 17.8,
        symmetryScore: 80,
        vascularity: 5,
        postureScore: 85,
        feedback: 'Vascularity check looking good. Posture straight ho raha hai. Deadlift se spine support aur lower body alignment fit ho rahi hai. Soya pulao khate raho!',
      ),
    ];
    LocalStorage.saveCachedProgressPhotos(_progressPhotos);
  }
}
