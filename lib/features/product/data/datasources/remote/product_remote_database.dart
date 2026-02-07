import 'package:click_shop/core/config/api_client.dart';
import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/services/storage/token_service.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ProductRemoteDatabaseProvider = Provider<IProductRemoteDatabase>((ref) {
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

  @override
  Future<List<ProductApiModel>> getAllproduct() async {
    final res = await _apiClient.get(ApiEndpoints.products);

    final data = (res.data['data']?['products'] as List?) ?? [];

    return data.map((json) => ProductApiModel.fromJson(json)).toList();
  }

  @override
  Future<ProductApiModel> getProductbyId(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getProductById(productId),
    );
    return ProductApiModel.fromJson(response.data['data']);
  }

  // @override
  // Future<List<ProductApiModel>> getProductsByCategory(String categoryId) async {
  //   // If your backend has route: /products/category/:category
  //   // use that. Otherwise keep queryParameters.
  //   final res = await _apiClient.get(
  //     ApiEndpoints.getByCategory(categoryId),
  //     // OR:
  //     // ApiEndpoints.Products,
  //     // queryParameters: {'category': categoryId},
  //   );

  //   final data = res.data['data'];
  //   if (data is! List) return [];

  //   final models = data
  //       .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
  //       .toList();

  //   return ProductApiModel.fromJson(response.data['data']);
  // }

  @override
  Future<List<ProductApiModel>> getProductsByCategory(String categoryId) {
    // TODO: implement getProductsByCategory
    throw UnimplementedError();
  }
}
