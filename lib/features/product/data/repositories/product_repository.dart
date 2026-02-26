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
  final remoteDatasource = ref.read(productRemoteDatabaseProvider);
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

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String categoryId,
  ) async {
    // helper: read local + convert to entities
    Future<Either<Failure, List<ProductEntity>>> getLocal() async {
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
        return getLocal();
      }
    } else {
      return getLocal();
    }
  }

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
        await _localDataSource.cacheAll(hiveModels);
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

  Future<Either<Failure, List<ProductEntity>>> _getCachedRecent() async {
    try {
      final models = await _localDataSource.getRecent();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _getCachedTrending() async {
    try {
      final models = await _localDataSource.getTrending();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _getCachedPopular() async {
    try {
      final models = await _localDataSource.getPopular();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _getCachedTopRated() async {
    try {
      final models = await _localDataSource.getTopRated();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRecentProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getRecent();

        // cache
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cacheRecent(hiveModels);

        // return
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        // remote failed -> cached
        return _getCachedRecent();
      }
    } else {
      return _getCachedRecent();
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getTrending();

        // cache
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cacheTrending(hiveModels);

        // return
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return _getCachedTrending();
      }
    } else {
      return _getCachedTrending();
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getPopularProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getPopular();

        // cache
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cachePopular(hiveModels);

        // return
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return _getCachedPopular();
      }
    } else {
      return _getCachedPopular();
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTopRatedProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getTopRated();

        // cache
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cacheTopRated(hiveModels);

        // return
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return _getCachedTopRated();
      }
    } else {
      return _getCachedTopRated();
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _getCachedOutOfStock() async {
    try {
      final models = await _localDataSource.getOutOfStock();
      final entities = ProductHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getOutOfStockProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getOutOfStock();

        // cache locally
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        await _localDataSource.cacheOutOfStock(hiveModels);

        // return entities
        final entities = ProductApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        // remote failed -> cached
        return _getCachedOutOfStock();
      }
    } else {
      return _getCachedOutOfStock();
    }
  }

  // -------------------- VIEW COUNT --------------------

  @override
  Future<Either<Failure, bool>> incrementViewCount(String productId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.incrementViewCount(productId);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // offline: don't fail product page just because views can't update
      return const Right(false);
    }
  }

  // -------------------- RATING / FAVORITE / COMMENTS --------------------

  @override
  Future<Either<Failure, ProductEntity>> rateProduct({
    required String productId,
    required double rating,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final updated = await _remoteDataSource.rateProduct(
          productId: productId,
          rating: rating,
        );

        // cache updated product
        await _localDataSource.upsertProduct(
          ProductHiveModel.fromApiModel(updated),
        );

        return Right(updated.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> toggleFavorite({
    required String productId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final updated = await _remoteDataSource.toggleFavorite(
          productId: productId,
        );

        // cache updated product
        await _localDataSource.upsertProduct(
          ProductHiveModel.fromApiModel(updated),
        );

        return Right(updated.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addComment({
    required String productId,
    required String comment,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final updated = await _remoteDataSource.addComment(
          productId: productId,
          comment: comment,
        );

        // cache updated product (includes updated comments usually)
        await _localDataSource.upsertProduct(
          ProductHiveModel.fromApiModel(updated),
        );

        // (optional) cache comments separately if you maintain a comments box
        // await _localDataSource.cacheProductComments(
        //   productId,
        //   updated.toEntity().comments,
        // );

        return Right(updated.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyFavorites() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getMyFavorites();
        final entities = ProductApiModel.toEntityList(models);

        // optional cache
        final hiveModels = ProductHiveModel.fromApiModelList(models);
        // you need to implement cacheMyFavorites(userId, items) OR ignore caching
        // await _localDataSource.cacheMyFavorites(userId, hiveModels);

        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline fallback: return cached favorites if you store by userId.
      // But repository doesn't have userId here, so either:
      // 1) change method to getMyFavorites(String userId)
      // 2) store "currentUserId" somewhere else
      return const Left(
        LocalDatabaseFailure(message: 'Offline favorites need userId cache'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductCommentEntity>>> getProductComments({
    required String productId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final commentModels = await _remoteDataSource.getProductComments(
          productId: productId,
        );

        final comments = commentModels
            .map(
              (c) => ProductCommentEntity(
                userId: c.userId,
                comment: c.comment,
                createdAt: c.createdAt,
                username: c.username,
              ),
            )
            .toList();

        return Right(comments);
      } catch (e) {
        try {
          final cached = await _localDataSource.getProductCommentsFromCache(
            productId,
          ); // List<String>

          final mapped = cached
              .map(
                (text) => ProductCommentEntity(
                  userId: '',
                  comment: text,
                  createdAt: null,
                  username: "",
                ),
              )
              .toList();

          return Right(mapped);
        } catch (e2) {
          return Left(ApiFailure(message: e.toString()));
        }
      }
    } else {
      try {
        final cached = await _localDataSource.getProductCommentsFromCache(
          productId,
        ); // List<String>

        final mapped = cached
            .map(
              (text) => ProductCommentEntity(
                userId: '',
                comment: text,
                createdAt: null,
                username: "",
              ),
            )
            .toList();

        return Right(mapped);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String productId) {
    // TODO: implement deleteProduct
    throw UnimplementedError();
  }
}
