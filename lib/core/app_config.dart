abstract class AppConfig {
  static const String _defaultSupabaseUrl = 'your supabase url';
  static const String _defaultSupabaseAnonKey = 'your key';

  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );

  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
