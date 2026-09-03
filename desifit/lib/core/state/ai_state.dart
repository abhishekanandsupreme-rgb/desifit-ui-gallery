import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import '../network/analytics_service.dart';
import 'models.dart';

class AiState extends ChangeNotifier {
  int _aiChatCount = 0;
  int _aiCalorieEstimateCount = 0;
  int _aiRecipeCount = 0;
  int _aiArticleCount = 0;
  int _coachMessageCount = 0;
  bool _unlockedUnlimitedCoach = false;

  List<ChatMessage> _chatHistory = [];
  List<RecipeItem> _recipes = [];

  int get aiChatCount => _aiChatCount;
  int get aiCalorieEstimateCount => _aiCalorieEstimateCount;
  int get aiRecipeCount => _aiRecipeCount;
  int get aiArticleCount => _aiArticleCount;
  bool get isAiChatLimitReached => _aiChatCount >= 5;
  bool get isAiCalorieLimitReached => _aiCalorieEstimateCount >= 3;
  bool get isAiRecipeLimitReached => _aiRecipeCount >= 3;
  bool get isAiArticleLimitReached => _aiArticleCount >= 3;
  int get coachMessageCount => _coachMessageCount;
  bool get unlockedUnlimitedCoach => _unlockedUnlimitedCoach;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<RecipeItem> get recipes => _recipes;

  void initFromCache({
    required List<RecipeItem> recipes,
    required List<ChatMessage> chatHistory,
  }) {
    _recipes = recipes;
    _chatHistory = chatHistory;

    final aiCounters = LocalStorage.getAiUsageCounters();
    _aiChatCount = aiCounters['ai_chat_count'] ?? 0;
    _aiCalorieEstimateCount = aiCounters['ai_calorie_count'] ?? 0;
    _aiRecipeCount = aiCounters['ai_recipe_count'] ?? 0;
    _aiArticleCount = aiCounters['ai_article_count'] ?? 0;
    _coachMessageCount = LocalStorage.getCoachMessageCount();
    _unlockedUnlimitedCoach = LocalStorage.getUnlockedUnlimitedCoach();

    if (_recipes.isEmpty) {
      _loadDefaultRecipes();
    }
    if (_chatHistory.isEmpty) {
      _loadDefaultChat();
    }
  }

  void incrementAiChatCount() {
    _aiChatCount++;
    _saveAiCounters();
    notifyListeners();
  }

  void incrementAiCalorieCount() {
    _aiCalorieEstimateCount++;
    _saveAiCounters();
    notifyListeners();
  }

  void incrementAiRecipeCount() {
    _aiRecipeCount++;
    _saveAiCounters();
    notifyListeners();
  }

  void incrementAiArticleCount() {
    _aiArticleCount++;
    _saveAiCounters();
    notifyListeners();
  }

  void unlockAiChat() {
    _aiChatCount = 0;
    _saveAiCounters();
    notifyListeners();
  }

  void unlockAiCalorie() {
    _aiCalorieEstimateCount = 0;
    _saveAiCounters();
    notifyListeners();
  }

  void unlockAiRecipe() {
    _aiRecipeCount = 0;
    _saveAiCounters();
    notifyListeners();
  }

  void unlockAiArticle() {
    _aiArticleCount = 0;
    _saveAiCounters();
    notifyListeners();
  }

  void unlockUnlimitedCoach() {
    _unlockedUnlimitedCoach = true;
    LocalStorage.saveUnlockedUnlimitedCoach(true);
    notifyListeners();
  }

  void addChatMessage(bool isUser, String message, {String senderName = 'Expert'}) {
    final chat = ChatMessage(
      isUser: isUser,
      message: message,
      timestamp: DateTime.now(),
      senderName: senderName,
    );
    _chatHistory.add(chat);
    LocalStorage.saveCachedChat(_chatHistory);

    if (isUser) {
      _coachMessageCount++;
      LocalStorage.saveCoachMessageCount(_coachMessageCount);
    }

    notifyListeners();
  }

