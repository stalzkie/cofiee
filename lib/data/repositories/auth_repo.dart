import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../../core/services/supabase_client.dart';
import '../../core/utils/enums.dart';
import '../models/profile.dart';
import '../sources/remote/auth_api.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository({AuthApi? api})
      : _api = api ?? AuthApi(SupabaseService().client);

  /// -------------------------
  /// Google Sign-in
  /// -------------------------
  Future<Profile> signInWithGoogle() async {
    try {
      await _api.signInWithGoogle();

      final user = _api.getCurrentUser();
      if (user == null) {
        throw Failure('Google sign-in failed: no user returned.');
      }

      await _api.insertProfileIfMissing(user);

      final profileMap = await SupabaseService().client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromMap(profileMap);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// -------------------------
  /// Email/Password Signup
  /// -------------------------
  Future<Profile> signUpWithEmail(
      String email, String password, String displayName) async {
    try {
      final res = await _api.signUpWithEmail(email, password);
      final user = res.user;
      if (user == null) {
        throw Failure('Email signup failed: no user returned.');
      }

      // Insert into profiles
      await SupabaseService().client.from('profiles').insert({
        'id': user.id,
        'role': 'user',
        'display_name': displayName,
        'photo_url': null,
      });

      final profileMap = await SupabaseService().client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromMap(profileMap);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// -------------------------
  /// Email/Password Login
  /// -------------------------
  Future<Profile> signInWithEmail(String email, String password) async {
    try {
      final res = await _api.signInWithEmail(email, password);
      final user = res.user;
      if (user == null) {
        throw Failure('Email login failed: no user returned.');
      }

      await _api.insertProfileIfMissing(user);

      final profileMap = await SupabaseService().client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromMap(profileMap);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// -------------------------
  /// Current Profile
  /// -------------------------
  Future<Profile?> getCurrentProfile() async {
    try {
      final user = _api.getCurrentUser();
      if (user == null) return null;

      final profileMap = await SupabaseService().client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileMap == null) return null;
      return Profile.fromMap(profileMap);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// -------------------------
  /// Sign Out
  /// -------------------------
  Future<void> signOut() async {
    try {
      await _api.signOut();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// -------------------------
  /// Listen to Auth State
  /// -------------------------
  Stream<AuthState> onAuthStateChange() => _api.onAuthStateChange();
}
