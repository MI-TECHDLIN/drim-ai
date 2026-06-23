import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/profile.dart';

class ProfileRepository {
  Future<Profile?> getMyProfile() async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<void> updateProfile({
    required String displayName,
    required String ageBand,
    required String educationStage,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase
        .from('profiles')
        .update({
          'display_name': displayName,
          'age_band': ageBand,
          'education_stage': educationStage,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> saveConfidenceScore({
    required String phase,
    required int score,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('confidence_scores').insert({
      'user_id': userId,
      'phase': phase,
      'score': score,
    });
  }

  Future<Map<String, int?>> getConfidenceScores() async {
    if (!AppConfig.isConfigured) return {'pre': null, 'post': null};
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {'pre': null, 'post': null};

    final data = await supabase
        .from('confidence_scores')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    int? pre;
    int? post;
    for (final row in data as List<dynamic>) {
      final phase = row['phase'] as String;
      final score = row['score'] as int;
      if (phase == 'pre' && pre == null) pre = score;
      if (phase == 'post' && post == null) post = score;
      if (pre != null && post != null) break;
    }

    return {'pre': pre, 'post': post};
  }
}
