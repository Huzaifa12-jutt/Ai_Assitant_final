import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/app_database.dart';
import 'auth_state.dart';

const _prefsUserIdKey = 'auth.currentUserId';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AppDatabase db,
    required SharedPreferences prefs,
  })  : _db = db,
        _prefs = prefs,
        super(const AuthState.loading()) {
    _init();
  }

  final AppDatabase _db;
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  Future<void> _init() async {
    final id = _prefs.getInt(_prefsUserIdKey);
    if (id == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    final user = await _db.getUserById(id);
    if (user == null) {
      await _prefs.remove(_prefsUserIdKey);
      state = const AuthState.unauthenticated();
      return;
    }
    state = AuthState.authenticated(user);
  }

  static String _hashPassword({
    required String password,
    required String salt,
  }) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  static String _newSalt() => _uuid.v4();

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final existing = await _db.getUserByEmail(normalizedEmail);
      if (existing != null) {
        state = const AuthState(isLoading: false, user: null, error: 'Email already registered');
        return false;
      }

      final salt = _newSalt();
      final hash = _hashPassword(password: password, salt: salt);
      await _db.createUser(
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: hash,
        passwordSalt: salt,
      );
      // Do NOT auto-login after registration. User must login explicitly.
      state = const AuthState.unauthenticated();
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, user: null, error: e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final user = await _db.getUserByEmail(normalizedEmail);
      if (user == null) {
        state = const AuthState(isLoading: false, user: null, error: 'Invalid email or password');
        return false;
      }

      final hash = _hashPassword(password: password, salt: user.passwordSalt);
      if (hash != user.passwordHash) {
        state = const AuthState(isLoading: false, user: null, error: 'Invalid email or password');
        return false;
      }

      await _prefs.setInt(_prefsUserIdKey, user.id);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState(isLoading: false, user: null, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_prefsUserIdKey);
    state = const AuthState.unauthenticated();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    final current = state.user;
    if (current == null) return false;

    final ok = await _db.updateUserProfile(
      id: current.id,
      name: name,
      email: email,
    );
    if (!ok) return false;

    final refreshed = await _db.getUserById(current.id);
    if (refreshed == null) return false;
    state = AuthState.authenticated(refreshed);
    return true;
  }
}

