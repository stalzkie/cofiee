import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // for Google icon
import 'package:provider/provider.dart';

import '../../../ui/viewmodels/auth_viewmodel.dart';
import '../../../app/routes.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sign Up'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoTextField(
                controller: nameCtrl,
                placeholder: 'Full Name',
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: emailCtrl,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: passwordCtrl,
                placeholder: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Create account with email/password
              CupertinoButton.filled(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        await vm.signupWithEmail(
                          emailCtrl.text.trim(),
                          passwordCtrl.text.trim(),
                          nameCtrl.text.trim(),
                        );
                        if (vm.error != null) {
                          _showErrorDialog(context, vm.error!);
                        } else if (vm.currentUser != null && context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.map);
                        }
                      },
                child: vm.isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text("Create Account"),
              ),

              const SizedBox(height: 16),

              // Signup with Google
              CupertinoButton(
                color: CupertinoColors.systemGrey,
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        await vm.loginWithGoogle();
                        if (vm.error != null) {
                          _showErrorDialog(context, vm.error!);
                        } else if (vm.currentUser != null && context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.map);
                        }
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.g_mobiledata, color: CupertinoColors.white, size: 28),
                    const SizedBox(width: 6),
                    vm.isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : const Text(
                            "Sign Up with Google",
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Go to login
              CupertinoButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text(
                  "Already have an account? Log in",
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Signup Failed"),
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
