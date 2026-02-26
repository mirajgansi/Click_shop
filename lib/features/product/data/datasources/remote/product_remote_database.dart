import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRemoteDatabaseProvider = Provider<IProductRemoteDatabase>((ref) {
  return ProductRemoteDatabase(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProductRemoteDatabase implements IProductRemoteDatabase {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProductRemoteDatabase({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenService
        .getToken(); // adjust if your method name differs
    if (token == null || token.isEmpty) return {};
    return {"Authorization": "Bearer $token"};
  }

  // Helper to parse list safely
  List<ProductApiModel> _parseProductList(dynamic data) {
    final list =
        (data["data"]?["products"] ?? data["products"] ?? data["data"] ?? data)
            as List;

    return list
        .map((e) => ProductApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =============================
  // GET ALL PRODUCTS
  // =============================
  @override
  Future<List<ProductApiModel>> getAllproduct({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.getAllProducts(),
        queryParameters: {
          "page": page,
          "size": size,
          if (search != null && search.trim().isNotEmpty)
            "search": search.trim(),
        },
      );

      return _parseProductList(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch products",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching products");
    }
  }

  // =============================
  // GET PRODUCT BY ID
  // =============================
  @override
  Future<ProductApiModel> getProductbyId(String productId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getProductById(productId),
      );

      final data = response.data["data"] ?? response.data;

      return ProductApiModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch product",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching product");
    }
  }

  // =============================
  // GET BY CATEGORY
  // =============================
  @override
  Future<List<ProductApiModel>> getProductsByCategory(String categoryId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.getByCategory(categoryId));

      return _parseProductList(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch category products",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching category products");
    }
  }

  // =============================
  // GET RECENT
  // =============================
  @override
  Future<List<ProductApiModel>> getRecent() async {
    try {
      final url = ApiEndpoints.recent();
      debugPrint("🔵 CALLING RECENT: $url");

      final res = await _apiClient.get(url);

      final list = _parseProductList(res.data);

      debugPrint(
        "🔵 RECENT RESULT: ${list.map((e) => e.name).take(5).toList()}",
      );

      return list;
    } catch (e) {
      throw Exception("Failed to fetch recent products");
    }
  }

  // =============================
  // GET TRENDING
  // =============================
  @override
  Future<List<ProductApiModel>> getTrending() async {
    try {
      final url = ApiEndpoints.trending();
      debugPrint("🟢 CALLING TRENDING: $url");

      final res = await _apiClient.get(url);

      final list = _parseProductList(res.data);

      debugPrint(
        "🟢 TRENDING RESULT: ${list.map((e) => e.name).take(5).toList()}",
      );

      return list;
    } catch (e) {
      throw Exception("Failed to fetch trending products");
    }
  }

  @override
  Future<List<ProductApiModel>> getPopular() async {
    try {
      final url = ApiEndpoints.popular();
      debugPrint("🟣 CALLING POPULAR: $url");

      final res = await _apiClient.get(url);

      final list = _parseProductList(res.data);

      debugPrint(
        "🟣 POPULAR RESULT: ${list.map((e) => e.name).take(5).toList()}",
      );

      return list;
    } catch (e) {
      throw Exception("Failed to fetch popular products");
    }
  }

  @override
  Future<List<ProductApiModel>> getTopRated() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.topRated());
      return _parseProductList(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch top rated products",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching top rated products");
    }
  }

  // @override
  // Future<List<ProductApiModel>> getOutOfStock() async {
  //   try {
  //     final res = await _apiClient.get(ApiEndpoints.outOfStock());
  //     return _parseProductList(res.data);
  //   } on DioException catch (e) {
  //     throw Exception(
  //       e.response?.data?["message"] ?? "Failed to fetch out-of-stock products",
  //     );
  //   } catch (e) {
  //     throw Exception("Unexpected error while fetching out-of-stock products");
  //   }
  // }

  @override
  Future<void> incrementViewCount(String productId) async {
    try {
      await _apiClient.patch(ApiEndpoints.incrementView(productId));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to increment view count",
      );
    } catch (e) {
      throw Exception("Unexpected error while incrementing view count");
    }
  }

  @override
  Future<List<ProductApiModel>> getOutOfStock() {
    // TODO: implement getOutOfStock
    throw UnimplementedError();
  }

  @override
  Future<ProductApiModel> rateProduct({
    required String productId,
    required double rating,
  }) async {
    try {
      final headers = await _authHeaders();

      final res = await _apiClient.post(
        ApiEndpoints.rateProduct(productId),
        data: {"rating": rating},
        options: Options(headers: headers),
      );

      final data = res.data["data"] ?? res.data;
      return ProductApiModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Failed to rate product");
    } catch (e) {
      throw Exception("Unexpected error while rating product");
    }
  }

  @override
  Future<ProductApiModel> toggleFavorite({required String productId}) async {
    try {
      final headers = await _authHeaders();

      final res = await _apiClient.post(
        ApiEndpoints.toggleFavorite(productId),
        options: Options(headers: headers),
      );

      final data = res.data["data"] ?? res.data;
      return ProductApiModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to update favorite",
      );
    } catch (e) {
      throw Exception("Unexpected error while updating favorite");
    }
  }

  @override
  Future<ProductApiModel> addComment({
    required String productId,
    required String comment,
  }) async {
    try {
      final headers = await _authHeaders();

      final res = await _apiClient.post(
        ApiEndpoints.addComment(productId),
        data: {"comment": comment},
        options: Options(headers: headers),
      );

      final data = res.data["data"] ?? res.data;
      return ProductApiModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Failed to add comment");
    } catch (e) {
      throw Exception("Unexpected error while adding comment");
    }
  }

  @override
  Future<List<ProductApiModel>> getMyFavorites() async {
    try {
      final headers = await _authHeaders();

      final res = await _apiClient.get(
        ApiEndpoints.myFavorites(),
        options: Options(headers: headers),
      );

      final list = (res.data["data"] ?? res.data) as List;
      return list
          .map((e) => ProductApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch favorites",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching favorites");
    }
  }

  @override
  Future<List<CommentApiModel>> getProductComments({
    required String productId,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.getProductComments(productId),
      );

      final list = (res.data["data"] ?? res.data) as List;
      return list
          .map((e) => CommentApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to fetch comments",
      );
    } catch (e) {
      throw Exception("Unexpected error while fetching comments");
    }
  }
}
