import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> initSupabase() async {
  if (!AppConfig.isConfigured) return;
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}
