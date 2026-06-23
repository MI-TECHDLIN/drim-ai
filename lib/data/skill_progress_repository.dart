import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/career_match.dart';
import '../models/skill_progress.dart';

class SkillProgressRepository {
  Future<void> initializeSkills(String matchId, List<SkillTag> skills) async {
    if (!AppConfig.isConfigured) return;
    if (matchId.startsWith('fallback-')) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final existing = await supabase
        .from('skill_progress')
        .select('skill_name')
        .eq('user_id', userId)
        .eq('match_id', matchId);

    final existingNames = (existing as List)
        .map((e) => e['skill_name'] as String)
        .toSet();

    final toInsert = skills
        .where((s) => !existingNames.contains(s.name))
        .map(
          (s) => {
            'user_id': userId,
            'match_id': matchId,
            'skill_name': s.name,
            'status': 'not_started',
          },
        )
        .toList();

    if (toInsert.isNotEmpty) {
      await supabase.from('skill_progress').insert(toInsert);
    }
  }

  Future<List<SkillProgress>> getSkills(String matchId) async {
    if (!AppConfig.isConfigured) return [];
    if (matchId.startsWith('fallback-')) return [];

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('skill_progress')
        .select()
        .eq('user_id', userId)
        .eq('match_id', matchId)
        .order('skill_name');

    return (data as List)
        .map((e) => SkillProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus(String skillId, String newStatus) async {
    if (!AppConfig.isConfigured) return;
    if (skillId.startsWith('local_')) return; // local-only, no DB

    await supabase
        .from('skill_progress')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', skillId);
  }
}
