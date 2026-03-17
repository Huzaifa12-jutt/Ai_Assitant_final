import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final appDatabaseProvider = Provider<AppDatabase>((_) => AppDatabase());

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return AuthController(db: db, prefs: prefs);
});

