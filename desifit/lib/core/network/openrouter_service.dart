import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../state/app_state.dart';

class OpenRouterService {
  static const String _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Secure compile-time injection: inject via --dart-define=OPENROUTER_API_KEY=key_here
  static const String _apiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
  
  // Default free model
  static const String _defaultModel = 'meta-llama/llama-3-8b-instruct:free';

  static bool get hasApiKey => _apiKey.isNotEmpty;

  // Maximum API requests allowed daily to manage token consumption & cost-efficiency
  static const int _maxDailyRequests = 10;

  static bool _shouldThrottle() {
    try {
      final box = Hive.box('settings');
      final lastDate = box.get('last_api_date', defaultValue: '') as String;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (lastDate != today) {
        box.put('last_api_date', today);
        box.put('daily_api_count', 0);
        return false;
      }
      
      final count = box.get('daily_api_count', defaultValue: 0) as int;
      return count >= _maxDailyRequests;
    } catch (e) {
      // Return false on storage error so network requests can try to proceed
      return false;
    }
  }

  static void _incrementRequestCount() {
    try {
      final box = Hive.box('settings');
      final count = box.get('daily_api_count', defaultValue: 0) as int;
      box.put('daily_api_count', count + 1);
    } catch (e) {
      // Ignore errors
    }
  }

  static Future<RecipeItem?> generateRecipe({
    required String ingredients,
    required bool onlyKettle,
    required bool under30,
  }) async {
    if (_apiKey.isEmpty || _shouldThrottle()) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _generateLocalFallbackRecipe(ingredients, onlyKettle, under30);
    }

