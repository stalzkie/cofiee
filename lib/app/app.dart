import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../ui/viewmodels/auth_viewmodel.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel()..checkSession(),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Cofiee',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeOrange,
          brightness: Brightness.light,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
