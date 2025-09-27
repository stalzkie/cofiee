import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons; // for icons
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AuthViewModel>();
      if (vm.currentUser != null) {
        _redirectToMap();
      }
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cofiee Login'),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon / title
                const Icon(Icons.coffee, size: 80, color: CupertinoColors.activeOrange),
                const SizedBox(height: 12),
                const Text(
                  "Welcome to Cofiee",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                CupertinoTextField(
                  controller: emailCtrl,
                  focusNode: _emailFocus,
                  placeholder: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 12),

                // Password
                CupertinoTextField(
                  controller: passwordCtrl,
                  focusNode: _passwordFocus,
                  placeholder: 'Password',
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _loginWithEmail(),
                ),
                const SizedBox(height: 16),

                // Login with Email
                CupertinoButton.filled(
                  onPressed: vm.isLoading ? null : _loginWithEmail,
                  child: vm.isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Log in'),
                ),

                const SizedBox(height: 14),

                // Continue with Google
                CupertinoButton(
                  color: CupertinoColors.systemGrey,
                  onPressed: vm.isLoading ? null : _loginWithGoogle,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login, color: CupertinoColors.white, size: 22),
                      const SizedBox(width: 8),
                      vm.isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Go to Signup
                CupertinoButton(
                  onPressed: vm.isLoading
                      ? null
                      : () => Navigator.pushReplacementNamed(context, AppRoutes.signup),
                  child: const Text(
                    "Don’t have an account? Sign up",
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                ),

                const SizedBox(height: 12),

                // Inline error
                if (vm.error != null && vm.error!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      vm.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    final vm = context.read<AuthViewModel>();

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    await vm.loginWithEmail(email, password);
    if (!mounted) return;

    if (vm.error != null) {
      _showErrorDialog(vm.error!);
    } else if (vm.currentUser != null) {
      await vm.postLoginBootstrap();
      _redirectToMap();
    }
  }

  Future<void> _loginWithGoogle() async {
    final vm = context.read<AuthViewModel>();
    await vm.loginWithGoogle();
    if (!mounted) return;

    if (vm.error != null) {
      _showErrorDialog(vm.error!);
    } else if (vm.currentUser != null) {
      await vm.postLoginBootstrap();
      _redirectToMap();
    }
  }

  void _redirectToMap() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.map);
  }

  void _showErrorDialog(String error) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Login Failed"),
        content: Text(error),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
