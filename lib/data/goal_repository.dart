import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/user_goal.dart';

class GoalRepository {
  Future<UserGoal?> getActiveGoal() async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('user_goals')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return UserGoal.fromJson(data);
  }

  Future<UserGoal> setGoal({
    required int durationMonths,
    required DateTime targetDate,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Deactivate existing goals
    await supabase
        .from('user_goals')
        .update({'is_active': false})
        .eq('user_id', userId);

    final data = await supabase
        .from('user_goals')
        .insert({
          'user_id': userId,
          'duration_months': durationMonths,
          'target_date': targetDate.toIso8601String().split('T')[0],
          'is_active': true,
        })
        .select()
        .single();

    return UserGoal.fromJson(data);
  }
}