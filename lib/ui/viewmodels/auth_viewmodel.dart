import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile.dart';
import '../../data/repositories/auth_repo.dart';
import '../../core/error/failure.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  Profile? currentUser;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => currentUser != null;

  /// Try to restore session and load profile
  Future<void> checkSession() async {
    _setLoading(true);
    try {
      final profile = await _repo.getCurrentProfile();
      currentUser = profile;
      error = null;
      if (currentUser != null) {
        await postLoginBootstrap(); // ensure profile exists
      }
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// -------------------------
  /// Google Login
  /// -------------------------
  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      final profile = await _repo.signInWithGoogle();
      currentUser = profile;
      error = null;
      if (currentUser != null) {
        await postLoginBootstrap();
      }
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// -------------------------
  /// Email Signup
  /// -------------------------
  Future<void> signupWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    try {
      final profile =
          await _repo.signUpWithEmail(email, password, displayName);
      currentUser = profile;
      error = null;
      if (currentUser != null) {
        await postLoginBootstrap();
      }
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// -------------------------
  /// Email Login
  /// -------------------------
  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final profile = await _repo.signInWithEmail(email, password);
      currentUser = profile;
      error = null;
      if (currentUser != null) {
        await postLoginBootstrap();
      }
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// -------------------------
  /// Logout
  /// -------------------------
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.signOut();
      currentUser = null;
      error = null;
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// -------------------------
  /// Listen to auth changes
  /// -------------------------
  void listenAuthStateChanges() {
    _repo.onAuthStateChange().listen((event) {
      if (event.session == null) {
        currentUser = null;
        notifyListeners();
      } else {
        checkSession(); // reload profile if logged in
      }
    });
  }

  /// -------------------------
  /// Bootstrap: ensure profile row exists in Supabase
  /// -------------------------
  Future<void> postLoginBootstrap() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final meta = user.userMetadata ?? {};
    final displayName = (meta['full_name'] ?? user.email ?? '').toString();
    final avatarUrl = (meta['avatar_url'] ?? '').toString();

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'display_name':
            displayName.isEmpty ? 'Cofiee User' : displayName,
        'photo_url': avatarUrl,
      }, onConflict: 'id');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to bootstrap profile: $e');
      }
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
