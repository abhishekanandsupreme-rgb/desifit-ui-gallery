class ArticleSection {
  final String? heading;
  final String text;

  const ArticleSection({
    this.heading,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'text': text,
      };

  factory ArticleSection.fromJson(Map<String, dynamic> map) {
    return ArticleSection(
      heading: map['heading'] as String?,
      text: map['text'] as String,
    );
  }
}

class ArticleQuiz {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const ArticleQuiz({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'explanation': explanation,
      };

  factory ArticleQuiz.fromJson(Map<String, dynamic> map) {
    return ArticleQuiz(
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
      explanation: map['explanation'] as String,
    );
  }
}

class DesiArticle {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'Gym Hacks', 'Ayurvedic', 'Mythbusters'
  final String imageUrl;
  final String readTime;
  final List<String> tags;
  final List<ArticleSection> sections;
  final String hostelHack;
  final ArticleQuiz quiz;
  final bool isFeatured;
  bool isBookmarked;

  DesiArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.readTime,
    required this.tags,
    required this.sections,
    required this.hostelHack,
    required this.quiz,
    this.isFeatured = false,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'imageUrl': imageUrl,
        'readTime': readTime,
        'tags': tags,
        'sections': sections.map((s) => s.toJson()).toList(),
        'hostelHack': hostelHack,
        'quiz': quiz.toJson(),
        'isFeatured': isFeatured,
        'isBookmarked': isBookmarked,
      };

  factory DesiArticle.fromJson(Map<String, dynamic> map) {
    return DesiArticle(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String,
      readTime: map['readTime'] as String,
      tags: List<String>.from(map['tags'] as List),
      sections: (map['sections'] as List)
          .map((s) => ArticleSection.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      hostelHack: map['hostelHack'] as String,
      quiz: ArticleQuiz.fromJson(Map<String, dynamic>.from(map['quiz'] as Map)),
      isFeatured: map['isFeatured'] as bool? ?? false,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
    );
  }
}
