import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/feed_screen.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

final authNotifier = AuthNotifier();

final router = GoRouter(
  initialLocation: '/login',
  refreshListenable: authNotifier,

  redirect: (context, state) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final path = state.matchedLocation;

    final isAuthRoute = path == '/login' || path == '/registro';

    if (!logged && !isAuthRoute) {
      return '/login';
    }

    if (logged && isAuthRoute) {
      return '/feed';
    }

    return null;
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
  ],
);
