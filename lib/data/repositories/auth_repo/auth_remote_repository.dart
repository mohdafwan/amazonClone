import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    _googleSignIn.signOut();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        log('User: ${userCredential.user!.displayName}');
        return userCredential;
      }
    } catch (e) {
      throw Exception('Google Sign-In Failed: $e');
    }
    return null;
  }

  Future<UserCredential> createAccountWithUserNameAndPassword(
    String email,
    String password,
  ) async {
    try {
      log('Email: $email, Password: $password');
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This user has been disabled.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password sign-in is not enabled.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('The supplied auth credential is incorrect, malformed or has expired.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign-up Failed: $e');
    }
  }

  Future<dynamic> signInWithUserNameAndPassword(
    String email,
    String password,
  ) async {
    try {
      log('Email: $email, Password: $password');
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This user has been disabled.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password sign-in is not enabled.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('The supplied auth credential is incorrect, malformed or has expired.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign-in Failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
