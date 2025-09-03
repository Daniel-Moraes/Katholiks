import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katholiks/utils/app_colors.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/rosary/rosary_home_screen.dart';
import '../screens/rosary/rosary_tutorial_screen.dart';
import '../services/auth_service.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String rosary = '/rosary';
  static const String rosaryTutorial = '/rosary/tutorial';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,

    // Redirect logic for authentication
    redirect: (BuildContext context, GoRouterState state) {
      final authService = AuthService.instance;
      final isAuthenticated = authService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToSplash = state.matchedLocation == splash;

      if (!isAuthenticated &&
          !isGoingToLogin &&
          !isGoingToRegister &&
          !isGoingToSplash) {
        return login;
      }

      if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
        return home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: rosary,
        name: 'rosary',
        builder: (BuildContext context, GoRouterState state) {
          return const RosaryHomeScreen();
        },
      ),
      GoRoute(
        path: rosaryTutorial,
        name: 'rosaryTutorial',
        builder: (BuildContext context, GoRouterState state) {
          return const RosaryTutorialScreen();
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erro de Navegação'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Erro: ${state.error}',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
}

extension AppNavigationHelper on BuildContext {
  // Basic navigation
  void goToSplash() => go(AppRoutes.splash);
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToHome() => go(AppRoutes.home);
  void goToProfile() => go(AppRoutes.profile);

  // Push navigation (keeps previous route in stack)
  void pushLogin() => push(AppRoutes.login);
  void pushRegister() => push(AppRoutes.register);
  void pushProfile() => push(AppRoutes.profile);

  // Replace navigation (replaces current route)
  void replaceWithLogin() => pushReplacement(AppRoutes.login);
  void replaceWithHome() => pushReplacement(AppRoutes.home);

  // Clear stack and navigate (equivalent to pushNamedAndRemoveUntil)
  void clearAndGoToLogin() => go(AppRoutes.login);
  void clearAndGoToHome() => go(AppRoutes.home);
}
