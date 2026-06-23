import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drim_ai/core/supabase_client.dart';
import 'package:drim_ai/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const ProviderScope(child: DrimApp()));
}
