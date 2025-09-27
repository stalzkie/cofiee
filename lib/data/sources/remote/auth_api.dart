import 'package:supabase_flutter/supabase_flutter.dart';

/// Low-level wrapper for Supabase Auth
/// Keep business rules (like inserting into `profiles`) in the repository layer.
class AuthApi {
  final SupabaseClient client;

  AuthApi(this.client);

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.cofiee://login-callback/',
    );
  }

  /// Sign up with email + password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
    );
    return res;
  }

  /// Sign in with email + password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  /// Sign out current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Get the current session (if any)
  Session? getCurrentSession() {
    return client.auth.currentSession;
  }

  /// Get the current user (if any)
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Listen for auth state changes (SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED, etc.)
  Stream<AuthState> onAuthStateChange() {
    return client.auth.onAuthStateChange;
  }

  /// Insert into profiles table if missing
  Future<void> insertProfileIfMissing(User user) async {
    final existing = await client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await client.from('profiles').insert({
        'id': user.id,
        'role': 'user',
        'display_name': user.userMetadata?['full_name'] ?? user.email,
        'photo_url': user.userMetadata?['avatar_url'],
      });
    }
  }
}
