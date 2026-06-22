import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/career_match.dart';

class RoadmapRepository {
  /// Returns cached matches if they exist, otherwise generates new ones.
  Future<List<CareerMatch>> getOrGenerate() async {
    if (!AppConfig.isConfigured) return _fallback();

    final existing = await getMyMatches();
    if (existing.isNotEmpty) return existing;

    return generate();
  }

  /// Always calls the Edge Function and writes fresh matches to DB.
  Future<List<CareerMatch>> generate() async {
    if (!AppConfig.isConfigured) return _fallback();

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return _fallback();

    // Fetch profile
    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    // Fetch latest quiz response
    final quizData = await supabase
        .from('quiz_responses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final profile = {
      'displayName': profileData?['display_name'] ?? 'Student',
      'ageBand': profileData?['age_band'] ?? '',
      'educationStage': profileData?['education_stage'] ?? '',
    };

    final answers = (quizData?['answers'] as Map<String, dynamic>?) ?? {};

    final quiz = {
      'interests': quizData?['interests'] ?? [],
      'values': quizData?['values'] ?? [],
      'strengths': quizData?['strengths'] ?? [],
      'workStyle': _extractWorkStyle(answers),
      'vision': _extractVision(answers),
      'rawAnswers': answers,
    };

    try {
      final response = await supabase.functions.invoke(
        'generate-roadmap',
        body: {'profile': profile, 'quiz': quiz},
      );

      if (response.data == null) throw Exception('Empty response from AI');

      final data = response.data as Map<String, dynamic>;
      final matchesJson = data['matches'] as List<dynamic>;
      return matchesJson
          .map((e) => CareerMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _fallback();
    }
  }

  Future<List<CareerMatch>> getMyMatches() async {
    if (!AppConfig.isConfigured) return [];
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('career_matches')
        .select()
        .eq('user_id', userId)
        .order('fit_score', ascending: false);

    return (data as List<dynamic>)
        .map((e) => CareerMatch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String? _extractWorkStyle(Map<String, dynamic> answers) {
    final q4 = answers['q4'];
    if (q4 is List && q4.isNotEmpty)
      return (q4 as List).cast<String>().join(', ');
    if (q4 is String && q4.isNotEmpty) return q4;
    return null;
  }

  List<String> _extractVision(Map<String, dynamic> answers) {
    final q8 = answers['q8'];
    if (q8 is List) return (q8 as List).cast<String>();
    if (q8 is String && q8.isNotEmpty) return [q8];
    return [];
  }

  List<CareerMatch> _fallback() => [
    const CareerMatch(
      id: 'fallback-1',
      title: 'UX Designer',
      summary:
          'UX Designers research how people use products and create interfaces that feel natural.',
      matchReason:
          'Your creative thinking and interest in how people behave makes UX design a natural fit.',
      fitScore: 82,
      requiredSkills: [
        SkillTag(name: 'UI Design', level: 'beginner'),
        SkillTag(name: 'User Research', level: 'beginner'),
      ],
      outlook:
          'Strong global demand with remote-friendly roles across tech, fintech, and health sectors.',
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Learn the basics',
          detail: "Complete Google's free UX Certificate on Coursera.",
        ),
        RoadmapStep(
          order: 2,
          title: 'Build a portfolio piece',
          detail: 'Redesign an app you use and document your process.',
        ),
        RoadmapStep(
          order: 3,
          title: 'Get real experience',
          detail:
              'Apply for internships or help a local business with their site.',
        ),
      ],
      source: 'fallback',
    ),
    const CareerMatch(
      id: 'fallback-2',
      title: 'Data Scientist',
      summary:
          'Data Scientists find meaningful patterns in large datasets to help organisations make smarter decisions.',
      matchReason:
          'Your analytical strengths and love of learning translate directly into data science.',
      fitScore: 75,
      requiredSkills: [
        SkillTag(name: 'Python', level: 'beginner'),
        SkillTag(name: 'Stats', level: 'beginner'),
      ],
      outlook:
          "One of the fastest-growing roles globally — every industry needs people who can make sense of data.",
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Start with Python',
          detail: 'Complete Python for Everybody on Coursera.',
        ),
        RoadmapStep(
          order: 2,
          title: 'Learn data tools',
          detail: "Pick up pandas and matplotlib on Kaggle's free courses.",
        ),
        RoadmapStep(
          order: 3,
          title: 'Complete a project',
          detail: 'Analyse a public dataset and publish it on GitHub.',
        ),
      ],
      source: 'fallback',
    ),
    const CareerMatch(
      id: 'fallback-3',
      title: 'Product Manager',
      summary:
          "Product Managers decide what gets built, why it matters, and whether it's working.",
      matchReason:
          'Your leadership instincts and big-picture thinking align well with product management.',
      fitScore: 68,
      requiredSkills: [
        SkillTag(name: 'Strategy', level: 'intermediate'),
        SkillTag(name: 'Agile', level: 'beginner'),
      ],
      outlook:
          'Highly valued in tech and startups, but typically needs 1-2 years of adjacent experience first.',
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Read the fundamentals',
          detail: "Start with 'Inspired' by Marty Cagan.",
        ),
        RoadmapStep(
          order: 2,
          title: 'Get exposure',
          detail: 'Join a student startup or hackathon in a coordination role.',
        ),
        RoadmapStep(
          order: 3,
          title: 'Document your thinking',
          detail: 'Write product teardowns and publish them online.',
        ),
      ],
      source: 'fallback',
    ),
  ];
}
