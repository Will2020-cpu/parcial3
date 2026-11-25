import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  static Future<void>? _googleInitialization;

  User? get currentUser => _auth.currentUser;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
  }

  Future<void> loginGoogle() async {
    final google = GoogleSignIn.instance;

    await (_googleInitialization ??= google.initialize());

    final account = await google.authenticate();

    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> loginFacebook() async {
    final result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook-login-cancelled',
        message: 'No se pudo completar el inicio con Facebook.',
      );
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
    await FacebookAuth.instance.logOut();
  }
}
