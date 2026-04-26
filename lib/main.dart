import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_routes.dart';
import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/provider_provider.dart';
import 'providers/review_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/provider_dashboard/provider_dashboard_screen.dart';
import 'screens/provider_profile/provider_profile_screen.dart';
import 'screens/questionnaire/questionnaire_screen.dart';
import 'screens/reviews/reviews_list_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/user_profile/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DrapoApp());
}

class DrapoApp extends StatelessWidget {
  const DrapoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProviderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: 'DRAPO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        // Auth guard: if the user is signed out from anywhere in the app,
        // the navigator listener in AuthProvider will push login.
        // Additional route-level guard is in MainWrapper.
        routes: {
          AppRoutes.splash:             (_) => const SplashScreen(),
          AppRoutes.onboarding:         (_) => const OnboardingScreen(),
          AppRoutes.login:              (_) => const LoginScreen(),
          AppRoutes.signup:             (_) => const SignupScreen(),
          AppRoutes.home:               (_) => const AuthGuard(child: MainWrapper()),
          AppRoutes.search:             (_) => const SearchScreen(),
          AppRoutes.providerProfile:    (_) => const ProviderProfileScreen(),
          AppRoutes.reviewsList:        (_) => const ReviewsListScreen(),
          AppRoutes.questionnaire:      (_) => const AuthGuard(child: QuestionnaireScreen()),
          AppRoutes.userProfile:        (_) => const AuthGuard(child: UserProfileScreen()),
          AppRoutes.providerDashboard:  (_) => const AuthGuard(child: ProviderDashboardScreen()),
          AppRoutes.settings:           (_) => const AuthGuard(child: SettingsScreen()),
        },
      ),
    );
  }
}

/// Wraps any route that requires authentication.
/// If the user signs out, they are immediately redirected to login
/// with no blank screen flash.
class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    if (!isLoggedIn) {
      // Schedule navigation after the current frame to avoid build-phase errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (_) => false);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return child;
  }
}
