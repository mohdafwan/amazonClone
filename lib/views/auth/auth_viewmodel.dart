// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:amazon_clone/data/repositories/auth_repo/auth_remote_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, User?>((
  ref,
) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthViewModel extends StateNotifier<User?> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(null);

  Future<void> signInWithGoogle() async {
    try {
      UserCredential? userCredential = await _authRepository.signInWithGoogle();
      if (userCredential != null) {
        state = userCredential.user;
      }
    } catch (e) {
      state = null;
      log('Login with GoogleAuth Failed: $e');
    }
  }

  Future<void> createAccountWithUserNameAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential? userCredential = await _authRepository
          .createAccountWithUserNameAndPassword(email, password);
      state = userCredential.user;
      context.go('/main');
    } catch (e) {
      state = null;
      log('Create Account with UserName and Password Failed: $e');
    }
  }

  Future<dynamic> signInWithUserNameAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential? userCredential = await _authRepository
          .signInWithUserNameAndPassword(email, password);
      if (userCredential != null) {
        state = userCredential.user;
      }
    } catch (e) {
      state = null;
      log('Login with UserName and Password Failed: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authRepository.signOut();
      state = null;
      context.go('/splash');
    } catch (e) {
      log('Sign out failed: $e');
    }
  }
}
