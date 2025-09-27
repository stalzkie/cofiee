import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/routes.dart';

class ChooseUserView extends StatelessWidget {
  const ChooseUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Welcome to Cofiee'),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.coffee, size: 80, color: CupertinoColors.activeOrange),
                const SizedBox(height: 24),
                const Text(
                  'How do you want to join?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Coffee Lover → Signup
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  child: const Text(
                    'I’m a Coffee Lover',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Shop Owner → Onboarding
                CupertinoButton(
                  color: CupertinoColors.activeOrange,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.onboardingOwner),
                  child: const Text(
                    'I’m a Shop Owner',
                    style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                  ),
                ),
                const SizedBox(height: 32),

                // Already have an account
                CupertinoButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: const Text(
                    'Already have an account? Log in',
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
