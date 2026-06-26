import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/dream_company_goal.dart';

class DreamCompanyRepository {
  Future<DreamCompanyGoal?> analyzeGap({
    required String company,
    required String role,
    required String experienceLevel,
    required Map<String, dynamic> userProfile,
  }) async {
    if (!AppConfig.isConfigured) return _localFallback(company, role);

    // 30 second timeout — if Groq hangs, we bail cleanly
    final response = await supabase.functions
        .invoke(
          'analyze-gap',
          body: {
            'company': company,
            'role': role,
            'experienceLevel': experienceLevel,
            'userProfile': userProfile,
          },
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception(
            'Analysis timed out. Check your connection and try again.',
          ),
        );

    if (response.data == null) {
      throw Exception('Empty response from AI service.');
    }

    final data = response.data as Map<String, dynamic>;

    // Edge function returned an error field
    if (data['error'] != null) {
      throw Exception('AI error: ${data['error']}');
    }

    if (data['goal'] == null) {
      throw Exception('No goal returned from AI service.');
    }

    return DreamCompanyGoal.fromJson(data['goal'] as Map<String, dynamic>);
  }

  Future<DreamCompanyGoal?> getActiveGoal() async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('dream_company_goals')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return DreamCompanyGoal.fromJson(data);
  }

  Future<void> markStepDone(
    String goalId,
    int stepIndex,
    List<CompanyRoadmapStep> steps,
  ) async {
    if (!AppConfig.isConfigured) return;

    steps[stepIndex].status = 'done';
    final nextIndex = stepIndex + 1;
    if (nextIndex < steps.length) {
      steps[nextIndex].status = 'active';
    }

    await supabase
        .from('dream_company_goals')
        .update({
          'steps': steps.map((s) => s.toJson()).toList(),
          'current_step': nextIndex < steps.length ? nextIndex : stepIndex,
        })
        .eq('id', goalId);
  }

  // Add this public method — rename _localFallback to buildLocalFallback
  DreamCompanyGoal buildLocalFallback({
    required String company,
    required String role,
  }) {
    return DreamCompanyGoal(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      company: company,
      role: role,
      experienceLevel: 'newbie',
      youHave: ['Problem Solving', 'Communication', 'Adaptability'],
      youNeed: [
        GapSkill(skill: 'Technical Foundation', level: 'beginner'),
        GapSkill(skill: 'Industry Knowledge', level: 'beginner'),
        GapSkill(skill: 'Relevant Experience', level: 'intermediate'),
      ],
      realityCheck:
          'Landing a $role role at $company takes 6–12 months of focused preparation. Start with the fundamentals and build consistently.',
      steps: [
        CompanyRoadmapStep(
          order: 1,
          title: 'CORE FOUNDATIONS',
          detail:
              'Master the fundamental skills required for this role at $company.',
          taskCount: 10,
          resourceCount: 4,
          status: 'active',
        ),
        CompanyRoadmapStep(
          order: 2,
          title: 'BUILD YOUR SKILLS',
          detail: 'Develop the technical and soft skills specific to $role.',
          taskCount: 12,
          resourceCount: 5,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 3,
          title: 'REAL PROJECTS',
          detail:
              'Build portfolio projects that demonstrate your capabilities.',
          taskCount: 8,
          resourceCount: 3,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 4,
          title: 'NETWORK ACTIVELY',
          detail: 'Connect with people at $company and attend relevant events.',
          taskCount: 6,
          resourceCount: 2,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 5,
          title: 'INTERVIEW PREP',
          detail:
              'Practice common interview questions and assessments for $company.',
          taskCount: 15,
          resourceCount: 6,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 6,
          title: 'THE FINAL PUSH',
          detail:
              'Polish your application and cover letter specifically for $company.',
          taskCount: 7,
          resourceCount: 3,
          status: 'locked',
        ),
      ],
    );
  }

  // Local fallback so demo never breaks
  DreamCompanyGoal _localFallback(String company, String role) {
    return DreamCompanyGoal(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      company: company,
      role: role,
      experienceLevel: 'newbie',
      youHave: ['Problem Solving', 'Communication', 'Adaptability'],
      youNeed: [
        GapSkill(skill: 'Technical Foundation', level: 'beginner'),
        GapSkill(skill: 'Industry Knowledge', level: 'beginner'),
        GapSkill(skill: 'Relevant Experience', level: 'intermediate'),
      ],
      realityCheck:
          'Landing a $role role at $company takes 6-12 months of focused preparation. Start with the fundamentals.',
      steps: [
        CompanyRoadmapStep(
          order: 1,
          title: 'CORE FOUNDATIONS',
          detail: 'Master the fundamental skills required for this role.',
          taskCount: 10,
          resourceCount: 4,
          status: 'active',
        ),
        CompanyRoadmapStep(
          order: 2,
          title: 'BUILD YOUR SKILLS',
          detail: 'Develop technical and soft skills specific to this role.',
          taskCount: 12,
          resourceCount: 5,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 3,
          title: 'REAL PROJECTS',
          detail:
              'Build portfolio projects that demonstrate your capabilities.',
          taskCount: 8,
          resourceCount: 3,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 4,
          title: 'NETWORK ACTIVELY',
          detail: 'Connect with people at $company and attend relevant events.',
          taskCount: 6,
          resourceCount: 2,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 5,
          title: 'INTERVIEW PREP',
          detail:
              'Practice common interview questions and technical assessments.',
          taskCount: 15,
          resourceCount: 6,
          status: 'locked',
        ),
        CompanyRoadmapStep(
          order: 6,
          title: 'THE FINAL PUSH',
          detail:
              'Polish your application and cover letter specifically for $company.',
          taskCount: 7,
          resourceCount: 3,
          status: 'locked',
        ),
      ],
    );
  }
}
