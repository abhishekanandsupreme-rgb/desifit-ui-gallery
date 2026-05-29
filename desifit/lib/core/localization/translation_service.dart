class TranslationService {
  static const Map<String, String> _hinglishMap = {
    'Hello, Champ!': 'Ram Ram, Bhai!',
    'Budget Left': 'Paisa Bacha',
    'Protein Hit': 'Protein Dum',
    'Leaderboard': 'Sattu Samrat Rank',
    'Jugaad Leaderboard': 'Sattu Samrat Rank',
    'Rank': 'Sattu Samrat Rank',
    'Home': 'Ghar',
    'Recipes': 'Pakwan',
    'Coach': 'Guru',
    'Planner': 'Karyakram',
    'FITNESS STORIES': 'FITNESS KI KAHANIYAN',
    'DAILY MYTHBUSTER': 'ROZ KE MYTHS',
    'AI DESI HEALTH FEED': 'AI DESI HEALTH FEED',
    'DORM WORKOUTS': 'HOSTEL KI KASRAT',
    'WEEKLY REPORTS': 'HAFTAWAR REPORT',
    'Quick Add': 'Turant Add',
    'Limit': 'Seema',
    'Goal': 'Target',
    'Hit your targets today!': 'Aaj ke targets pure karo!',
    'Ready to fuel up on a budget?': 'Budget me body banane ke liye tayar?',
    'Settings': 'Settings',
    'Hinglish Mode': 'Hinglish Bolchal',
    'Translate UI to Hinglish': 'UI ko Hinglish me badlein',
    'Daily Budget (₹)': 'Roz ka Kharcha (₹)',
    'Daily Protein Goal (g)': 'Roz ka Protein Target (g)',
    'Cancel': 'Rehne do',
    'Save': 'Save karo',
    'Settings saved successfully!': 'Settings ekdum fit ho gayi!',
    'Sasta Protein Meter': 'Sasta Protein Meter',
    'Mix cheap Indian staples (Sattu, Soya, Peanuts) and track cost efficiency in real-time.': 'Sasta staples (Sattu, Soya, Peanuts) ko mix karo aur cost-efficiency check karo.',
    'CALCULATE DIET NOW': 'DIET METER CHECK KARO',
  };

  static String translate(String key, {bool isHinglish = false, String? name}) {
    if (!isHinglish) {
      if (name != null && key.contains('Champ')) {
        return key.replaceAll('Champ', name);
      }
      return key;
    }

    if (key.startsWith('Hello,') || key.startsWith('Hello')) {
      final actualName = name ?? 'Champ';
      if (actualName.toLowerCase() == 'champ') {
        return _hinglishMap['Hello, Champ!'] ?? 'Ram Ram, Bhai!';
      }
      return 'Ram Ram, $actualName!';
    }

    return _hinglishMap[key] ?? key;
  }
}
