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
  // @override
  // Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
  //   String categoryId,
  // ) async {
  //   if (await _networkInfo.isConnected) {
  //     try {
  //       final products = await _remoteDataSource.getProductsByCategory(
  //         categoryId,
  //       );
  //       return Right(products);
  //     } catch (e) {
  //       return Left(ApiFailure(message: e.toString()));
  //     }
  //   } else {
  //     try {
  //       final products = await _localDataSource.getProductsByCategory(
  //         categoryId,
  //       );
  //       return Right(products);
  //     } catch (e) {
  //       return Left(LocalDatabaseFailure(message: e.toString()));
  //     }
  //   }
  // }

  /// ✅ SEARCH (local filtering)
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

  /// ✅ ADD TO CART
  @override
  Future<Either<Failure, bool>> createCartProduct(String productId) async {
    // If your backend has cart API, use remote when online, else local
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remoteDataSource.createCartProduct(productId);
        return Right(ok);
      } catch (e) {
        // if remote fails, fallback to local cart
        try {
          final ok = await _localDataSource.createCartProduct(productId);
          return Right(ok);
        } catch (err) {
          return Left(LocalDatabaseFailure(message: err.toString()));
        }
      }
    } else {
      try {
        final ok = await _localDataSource.createCartProduct(productId);
        return Right(ok);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // /// ✅ GET CART PRODUCTS
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
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query) {
    // TODO: implement searchProducts
    throw UnimplementedError();
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

  @override
  Future<Either<Failure, List<ProductEntity>>> getCartProducts() {
    // TODO: implement getCartProducts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  ) {
    // TODO: implement getProductsByCategory
    throw UnimplementedError();
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
