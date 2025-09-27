import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../ui/views/auth/login_view.dart';
import '../ui/views/auth/signup_view.dart';
import '../ui/views/map/map_view.dart';
import '../ui/views/splash_view.dart';
import '../ui/views/auth/onboarding_owner_view.dart';
import '../ui/views/auth/choose_user_view.dart';
import '../ui/views/shop_detail/shop_detail_view.dart';
import '../ui/viewmodels/shop_detail_viewmodel.dart'; // 👈 import ViewModel

class AppRoutes {
  static const String splash          = '/';
  static const String login           = '/login';
  static const String signup          = '/signup';
  static const String map             = '/map';
  static const String onboardingOwner = '/onboarding-owner';
  static const String chooseUser      = '/choose-user';
  static const String shopDetail      = '/shop-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return CupertinoPageRoute(builder: (_) => const SplashView());
      case signup:
        return CupertinoPageRoute(builder: (_) => const SignupView());
      case login:
        return CupertinoPageRoute(builder: (_) => const LoginView());
      case map:
        return CupertinoPageRoute(builder: (_) => const MapView());
      case onboardingOwner:
        return CupertinoPageRoute(builder: (_) => const OnboardingOwnerView());
      case chooseUser:
        return CupertinoPageRoute(builder: (_) => const ChooseUserView());
      case shopDetail:
        final shopId = settings.arguments as String;
        return CupertinoPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ShopDetailViewModel(),
            child: ShopDetailView(shopId: shopId),
          ),
        );
      default:
        return CupertinoPageRoute(builder: (_) => const SplashView());
    }
  }
}
