import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:5050/api/';
  // //static const String baseUrl = 'http://localhost:3000/api/v1';
  // // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const bool isPhysicalDevice = false;
  static const String compIpAddress = '192.168.1.105';

  static String getHostUrl() {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }

    if (kIsWeb) {
      return 'http://localhost:5050'; // web runs on same machine
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050'; // android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:5050'; // iOS simulator
    } else {
      return 'http://localhost:5050';
    }
  }

  static String getBaseUrl() {
    return '${getHostUrl()}/api'; // ✅ API base (no trailing slash)
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Category Endpoints ============
  // static const String categories = '/categories';
  // static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String users = 'auth';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register/';
  static const String whoAmI = 'auth/whoamI';

  static String userById(String id) => '/auth/$id';
  static String userPhoto(String id) => '/auth/update-profile';

  // ============ Item Endpoints ============
  // static const String items = '/items';
  // static String itemById(String id) => '/items/$id';
  // static String itemClaim(String id) => '/items/$id/claim';

  // ============ Comment Endpoints ============
  // static const String comments = '/comments';
  // static String commentById(String id) => '/comments/$id';
  // static String commentsByItem(String itemId) => '/comments/item/$itemId';
  // static String commentLike(String id) => '/comments/$id/like';
}
