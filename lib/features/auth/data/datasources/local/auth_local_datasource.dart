import 'dart:async';

import 'package:click_shop/core/services/hive/hive_service.dart';
import 'package:click_shop/core/services/storage/user_session_service.dart';
import 'package:click_shop/features/auth/data/datasources/auth_datasources.dart';
import 'package:click_shop/features/auth/data/models/auth_hive_model.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
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
    // TODO: implement getCurrentUser
    throw UnimplementedError();
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
  Future<AuthHiveModel?> deleteUser(String userId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
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
  Future<AuthHiveModel?> updateUser(String user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  // @override
  // Future<bool> register(AuthHiveModel user) async {
  //   try {
  //     await _hiveService.registerUser(user);
  //     return Future.value(true);
  //   } catch (e) {
  //     return Future.value(false);
  //   }
  // }
}
