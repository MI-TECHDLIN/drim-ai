import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/user_activity.dart';

class ActivityRepository {
  Future<void> logActivity({
    required String activityType,
    int intensity = 1,
  }) async {
    if (!AppConfig.isConfigured) return;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('user_activity').insert({
        'user_id': userId,
        'activity_type': activityType,
        'activity_date': DateTime.now().toIso8601String().split('T')[0],
        'intensity': intensity,
      });
    } catch (_) {
      // Non-blocking
    }
  }

  /// Returns activity map: date string → total intensity for heatmap
  Future<Map<String, int>> getActivityMap() async {
    if (!AppConfig.isConfigured) return _demoActivityMap();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return _demoActivityMap();

    final cutoff = DateTime.now().subtract(
      const Duration(days: 84),
    ); // 12 weeks
    final data = await supabase
        .from('user_activity')
        .select('activity_date, intensity')
        .eq('user_id', userId)
        .gte('activity_date', cutoff.toIso8601String().split('T')[0]);

    final map = <String, int>{};
    for (final row in data as List<dynamic>) {
      final date = row['activity_date'] as String;
      final intensity = row['intensity'] as int? ?? 1;
      map[date] = (map[date] ?? 0) + intensity;
    }

    // If no real data exists, show demo data so heatmap isn't empty
    if (map.isEmpty) return _demoActivityMap();
    return map;
  }

  Future<int> getCurrentStreak() async {
    if (!AppConfig.isConfigured) return 14;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final data = await supabase
        .from('user_activity')
        .select('activity_date')
        .eq('user_id', userId)
        .order('activity_date', ascending: false);

    if ((data as List).isEmpty) return 0;

    final dates =
        data
            .map((e) => e['activity_date'] as String)
            .toSet()
            .map((s) => DateTime.parse(s))
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime expected = DateTime.now();
    for (final date in dates) {
      final diff = expected.difference(date).inDays;
      if (diff <= 1) {
        streak++;
        expected = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> getBestStreak() async {
    if (!AppConfig.isConfigured) return 18;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final data = await supabase
        .from('user_activity')
        .select('activity_date')
        .eq('user_id', userId)
        .order('activity_date', ascending: true);

    if ((data as List).isEmpty) return 0;

    final dates =
        data
            .map((e) => DateTime.parse(e['activity_date'] as String))
            .toSet()
            .toList()
          ..sort();

    int best = 0;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    if (best == 0 && dates.isNotEmpty) best = 1;
    return best;
  }

  Future<int> getThisMonthCount() async {
    if (!AppConfig.isConfigured) return 24;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      1,
    ).toIso8601String().split('T')[0];

    final data = await supabase
        .from('user_activity')
        .select('id')
        .eq('user_id', userId)
        .gte('activity_date', start);

    return (data as List).length;
  }

  Future<int> getWeeklyScore() async {
    if (!AppConfig.isConfigured) return 850;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final weekStart = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String()
        .split('T')[0];

    final data = await supabase
        .from('user_activity')
        .select('intensity')
        .eq('user_id', userId)
        .gte('activity_date', weekStart);

    int total = 0;
    for (final row in data as List<dynamic>) {
      total += (row['intensity'] as int? ?? 1) * 100;
    }
    return total;
  }

  // Demo heatmap data so screen never looks empty
  Map<String, int> _demoActivityMap() {
    final map = <String, int>{};
    final now = DateTime.now();
    final random = [
      0,
      0,
      1,
      0,
      2,
      1,
      0,
      2,
      3,
      1,
      2,
      0,
      1,
      2,
      3,
      2,
      1,
      3,
      4,
      2,
      3,
      1,
      2,
      4,
      3,
      4,
      3,
      2,
      4,
      3,
      1,
      4,
      3,
      4,
      3,
      2,
    ];
    for (int i = 0; i < 84; i++) {
      final date = now.subtract(Duration(days: 83 - i));
      final key = date.toIso8601String().split('T')[0];
      final intensity = random[i % random.length];
      if (intensity > 0) map[key] = intensity;
    }
    return map;
  }
}
