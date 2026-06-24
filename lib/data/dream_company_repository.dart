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
    if (!AppConfig.isConfigured) return null;

    try {
      final response = await supabase.functions.invoke(
        'analyze-gap',
        body: {
          'company': company,
          'role': role,
          'experienceLevel': experienceLevel,
          'userProfile': userProfile,
        },
      );

      if (response.data == null) return null;
      final data = response.data as Map<String, dynamic>;
      return DreamCompanyGoal.fromJson(data['goal'] as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
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
}
