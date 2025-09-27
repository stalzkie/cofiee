import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/supabase_client.dart';
import 'app/app.dart';
import 'ui/viewmodels/auth_viewmodel.dart';
import 'ui/viewmodels/map_viewmodel.dart';
import 'ui/viewmodels/shop_detail_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => ShopDetailViewModel()), // 👈 added
      ],
      child: const MyApp(),
    ),
  );
}
