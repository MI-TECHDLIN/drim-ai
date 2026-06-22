abstract class AppConfig {
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL');

  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
