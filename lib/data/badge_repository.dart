import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/user_badge.dart';

class BadgeRepository {
  Future<List<UserBadge>> getMyBadges() async {
    if (!AppConfig.isConfigured) return [];
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('user_badges')
        .select()
        .eq('user_id', userId)
        .order('earned_at', ascending: true);

    return (data as List)
        .map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Awards a badge if not already earned. Returns badge id if newly awarded, null if already had it.
  Future<String?> awardBadge(String badgeId) async {
    if (!AppConfig.isConfigured) return null;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      await supabase.from('user_badges').insert({
        'user_id': userId,
        'badge_id': badgeId,
      });
      return badgeId;
    } catch (_) {
      // Already earned (unique constraint) — not an error
      return null;
    }
  }

  Future<bool> hasBadge(String badgeId) async {
    if (!AppConfig.isConfigured) return false;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final data = await supabase
        .from('user_badges')
        .select('id')
        .eq('user_id', userId)
        .eq('badge_id', badgeId)
        .maybeSingle();

    return data != null;
  }

  /// Check all badge conditions and award any that have been met
  Future<String?> checkAndAwardBadges({
    int? skillsDoneCount,
    int? streakDays,
    int? confidenceScore,
    bool dreamChaserTriggered = false,
    bool pathfinderTriggered = false,
  }) async {
    String? newBadge;

    if (skillsDoneCount != null && skillsDoneCount >= 1) {
      final awarded = await awardBadge('first_step');
      newBadge ??= awarded;
    }

    if (skillsDoneCount != null && skillsDoneCount >= 5) {
      final awarded = await awardBadge('skill_master');
      newBadge ??= awarded;
    }

    if (streakDays != null && streakDays >= 14) {
      final awarded = await awardBadge('iron_discipline');
      newBadge ??= awarded;
    }

    if (dreamChaserTriggered) {
      final awarded = await awardBadge('dream_chaser');
      newBadge ??= awarded;
    }

    if (confidenceScore != null && confidenceScore >= 8) {
      final awarded = await awardBadge('confident');
      newBadge ??= awarded;
    }

    if (pathfinderTriggered) {
      final awarded = await awardBadge('pathfinder');
      newBadge ??= awarded;
    }

    return newBadge;
  }
}