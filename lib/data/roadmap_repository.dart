import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/career_match.dart';

class RoadmapRepository {
  Future<List<CareerMatch>> getOrGenerate() async {
    if (!AppConfig.isConfigured) return _fallback();
    final existing = await getMyMatches();
    if (existing.isNotEmpty) return existing;
    return generate();
  }

  Future<List<CareerMatch>> generate() async {
    if (!AppConfig.isConfigured) return _fallback();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return _fallback();

    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

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
      if (response.data == null) throw Exception('Empty response');
      final data = response.data as Map<String, dynamic>;
      final matchesJson = data['matches'] as List<dynamic>;
      return matchesJson
          .map((e) => CareerMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
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

  Future<CareerMatch?> getMatch(String matchId) async {
    if (!AppConfig.isConfigured) return null;
    if (matchId.startsWith('fallback-')) return null;
    final data = await supabase
        .from('career_matches')
        .select()
        .eq('id', matchId)
        .maybeSingle();
    if (data == null) return null;
    return CareerMatch.fromJson(data);
  }

  // ── NEW ────────────────────────────────────────────────────────────────
  Future<CareerMatch?> getSavedMatch() async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await supabase
        .from('career_matches')
        .select()
        .eq('user_id', userId)
        .eq('is_saved', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return CareerMatch.fromJson(data);
  }

  Future<void> saveMatch(String matchId) async {
    if (!AppConfig.isConfigured) return;
    if (matchId.startsWith('fallback-')) return;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Unsave any previously saved path for this user before marking the new one.
    await supabase
        .from('career_matches')
        .update({'is_saved': false})
        .eq('user_id', userId);

    await supabase
        .from('career_matches')
        .update({
          'is_saved': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', matchId);
  }

  String? _extractWorkStyle(Map<String, dynamic> answers) {
    final q4 = answers['q4'];
    if (q4 is List && q4.isNotEmpty) {
      return (q4).cast<String>().join(', ');
    }
    if (q4 is String && q4.isNotEmpty) return q4;
    return null;
  }

  List<String> _extractVision(Map<String, dynamic> answers) {
    final q8 = answers['q8'];
    if (q8 is List) return (q8).cast<String>();
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
        SkillTag(name: 'Wireframing', level: 'beginner'),
      ],
      outlook:
          'Strong global demand with remote-friendly roles across tech, fintech, and health.',
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Foundations of Design',
          detail: "Complete Google's free UX Certificate on Coursera.",
        ),
        RoadmapStep(
          order: 2,
          title: 'Learn the Tools',
          detail: 'Get comfortable with Figma — the industry standard.',
        ),
        RoadmapStep(
          order: 3,
          title: 'Build Your Portfolio',
          detail: 'Redesign an app you use and document your process.',
        ),
      ],
      source: 'fallback',
    ),
    const CareerMatch(
      id: 'fallback-2',
      title: 'Data Scientist',
      summary:
          'Data Scientists find meaningful patterns in large datasets to help organisations decide smarter.',
      matchReason:
          'Your analytical strengths and love of learning translate directly into data science.',
      fitScore: 75,
      requiredSkills: [
        SkillTag(name: 'Python', level: 'beginner'),
        SkillTag(name: 'Statistics', level: 'beginner'),
        SkillTag(name: 'Data Analysis', level: 'beginner'),
      ],
      outlook: 'One of the fastest-growing roles globally.',
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Start with Python',
          detail: 'Complete Python for Everybody on Coursera.',
        ),
        RoadmapStep(
          order: 2,
          title: 'Learn Data Tools',
          detail: "Pick up pandas and matplotlib on Kaggle's free courses.",
        ),
        RoadmapStep(
          order: 3,
          title: 'Ship a Project',
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
      outlook: 'Highly valued in tech and startups.',
      roadmap: [
        RoadmapStep(
          order: 1,
          title: 'Read the Fundamentals',
          detail: "Start with 'Inspired' by Marty Cagan.",
        ),
        RoadmapStep(
          order: 2,
          title: 'Get Real Exposure',
          detail: 'Join a student startup or hackathon in a coordination role.',
        ),
        RoadmapStep(
          order: 3,
          title: 'Document Your Thinking',
          detail: 'Write product teardowns and publish them online.',
        ),
      ],
      source: 'fallback',
    ),
  ];
}
