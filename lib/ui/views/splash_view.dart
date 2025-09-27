import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../ui/viewmodels/auth_viewmodel.dart';
import '../../../app/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final vm = context.read<AuthViewModel>();
    await vm.checkSession();

    if (!mounted) return;

    if (vm.currentUser != null) {
      // ✅ Logged in → go to map/dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.map);
    } else {
      // ❌ Not logged in → go to signup
      Navigator.pushReplacementNamed(context, AppRoutes.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: 16,
          color: CupertinoColors.activeOrange,
        ),
      ),
    );
  }
}
