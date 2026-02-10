import 'dart:async';

import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final AuthLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(HiveServiceProvider);
  final userSessionService = ref.read(UserSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    try {
      final currentUserId = _userSessionService.getCurrentUserId();
      if (currentUserId == null) {
        return Future.value(null);
      }
      final user = _hiveService.getCurrentUser(currentUserId);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);

      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          // username: user.username,
          // profilePicture: user.profileImage ?? '',
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    try {
      await _hiveService.registerUser(user);
      return Future.value(true as FutureOr<AuthHiveModel>?);
    } catch (e) {
      return Future.value(false as FutureOr<AuthHiveModel>?);
    }
  }

  @override
  Future<bool> deleteMe(String userId) async {
    try {
      final ok = await _hiveService.deleteUser(
        userId,
      ); // implement in HiveService
      if (ok == true) {
        await _userSessionService.clearUserSession();
      }
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------
  // New interface methods
  // ----------------------------
  @override
  Future<void> saveUser(AuthHiveModel user) async {
    // if you already store user inside register/login, this can be optional
    await _hiveService.saveUser(user); // implement if needed
  }

  @override
  Future<void> clearUser() async {
    await _hiveService.clearUsers(); // implement if needed
    await _userSessionService.clearUserSession();
  }

  @override
  Future<AuthHiveModel?> getUserbyEmail(String email) {
    // TODO: implement getUserbyEmail
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> getUserbyId(String userId) {
    // TODO: implement getUserbyId
    throw UnimplementedError();
  }

  @override
  Future<AuthHiveModel?> updateUser(AuthHiveModel user) async {
    try {
      final updatedUser = await _hiveService.updateUser(user);

      // Optional: keep session in sync if this is the logged-in user
      final currentUserId = _userSessionService.getCurrentUserId();
      if (updatedUser != null && updatedUser.userId == currentUserId) {
        await _userSessionService.saveUserSession(
          userId: updatedUser.userId!,
          email: updatedUser.email,
        );
      }

      return updatedUser;
    } catch (e) {
      return null;
    }
  }
}
