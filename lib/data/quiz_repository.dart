import '../core/app_config.dart';
import '../core/supabase_client.dart';

class QuizRepository {
  Future<void> saveResponses(Map<String, dynamic> answers) async {
    if (!AppConfig.isConfigured) return;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Extract categorised arrays from answers
    final interests = <String>[
      ...(_asList(answers['q1'])),
      ...(_asList(answers['q6'])),
    ];

    final values = <String>[
      ...(_asList(answers['q2'])),
      if (answers['q5'] is String && (answers['q5'] as String).isNotEmpty)
        answers['q5'] as String,
    ];

    final strengths = <String>[
      if (answers['q3'] is String && (answers['q3'] as String).isNotEmpty)
        answers['q3'] as String,
      if (answers['q7'] is String && (answers['q7'] as String).isNotEmpty)
        answers['q7'] as String,
    ];

    await supabase.from('quiz_responses').insert({
      'user_id': userId,
      'answers': answers,
      'interests': interests,
      'values': values,
      'strengths': strengths,
    });
  }

  Future<Map<String, dynamic>?> getLatestResponse() async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('quiz_responses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return data;
  }

  List<String> _asList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }
}
