import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/env.dart';
import '../error/failure.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() => _instance;

  SupabaseService._internal();

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

  /// ✅ Now you can just call SupabaseService.instanceClient
  static SupabaseClient get instanceClient => _instance.client;
}
