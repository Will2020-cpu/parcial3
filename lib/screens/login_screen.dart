import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool loading = false;

  Future<void> execute(Future<void> Function() action) async {
    if (loading) return;

    setState(() => loading = true);

    try {
      await action();
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' => 'Correo o contraseña incorrectos.',
        'invalid-email' => 'El correo no es válido.',
        'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
        _ => e.message ?? 'Error de autenticación.',
      };

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 15),
                const Text(
                  'APP PARCIAL WILLIAN CAMACHO',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(value.trim())) {
                      return 'Introduce un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'La contraseña es obligatoria'
                      : null,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              execute(
                                () => _auth.login(_email.text, _password.text),
                              );
                            }
                          },
                    child: const Text('Iniciar sesión'),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: loading ? null : () => execute(_auth.loginGoogle),
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continuar con Google'),
                ),

                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => execute(_auth.loginFacebook),
                  icon: const Icon(Icons.facebook),
                  label: const Text('Continuar con Facebook'),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => context.go('/registro'),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
