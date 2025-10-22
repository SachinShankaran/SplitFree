import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitfree/features/groups/screens/home_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const AuthPage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showLogin = true;
  void _toggleView() => setState(() => _showLogin = !_showLogin);

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(onSwitchToRegister: _toggleView);
    } else {
      return SignUpScreen(onSwitchToLogin: _toggleView);
    }
  }
}