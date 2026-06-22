enum QuestionType { singleSelect, multiSelect }

class QuizQuestion {
  final String id;
  final String question;
  final String? hint;
  final QuestionType type;
  final int? maxSelections;
  final List<String> options;
  final String category;

  const QuizQuestion({
    required this.id,
    required this.question,
    this.hint,
    required this.type,
    this.maxSelections,
    required this.options,
    required this.category,
  });
}
