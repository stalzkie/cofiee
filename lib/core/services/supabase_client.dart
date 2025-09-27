import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/env.dart';
import '../error/failure.dart';

/// Singleton class to hold the Supabase client
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  /// Initialize Supabase — call this once in main.dart before runApp()
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      _instance.client = Supabase.instance.client;
    } catch (e) {
      throw Failure('Failed to initialize Supabase: $e');
    }
  }

  /// Get the Supabase client anywhere
  static SupabaseClient getClient() => _instance.client;
}
