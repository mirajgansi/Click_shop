import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/product/data/datasources/local/product_local_database.dart';
import 'package:click_shop/features/product/data/datasources/product_database.dart';
import 'package:click_shop/features/product/data/datasources/remote/product_remote_database.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final localDatasource = ref.read(ProductLocalDatasourceProvider);
  final remoteDatasource = ref.read(ProductRemoteDatabaseProvider);
  final networkInfo = ref.read(NetworkInfoProvider);

  return ProductRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class ProductRepository implements IProductRepository {
  final ProdcutLocalDatabase _localDataSource;
  final IProductRemoteDatabase _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProductRepository({
    required ProdcutLocalDatabase localDatasource,
    required IProductRemoteDatabase remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDatasource,
       _remoteDataSource = remoteDatasource,
       _networkInfo = networkInfo;

  // -------------------- PRODUCTS --------------------

  Future<Either<Failure, List<ProductEntity>>> _getCachedItems() async {
    try {
      final models = await _localDataSource.getAllproduct();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// ✅ GET PRODUCT BY ID
  @override
  Future<Either<Failure, ProductEntity>> getProductbyId(
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getProductbyId(productId);
        return Right(model!.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _localDataSource.getProductbyId(productId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(LocalDatabaseFailure(message: 'Item not found'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  /// ✅ GET PRODUCTS BY CATEGORY
  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  ) async {
    // helper: read local + convert to entities
    Future<Either<Failure, List<ProductEntity>>> _getLocal() async {
      try {
        final hiveModels = await _localDataSource.getProductsByCategory(
          categoryId,
        );
        // hiveModels: List<ProductHiveModel>
        final entities = ProductHiveModel.toEntityList(hiveModels);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }

    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDataSource.getProductsByCategory(
          categoryId,
        );
        // apiModels: List<ProductApiModel>
        final entities = ProductApiModel.toEntityList(apiModels);
        return Right(entities);
      } catch (e) {
        return _getLocal();
      }
    } else {
      return _getLocal();
    }
  }

  // @override
  // Future<Either<Failure, List<ProductEntity>>> searchProducts(
  //   String query,
  // ) async {
  //   try {
  //     final results = await _localDataSource.searchProducts(query);
  //     return Right(results);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }

  // -------------------- CART --------------------

  //  GET CART PRODUCTS
  // @override
  // Future<Either<Failure, List<ProductEntity>>> getCartProducts() async {
  //   if (await _networkInfo.isConnected) {
  //     try {
  //       final products = await _remoteDataSource.getCartProducts();
  //       return Right(products);
  //     } catch (e) {
  //       // fallback local cart
  //       try {
  //         final products = await _localDataSource.getCartProducts();
  //         return Right(products);
  //       } catch (err) {
  //         return Left(LocalDatabaseFailure(message: err.toString()));
  //       }
  //     }
  //   } else {
  //     try {
  //       final products = await _localDataSource.getCartProducts();
  //       return Right(products);
  //     } catch (e) {
  //       return Left(LocalDatabaseFailure(message: e.toString()));
  //     }
  //   }
  // }

  @override
  Future<Either<Failure, bool>> createProduct(ProductEntity productEntity) {
    // TODO: implement createProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> delteProduct(String productId) {
    // TODO: implement delteProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateProduct(ProductEntity productEntity) {
    // TODO: implement updateProduct
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int page = 1,
    int size = 20,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllproduct(
          page: page,
          size: size,
          search: query,
        );
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return _getCachedItems();
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllproduct() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllproduct();
        // Cache the data locally for offline access
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cacheAllProducts(hiveModels);
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        // API failed, try to return cached data
        return _getCachedItems();
      }
    } else {
      return _getCachedItems();
    }
  }
}
  // -------------------- ADMIN METHODS (skip / keep as not implemented) --------------------
  // If your IProductRepository still contains these, either remove them or keep as stubs.

  // @override
  // Future<Either<Failure, bool>> createProduct(
  //   ProductEntity productEntity,
  // ) async {
  //   // user app usually doesn't create products
  //   try {
  //     final ok = await _localDataSource.createProduct(productEntity);
  //     return Right(ok);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, bool>> updateProduct(
  //   ProductEntity productEntity,
  // ) async {
  //   try {
  //     final ok = await _localDataSource.updateProduct(productEntity);
  //     return Right(ok);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, bool>> delteProduct(String productId) async {
  //   try {
  //     final ok = await _localDataSource.deleteProduct(productId);
  //     return Right(ok);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }
