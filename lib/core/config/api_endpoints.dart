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

  static const bool isPhysicalDevice = true;
  static const String compIpAddress = '192.168.1.105';

  static String getHostUrl() {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050';
    }
    if (kIsWeb) {
      return 'http://localhost:5050';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050'; // android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:5050'; // iOS simulator
    } else {
      return 'http://localhost:5050';
    }
  }

  static String getBaseUrl() {
    return '${getHostUrl()}/api/';
  }

  static String buildFileUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;

    return "${getHostUrl()}${path.startsWith("/") ? "" : "/"}$path";
  }

  static Future<bool> isRealDevice() async {
    if (!Platform.isAndroid) return true;
    // Android emulator usually has these props; simplest approach:
    return !const bool.fromEnvironment('dart.vm.product') ? true : true;
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Category Endpoints ============
  // static const String categories = '/categories';
  // static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String auth = 'auth';

  static const String userLogin = '$auth/login';
  static const String userRegister = '$auth/register';
  static const String whoAmI = '$auth/whoamI';

  static const String updateProfile = '$auth/update-profile';
  static const String deleteMe = '$auth/me';

  static const String requestPasswordReset = '$auth/request-password-reset';
  static String resetPassword = '$auth/reset-password';
  static String saveFcmToken = '$auth/me/fcm-token';
  static String userById(String id) => '/auth/$id';
  static String userPhoto(String id) => '/auth/update-profile';

  // ============ Item Endpoints ============
  static const String products = "products";

  static String getAllProducts() => products; // GET /api/products
  static String getProductById(String id) =>
      "$products/$id"; // GET /api/products/:id
  static String getByCategory(String category) =>
      "$products/category/$category"; // GET /api/products/category/:category

  static String recent() => "$products/recent"; // GET /api/products/recent
  static String trending() =>
      "$products/trending"; // GET /api/products/trending
  static String popular() => "$products/popular"; // GET /api/products/popular
  static String topRated() =>
      "$products/top-rated"; // GET /api/products/top-rated

  static String incrementView(String id) =>
      "$products/$id/view"; // PATCH /api/products/:id/view

  // admin (if you call from admin app)
  static String createProduct() => products; // POST /api/products
  static String updateProduct(String id) =>
      "$products/$id"; // PUT /api/products/:id
  static String deleteProduct(String id) =>
      "$products/$id"; // DELETE /api/products/:id
  static String restockProduct(String id) =>
      "$products/$id/restock"; // PUT /api/products/:id/restock

  // cart
  static String cartGet() => "cart"; // GET /api/cart
  static String cartAdd() => "cart/items"; // POST /api/cart/items
  static String updateCartQty(String productId) =>
      "cart/items/$productId"; // PATCH
  static String deleteCartItem(String productId) =>
      "cart/items/$productId"; // DELETE
  static String clearCart() => "cart"; // DELETE /api/cart

  static const String base = "/api/orders";

  // user
  // orders
  static const String orders = "orders";

  static const String createOrder = orders; // POST /api/orders
  static const String myOrders = "$orders/me"; // GET  /api/orders/me
  static String orderById(String id) => "$orders/$id"; // GET /api/orders/:id
  static String cancelOrder(String id) => "$orders/orders/$id/cancel";

  static const String driverOrders = "$orders/driver/my-orders";

  static const String allOrders = orders;
  static String updateStatus(String id) => "$orders/$id/status";
  static String assignDriver(String id) => "$orders/$id/assign-driver";

  // Driver
  static const String driverMyOrders = "/orders/driver/my-orders";
  static String driverUpdateOrderStatus(String orderId) =>
      "/orders/driver/$orderId/status";

  //Notifications
  static const String notifications = "notifications";

  // user
  static String myNotifications() => "$notifications/me";
  static String notificationUnreadCount() => "$notifications/me/unread-count";
  static String markAllNotificationsRead() => "$notifications/me/read-all";
  static String markNotificationRead(String id) => "$notifications/$id/read";

  // admin/system
  static String createNotification() => notifications;
}
