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
}
