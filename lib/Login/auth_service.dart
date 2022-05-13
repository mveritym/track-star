import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:track_star/Login/authentication.dart';

class AuthService {

  AuthState _loginState = AuthState.loggedOut;
  AuthState get loginState => _loginState;

  Future<void> init(FirebaseOptions firebaseOptions) async {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  Future<void> loginOrRegister() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await _registerAnonymousAccount();
    }
    _loginState = AuthState.loggedIn;
  }

  Future<bool> _registerAnonymousAccount() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      FirebaseAnalytics.instance.setUserId(id: FirebaseAuth.instance.currentUser?.uid);
      _loginState = AuthState.loggedIn;
      return true;
    } on FirebaseAuthException catch (_) {
      throw Error();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _loginState = AuthState.loggedOut;
  }
}