    try {
      final systemPrompt = 'You are an expert Indian hostel cook and gym-bro specializing in quick, sasta (extremely cheap) bodybuilding diets (under ₹50). '
          'You speak in a highly colloquial, fun Hinglish tone using gym-slang (like "Bhai", "gains", "muscle", "workout", "anabolic", "bro", "jugad", "kettle", "sasta"). '
          'You must output a high-protein recipe based on user ingredients. '
          'Strictly adhere to the following length constraints:\n'
          '- recipe_name: Max 30 characters. Very catchy, Hinglish gym-slang (e.g. "Anabolic Kettle Soya", "Sasta Sattu Shake").\n'
          '- desc: Max 80 characters. Explaining the recipe in Hinglish with gym-slang.\n'
          '- steps: Max 4 steps. Each step must be under 100 characters, explaining the instructions in Hinglish.\n'
          '- tag: Max 15 characters (e.g. "Kettle Hack", "Sasta Gains", "No Cook").\n'
          'Your output MUST be a valid JSON object matching this schema exactly, and nothing else. No markdown wrappers (do NOT include ```json), no extra text. Just raw JSON.\n'
          'JSON Schema:\n'
          '{\n'
          '  "recipe_name": "Name of dish",\n'
          '  "cost_estimate_inr": 25.0,\n'
          '  "protein_grams": 15.0,\n'
          '  "cook_time_mins": 10,\n'
          '  "is_kettle_safe": true,\n'
          '  "tag": "Tag name",\n'
          '  "desc": "Short description",\n'
          '  "steps": ["Step 1", "Step 2"]\n'
          '}';

      final userPrompt = 'Ingredients: $ingredients. '
          'Constraints: ${onlyKettle ? 'MUST be cookable in an electric kettle. ' : ''} '
          '${under30 ? 'Total cost MUST be under INR 30. ' : ''}';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://desifit.app',
          'X-Title': 'DesiFit',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 350,
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        _incrementRequestCount();
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        
        // Clean JSON formatting if model added markdown wrappers
        String cleanedContent = content.trim();
        if (cleanedContent.startsWith('```')) {
          final int firstNewLine = cleanedContent.indexOf('\n');
          if (firstNewLine != -1 && cleanedContent.substring(0, firstNewLine).contains('`')) {
            cleanedContent = cleanedContent.substring(firstNewLine + 1);
          } else {
            cleanedContent = cleanedContent.substring(3);
          }
        }
        if (cleanedContent.endsWith('```')) {
          cleanedContent = cleanedContent.substring(0, cleanedContent.length - 3);
        }
        cleanedContent = cleanedContent.trim();

        final map = jsonDecode(cleanedContent);
        return RecipeItem(
          title: map['recipe_name'] ?? 'Custom Jugaad Dish',
          desc: map['desc'] ?? 'Generated high protein recipe.',
          cost: (map['cost_estimate_inr'] as num?)?.toDouble() ?? 25.0,
          protein: (map['protein_grams'] as num?)?.toDouble() ?? 15.0,
          timeMins: (map['cook_time_mins'] as num?)?.toInt() ?? 10,
          tag: map['tag'] ?? (onlyKettle ? 'Only Kettle' : 'Hostel Hack'),
          isKettle: map['is_kettle_safe'] ?? onlyKettle,
          steps: List<String>.from(map['steps'] ?? []),
        );
      }
    } catch (e) {
      // Fallback on network or parsing error
    }
    
    return _generateLocalFallbackRecipe(ingredients, onlyKettle, under30);
  }

  static Future<String> getCoachResponse(List<ChatMessage> history, {String expertName = 'Ravi'}) async {
    if (_apiKey.isEmpty || _shouldThrottle()) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _generateLocalCoachFallback(history.last.message, expertName: expertName);
    }

    try {
      String roleDescription = 'certified strength & conditioning coach';
      if (expertName == 'Amit') roleDescription = 'clinical dietitian & nutrition expert';
      if (expertName == 'Joseph') roleDescription = 'progressive calisthenics expert';
      if (expertName == 'Tom') roleDescription = 'fat loss and habit coach';

      final systemPrompt = 'You are $expertName, a certified $roleDescription at DesiFit. '
          'You are replying to a user in a direct chat. '
          'Sound like a real human fitness expert typing casually on WhatsApp or Instagram chat. '
          'Use very casual Hinglish, brief sentences, and conversational tone. '
          'Keep it extremely short: max 1-2 sentences (under 120 characters). '
          'Focus on a single, clear Desi budget hack. No formal greetings, no structured lists. Just type like a friend.';

      final messagesPayload = history.map((c) => {
        'role': c.isUser ? 'user' : 'assistant',
        'content': c.message,
      }).toList();

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://desifit.app',
          'X-Title': 'DesiFit',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...messagesPayload,
          ],
          'temperature': 0.8,
          'max_tokens': 150,
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        _incrementRequestCount();
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Ask me again, friend!';
      }
    } catch (e) {
      // Fallback
    }

    return _generateLocalCoachFallback(history.last.message, expertName: expertName);
  }

  static Future<HealthArticle?> generateHealthArticle({
    String? category,
    String? topic,
  }) async {
    if (_apiKey.isEmpty || _shouldThrottle()) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _generateLocalFallbackArticle(category, topic);
    }

    try {
      final systemPrompt = 'You are a certified fitness trainer, Ayurvedic practitioner, and gym-bro. '
          'You must output an informative, engaging article focused on fitness, nutrition, or Ayurvedic remedies suited for Indian students on a budget. '
          'You speak in a highly colloquial Hinglish tone using gym-slang (like "Bhai", "gains", "muscle", "workout", "sasta", "paisa vasool", "Sattu", "anabolic"). '
          'Strictly adhere to the following length constraints:\n'
          '- title: Max 40 characters. Very catchy, Hinglish gym-slang.\n'
          '- category: Must be exactly "Ayurveda" or "Fitness" or "Nutrition".\n'
          '- content: Max 450 characters. Fun, motivating Hinglish gym-slang article with actionable advice.\n'
          '- readTimeMins: Integer.\n'
          'Your output MUST be a valid JSON object matching this schema exactly, and nothing else. No markdown wrappers (do NOT include ```json), no extra text. Just raw JSON.\n'
          'JSON Schema:\n'
          '{\n'
          '  "title": "Title of the article",\n'
          '  "category": "Ayurveda" or "Fitness" or "Nutrition",\n'
          '  "content": "Detailed content",\n'
          '  "readTimeMins": 3\n'
          '}';

      final userPrompt = 'Generate a new article. '
          '${category != null ? 'Category: $category. ' : ''}'
          '${topic != null ? 'Topic: $topic. ' : ''}';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://desifit.app',
          'X-Title': 'DesiFit',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 450,
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        _incrementRequestCount();
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        
        // Clean JSON formatting if model added markdown wrappers
        String cleanedContent = content.trim();
        if (cleanedContent.startsWith('```')) {
          final int firstNewLine = cleanedContent.indexOf('\n');
          if (firstNewLine != -1 && cleanedContent.substring(0, firstNewLine).contains('`')) {
            cleanedContent = cleanedContent.substring(firstNewLine + 1);
          } else {
            cleanedContent = cleanedContent.substring(3);
          }
        }
        if (cleanedContent.endsWith('```')) {
          cleanedContent = cleanedContent.substring(0, cleanedContent.length - 3);
        }
        cleanedContent = cleanedContent.trim();

        final map = jsonDecode(cleanedContent);
        return HealthArticle(
          id: 'article_${DateTime.now().millisecondsSinceEpoch}',
          title: map['title'] ?? 'Desi Health Secrets',
          category: map['category'] ?? (category ?? 'Ayurveda'),
          content: map['content'] ?? 'No content provided.',
          readTimeMins: (map['readTimeMins'] as num?)?.toInt() ?? 3,
          isRead: false,
        );
      }
    } catch (e) {
      // Fallback
    }

    return _generateLocalFallbackArticle(category, topic);
  }

  // --- Fallback Local Generators ---
  static RecipeItem _generateLocalFallbackRecipe(String ingredients, bool onlyKettle, bool under30) {
    final input = ingredients.toLowerCase();
    
    if (input.contains('sattu') || input.contains('chana')) {
      return RecipeItem(
        title: 'Sattu Muscle Shake',
        desc: 'Sattu supremacy! Super sasta post-workout drink bina blender ke.',
        cost: 12.0,
        protein: 18.0,
        timeMins: 2,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          'Glass me 4-5 chammach Sattu powder daalo aur cold water mix karo.',
          'Digestion ke liye lemon juice aur kala namak daalo, ya taste ke liye thoda gur (jaggery).',
          'Spoon se achhe se stir karo jab tak lumps na khatam ho jayein. Anabolic drink ready, Champ!'
        ],
      );
    }
    
    if (input.contains('soya') || input.contains('chunks') || input.contains('soy')) {
      return RecipeItem(
        title: 'Kettle Soya Masala Bhurji',
        desc: 'Hostel room ka real protein savior. Instant, spicy and raw gains!',
        cost: 15.0,
        protein: 26.0,
        timeMins: 10,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          'Kettle me paani boil karo aur usme 50g soya chunks daalo. 5 min soak hone do.',
          'Chunks ko squeeze karke excess water nikal lo aur finely chop kar lo.',
          'Kettle dry karke thoda oil, pyaaz, green chilli aur masala fry karo.',
          'Chopped soya chunks aur thoda paani dalke 3 min cook karo and hit the gains!'
        ],
      );
    }
    
    if (input.contains('egg') || input.contains('anda') || input.contains('eggs')) {
      return RecipeItem(
        title: 'Boiled Egg Chaat Jugaad',
        desc: 'Classic gym-bro snack cookable right under the warden\'s nose.',
        cost: 20.0,
        protein: 18.0,
        timeMins: 12,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          '3 eggs ko electric kettle me gently rakho aur cold water fill kar do.',
          'Kettle ko turn on karo aur boil hone do. Element ka dhyan rakhna!',
          'Boil hone ke baad shut off karke 10 mins tak dhak kar chhod do.',
          'Peel karke slice karo, chat masala aur namak sprinkle karo aur enjoy karo!'
        ],
      );
    }
    
    if (input.contains('paneer') || input.contains('cheese')) {
      return RecipeItem(
        title: 'Sasta Paneer Bhurji Roll',
        desc: 'No-cook quick high-protein roll to hit muscle gains post workout.',
        cost: 35.0,
        protein: 22.0,
        timeMins: 5,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          'Roti wrap ya bread slices lo. 80g fresh Paneer ko small cubes me cut karo.',
          'Tamatar, pyaaz, green chilli aur chaat masala paneer ke sath mix karo.',
          'Is mixture ko roti wrap me fill karke clean tissue paper me roll karo. Heavy energy, Bro!'
        ],
      );
    }
    
    if (input.contains('peanut') || input.contains('butter') || input.contains('peanuts')) {
      return RecipeItem(
        title: 'Hostel PB & Banana Toast',
        desc: 'Late-night calorie bomb for study sessions and muscle gains.',
        cost: 15.0,
        protein: 12.0,
        timeMins: 3,
        tag: 'No Cook',
        isKettle: false,
        steps: [
          '2 slices bread lo (white ya brown chalega).',
          '2 bade chammach peanut butter evenly spread karo.',
          '1 banana slice karke slice upar rakho. Extra crunch ke liye peanuts daal sakte ho!'
        ],
      );
    }
    
    if (input.contains('oats') || input.contains('oatmeal')) {
      return RecipeItem(
        title: 'Kettle Protein Oats',
        desc: 'Garm-garam oatmeal packed with proteins to start your day strong.',
        cost: 18.0,
        protein: 15.0,
        timeMins: 7,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          '1/2 cup rolled oats aur 1 cup paani/doodh kettle me daalo.',
          'Kettle on karke stir karte raho taaki bottom element pe stick na ho.',
          'Jab oats thick ho jayein, switch off karo, peanut butter aur banana mix karo!'
        ],
      );
    }
    
    if (input.contains('maggi') || input.contains('noodles')) {
      return RecipeItem(
        title: 'Double Protein Maggi Jugaad',
        desc: 'Khaali Maggi to empty carbs hai. Let\'s make it anabolic, Champ!',
        cost: 25.0,
        protein: 20.0,
        timeMins: 10,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          'Kettle me paani boil karo aur pehle 30g soya chunks boil kar lo.',
          'Ab Maggi noodles aur masala packet daalo.',
          '1 egg ko directly boiling mix me crack karke stir karo. Spicy Egg-Soya Noodles ready!'
        ],
      );
    }

    // Default recipe fallback based on Kettle vs Cook constraints
    if (onlyKettle) {
      return RecipeItem(
        title: 'Kettle Oatmeal Scramble',
        desc: 'Quick high-protein oatmeal bowl made in a kettle with eggs and jaggery.',
        cost: 22.0,
        protein: 18.0,
        timeMins: 8,
        tag: 'Kettle Hack',
        isKettle: true,
        steps: [
          'Kettle me 1/2 cup oats aur 1 cup paani daalkar boil karo.',
          'Boil hone par 2 beaten eggs slow speed se whisk karte hue daalo.',
          '3 mins cook karo, thoda gur (jaggery) aur peanuts mix karke khao!'
        ],
      );
    }

    return RecipeItem(
      title: 'Sprout Paneer Chaat',
      desc: 'No-cook high-protein salad using raw paneer, sprouts, and lemon juice.',
      cost: 28.0,
      protein: 20.0,
      timeMins: 5,
      tag: 'No Cook',
      isKettle: false,
      steps: [
        '50g paneer ko tiny cubes me cut karo.',
        '1 cup mixed sprouted Moong aur Chana ko wash kar lo.',
        'Lemon juice, chaat masala, aur green chilli daalkar mix karo. Raw fitness fuel ready!'
      ],
    );
  }

  static String _generateLocalCoachFallback(String query, {String expertName = 'Ravi'}) {
    final text = query.toLowerCase();
    final greeting = "$expertName here! ";
    if (text.contains('protein') || text.contains('diet') || text.contains('khana')) {
      return "${greeting}Premium whey ke pichhe mat bhago. Apne diet me Sattu, Ande, Soya chunks aur Paneer rakho. Sattu ₹80/kg hai and is the ultimate sasta post-workout drink. Baki koi supplement ki zarurat nahi hai, bas daba ke mehnat karo!";
    }
    if (text.contains('kettle') || text.contains('hostel') || text.contains('room')) {
      return "${greeting}Hostel kettle to gym-bro ka best friend hai, Bhai! Uisme ande ubalo, soya chunks cook karo ya oats banao. Bas ek rule: boil karne ke baad use turant clean kar dena taaki hostel warden check pe pakad na sake!";
    }
    if (text.contains('exercise') || text.contains('workout') || text.contains('body')) {
      return "${greeting}Bhai bodybuilding ke liye bade gym ki need nahi hai. Push-ups, pull-ups aur squats lagao room me hi failure tak. Intensity matter karti hai, equipment nahi. Aaj ka workout complete hua kya?";
    }
    return "${greeting}Bodybuilding 80% diet aur consistency hai. Budget tight hai to din me 2 whole ande, ek glass sattu aur 50g soya chunks khao. ₹25 me 50g protein block sorted! Hard work chalu rakho!";
  }

  static Future<Map<String, dynamic>?> estimateFoodCalories(String foodDescription) async {
    if (_apiKey.isEmpty || _shouldThrottle()) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _generateLocalFoodEstimate(foodDescription);
    }

    try {
      final systemPrompt = 'You are an expert Indian nutritionist and dietitian who knows the caloric and macronutrient values of all Indian foods by heart. '
          'Given a food item, provide its estimated nutrition per standard serving. '
          'Your output MUST be a valid JSON object matching this schema exactly, and nothing else. No markdown wrappers (do NOT include ```json), no extra text. Just raw JSON.\n'
          'JSON Schema:\n'
          '{\n'
          '  "food_name": "Name of food",\n'
          '  "serving_size": "e.g. 1 medium, 100g, 1 cup",\n'
          '  "calories": 120.0,\n'
          '  "protein_g": 3.5,\n'
          '  "carbs_g": 20.0,\n'
          '  "fat_g": 3.5,\n'
          '  "fiber_g": 2.0\n'
          '}';

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://desifit.app',
          'X-Title': 'DesiFit',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Estimate nutrition for: $foodDescription'},
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        _incrementRequestCount();
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        
        String cleanedContent = content.trim();
        if (cleanedContent.startsWith('```')) {
          final int firstNewLine = cleanedContent.indexOf('\n');
          if (firstNewLine != -1 && cleanedContent.substring(0, firstNewLine).contains('`')) {
            cleanedContent = cleanedContent.substring(firstNewLine + 1);
          } else {
            cleanedContent = cleanedContent.substring(3);
          }
        }
        if (cleanedContent.endsWith('```')) {
          cleanedContent = cleanedContent.substring(0, cleanedContent.length - 3);
        }
        cleanedContent = cleanedContent.trim();

        return jsonDecode(cleanedContent) as Map<String, dynamic>;
      }
    } catch (e) {
      // Fallback
    }

    return _generateLocalFoodEstimate(foodDescription);
  }

  static Map<String, dynamic> _generateLocalFoodEstimate(String food) {
    final text = food.toLowerCase();
    
    if (text.contains('roti') || text.contains('chapati')) {
      return {'food_name': 'Roti/Chapati', 'serving_size': '1 medium', 'calories': 120.0, 'protein_g': 3.5, 'carbs_g': 20.0, 'fat_g': 3.5, 'fiber_g': 2.5};
    }
    if (text.contains('rice') || text.contains('chawal')) {
      return {'food_name': 'Cooked Rice', 'serving_size': '1 cup', 'calories': 210.0, 'protein_g': 4.0, 'carbs_g': 45.0, 'fat_g': 0.5, 'fiber_g': 0.5};
    }
    if (text.contains('dal') || text.contains('lentil')) {
      return {'food_name': 'Dal/Lentils', 'serving_size': '1 bowl', 'calories': 180.0, 'protein_g': 12.0, 'carbs_g': 28.0, 'fat_g': 2.0, 'fiber_g': 5.0};
    }
    if (text.contains('egg') || text.contains('anda')) {
      return {'food_name': 'Boiled Egg', 'serving_size': '1 whole', 'calories': 78.0, 'protein_g': 6.0, 'carbs_g': 0.5, 'fat_g': 5.0, 'fiber_g': 0.0};
    }
    if (text.contains('paneer')) {
      return {'food_name': 'Paneer', 'serving_size': '100g', 'calories': 265.0, 'protein_g': 18.0, 'carbs_g': 3.5, 'fat_g': 20.0, 'fiber_g': 0.0};
    }
    if (text.contains('chicken')) {
      return {'food_name': 'Chicken Breast', 'serving_size': '100g', 'calories': 165.0, 'protein_g': 31.0, 'carbs_g': 0.0, 'fat_g': 3.5, 'fiber_g': 0.0};
    }
    if (text.contains('soya') || text.contains('soy')) {
      return {'food_name': 'Soya Chunks', 'serving_size': '50g cooked', 'calories': 170.0, 'protein_g': 26.0, 'carbs_g': 13.0, 'fat_g': 0.5, 'fiber_g': 4.0};
    }
    if (text.contains('banana') || text.contains('kela')) {
      return {'food_name': 'Banana', 'serving_size': '1 medium', 'calories': 105.0, 'protein_g': 1.3, 'carbs_g': 27.0, 'fat_g': 0.4, 'fiber_g': 3.0};
    }
    if (text.contains('milk') || text.contains('doodh')) {
      return {'food_name': 'Milk', 'serving_size': '1 glass (250ml)', 'calories': 150.0, 'protein_g': 8.0, 'carbs_g': 12.0, 'fat_g': 8.0, 'fiber_g': 0.0};
    }
    if (text.contains('maggi') || text.contains('noodle')) {
      return {'food_name': 'Maggi Noodles', 'serving_size': '1 pack', 'calories': 350.0, 'protein_g': 8.0, 'carbs_g': 48.0, 'fat_g': 14.0, 'fiber_g': 2.0};
    }
    if (text.contains('paratha')) {
      return {'food_name': 'Paratha', 'serving_size': '1 medium', 'calories': 260.0, 'protein_g': 5.0, 'carbs_g': 36.0, 'fat_g': 10.0, 'fiber_g': 2.0};
    }
    if (text.contains('idli')) {
      return {'food_name': 'Idli', 'serving_size': '2 pieces', 'calories': 140.0, 'protein_g': 4.0, 'carbs_g': 28.0, 'fat_g': 0.5, 'fiber_g': 1.5};
    }
    if (text.contains('dosa')) {
      return {'food_name': 'Dosa', 'serving_size': '1 medium', 'calories': 165.0, 'protein_g': 4.0, 'carbs_g': 28.0, 'fat_g': 4.0, 'fiber_g': 1.5};
    }
    if (text.contains('sattu')) {
      return {'food_name': 'Sattu Drink', 'serving_size': '2 tbsp (30g)', 'calories': 100.0, 'protein_g': 6.0, 'carbs_g': 15.0, 'fat_g': 1.5, 'fiber_g': 3.0};
    }
    if (text.contains('peanut') || text.contains('moongfali')) {
      return {'food_name': 'Peanuts', 'serving_size': '30g handful', 'calories': 170.0, 'protein_g': 7.0, 'carbs_g': 5.0, 'fat_g': 14.0, 'fiber_g': 2.55};
    }
    if (text.contains('curd') || text.contains('dahi') || text.contains('yogurt')) {
      return {'food_name': 'Curd/Dahi', 'serving_size': '1 cup', 'calories': 100.0, 'protein_g': 5.0, 'carbs_g': 8.0, 'fat_g': 5.0, 'fiber_g': 0.0};
    }
    if (text.contains('samosa')) {
      return {'food_name': 'Samosa', 'serving_size': '1 piece', 'calories': 260.0, 'protein_g': 4.5, 'carbs_g': 30.0, 'fat_g': 14.0, 'fiber_g': 2.0};
    }
    if (text.contains('tea') || text.contains('chai')) {
      return {'food_name': 'Chai/Tea', 'serving_size': '1 cup', 'calories': 50.0, 'protein_g': 1.0, 'carbs_g': 7.0, 'fat_g': 1.5, 'fiber_g': 0.0};
    }
    if (text.contains('biryani')) {
      return {'food_name': 'Biryani', 'serving_size': '1 plate', 'calories': 450.0, 'protein_g': 18.0, 'carbs_g': 55.0, 'fat_g': 18.0, 'fiber_g': 3.0};
    }
    if (text.contains('rajma')) {
      return {'food_name': 'Rajma', 'serving_size': '1 bowl', 'calories': 200.0, 'protein_g': 14.0, 'carbs_g': 30.0, 'fat_g': 2.5, 'fiber_g': 8.0};
    }
    
    // Generic fallback
    return {'food_name': food, 'serving_size': '1 serving', 'calories': 200.0, 'protein_g': 8.0, 'carbs_g': 25.0, 'fat_g': 5.0, 'fiber_g': 2.0};
  }

  static HealthArticle _generateLocalFallbackArticle(String? category, String? topic) {
    final cat = category ?? 'Ayurveda';
    final search = (topic ?? '').toLowerCase();
    
    if (cat.toLowerCase().contains('ayurveda') || search.contains('ayur') || search.contains('herb') || search.contains('natural')) {
      final articles = [
        HealthArticle(
          id: 'article_fallback_ayu_1',
          title: 'Jeera-Dhania Detox Tea',
          category: 'Ayurveda',
          content: 'Hey Champ! Mess food se indigestion aur bloating hoti hai? 1/2 spoon Jeera aur Dhania seeds ko kettle me 5 mins boil karo. Morning me warm piyo. Tri-dosh balance hoga, digestion sharp hoga aur bloating door rahegi taaki bodybuilding diet achhe se absorb ho sake!',
          readTimeMins: 3,
          isRead: false,
        ),
        HealthArticle(
          id: 'article_fallback_ayu_2',
          title: 'Ashwagandha for Sleep & Gains',
          category: 'Ayurveda',
          content: 'Bhai, muscle building gym me nahi, sleep me hoti hai. Ashwagandha stress levels down karta hai aur growth hormone boost karta hai. 1/2 spoon powder warm milk ke sath bed time pe lo. Sasta adaptogen jo recovery speed fast kar dega!',
          readTimeMins: 4,
          isRead: false,
        ),
      ];
      if (search.contains('sleep') || search.contains('recover') || search.contains('ashwa')) {
        return articles[1];
      }
      return articles[0];
    } else if (cat.toLowerCase().contains('fitness') || search.contains('workout') || search.contains('exercise') || search.contains('gym')) {
      final articles = [
        HealthArticle(
          id: 'article_fallback_fit_1',
          title: 'Dorm Room Calisthenics Hack',
          category: 'Fitness',
          content: 'Dost, gym membership costly hai? Your muscles only know tension, not iron! Do 4 sets of slow push-ups (3s down, 1s hold), 4 sets of chair dips, and 4 sets of bodyweight squats. Failures ke close train karo and see the gains right in your room!',
          readTimeMins: 3,
          isRead: false,
        ),
        HealthArticle(
          id: 'article_fallback_fit_2',
          title: 'Corridor Walking Hack',
          category: 'Fitness',
          content: 'Late-night study me fatigue ho jata hai? Set a timer: every 45 mins, 10 mins corridor me walk karo. Blood flow increase hoga, cognitive fatigue door hoga aur daily 10,000 steps meet karna easy ho jayega without boring gym cardio. Pocket friendly efficiency!',
          readTimeMins: 3,
          isRead: false,
        ),
      ];
      if (search.contains('walk') || search.contains('cardio') || search.contains('steps')) {
        return articles[1];
      }
      return articles[0];
    } else {
      final articles = [
        HealthArticle(
          id: 'article_fallback_nut_1',
          title: 'Daal-Chawal Protein synergy',
          category: 'Nutrition',
          content: 'Bhai, check this amino hack! Daal me lysine hota hai but methionine kam, Chawal me methionine hota hai but lysine kam. Dono ko combine karke khao (2:1 ratio), complete protein block ban jayega ₹25 ke andar! No need for expensive isolate whey, Boss!',
          readTimeMins: 3,
          isRead: false,
        ),
        HealthArticle(
          id: 'article_fallback_nut_2',
          title: 'Sattu vs Whey Protein',
          category: 'Nutrition',
          content: 'Champ! Whey ka dabba ₹3000 ka ata hai but Sattu ₹80/kg. 100g Sattu gives 20g protein + fiber + complex carbs. Cold water, lime juice aur kala namak ke sath mix karke piyo. High energy pre/post workout supplement for pennies!',
          readTimeMins: 3,
          isRead: false,
        ),
      ];
      if (search.contains('sattu') || search.contains('whey') || search.contains('supplement')) {
        return articles[1];
      }
      return articles[0];
    }
  }
}