  void addGeneratedRecipe(RecipeItem recipe) {
    _recipes.insert(0, recipe);
    LocalStorage.saveCachedRecipes(_recipes);
    
    AnalyticsService.logEvent('recipe_generated', {
      'title': recipe.title,
      'cost': recipe.cost,
      'protein': recipe.protein,
      'time_mins': recipe.timeMins,
      'is_kettle': recipe.isKettle,
    });
    
    notifyListeners();
  }

  void resetAiCounts() {
    _aiChatCount = 0;
    _aiCalorieEstimateCount = 0;
    _aiRecipeCount = 0;
    _aiArticleCount = 0;
    LocalStorage.saveAiUsageCounters(0, 0, 0, 0);
    notifyListeners();
  }

  void _saveAiCounters() {
    LocalStorage.saveAiUsageCounters(_aiChatCount, _aiCalorieEstimateCount, _aiRecipeCount, _aiArticleCount);
  }

  void _loadDefaultRecipes() {
    _recipes = [
      RecipeItem(
        title: 'Kettle Soya Pulao Jugaad',
        desc: 'Ultimate hostel muscle staple. Kettle me one-pot comfort meal ready.',
        cost: 20.0, protein: 25.0, timeMins: 15, tag: 'Kettle Hack', isKettle: true,
        steps: ['Soya chunks ko 5 mins garm paani me soak karo.', 'Kettle me rice, thode spices aur soya chunks daal do.', 'Kettle on karke 15 mins pakne do, anabolic pulao ready!'],
      ),
      RecipeItem(
        title: 'Paneer Sprouts Salad',
        desc: 'Bina aag jalaye raw protein tank. Mix karo aur shuru ho jao.',
        cost: 25.0, protein: 21.0, timeMins: 5, tag: 'No Cook', isKettle: false,
        steps: ['Paneer ko chhote pieces me cut kar lo.', 'Sprouts ko achhe se paani se dhul lo.', 'Paneer, sprouts, lemon juice aur thoda black salt mix karo.'],
      ),
      RecipeItem(
        title: 'Late Night Oats Porridge',
        desc: 'Late-night padhai ya heavy workout ke baad ka anabolic calorie bomb.',
        cost: 22.0, protein: 15.0, timeMins: 3, tag: 'No Cook', isKettle: false,
        steps: ['Ek jar ya glass me oats aur doodh daal lo.', 'Thoda peanut butter aur 1 banana mash karke mix karo.', 'Raat bhar room me rakh do, subah uthte hi sasta protein ready!'],
      ),
      RecipeItem(
        title: 'Sattu Milkshake Supreme',
        desc: 'Desi protein drink! Power-packed sattu with cold milk & banana.',
        cost: 20.0, protein: 16.0, timeMins: 3, tag: 'No Cook', isKettle: false,
        steps: ['Ek bade glass me 4 tbsp (40g) Sattu powder daal do.', 'Cold milk (200ml) aur 1 mashed banana dalkar mix karo.', 'Mithaas ke liye thoda sa gur (jaggery) daalke shake ya stir karo, Supreme energy ready!'],
      ),
      RecipeItem(
        title: 'Roasted Chana Gym Snack',
        desc: 'Crunchy, sasta and ready-to-eat muscle snack. Zero preparation needed.',
        cost: 10.0, protein: 13.0, timeMins: 1, tag: 'No Cook', isKettle: false,
        steps: ['60g bhuna chana (roasted chana) apni pocket ya dabba me rakho.', 'Padhte padhte ya class ke beech me thoda thoda khao.', 'Green tea ya paani ke sath enjoy karo for clean slow-digesting carbs and protein!'],
      ),
    ];
    LocalStorage.saveCachedRecipes(_recipes);
  }

  void _loadDefaultChat() {
    _chatHistory = [
      ChatMessage(
        isUser: false,
        message: 'Ram Ram! DesiFit Experts panel me aapka swagat hai. Main Ravi hoon, certified strength coach. Amit, Joseph aur Tom bhi online hain. Aapko workout ya diet ke baare me kya help chahiye? Pucho, expert plan ready karte hain!',
        timestamp: DateTime.now(),
        senderName: 'Ravi',
      ),
    ];
    LocalStorage.saveCachedChat(_chatHistory);
  }
}
