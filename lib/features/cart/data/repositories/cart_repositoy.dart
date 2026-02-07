import 'package:click_shop/core/error/failures.dart';
import 'package:click_shop/core/services/connectivity/network_info.dart';
import 'package:click_shop/features/cart/data/datasources/cart_datasource.dart';
import 'package:click_shop/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:click_shop/features/cart/data/datasources/remote/cart_remote_datasource.dart';
import 'package:click_shop/features/cart/data/model/cart_hive_model.dart';
import 'package:click_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:click_shop/features/product/data/model/product_hive_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  final local = ref.read(cartLocalDatasourceProvider); // CartLocalDatasource
  final remote = ref.read(cartRemoteDatasourceProvider); // ICartRemoteDatabase
  final networkInfo = ref.read(NetworkInfoProvider);

  return ItemRepository(
    // or CartRepositoryImpl
    localDatasource: local,
    remoteDatasource: remote,
    networkInfo: networkInfo,
  );
});

class ItemRepository implements ICartRepository {
  final CartLocalDatasource _localDataSource;
  final ICartRemoteDatabase _remoteDataSource;
  final NetworkInfo _networkInfo;

  ItemRepository({
    required CartLocalDatasource localDatasource,
    required ICartRemoteDatabase remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDatasource,
       _remoteDataSource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createCartProduct(
    String productId,
    int quantity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remoteDataSource.createCartProduct(
          productId,
          quantity,
        );
        if (!ok) {
          return Left(
            LocalDatabaseFailure(message: "Failed to add product to cart"),
          );
        }
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      try {
        final ok = await _localDataSource.createCartProduct(
          productId,
          quantity,
        );
        if (!ok) {
          return Left(LocalDatabaseFailure(message: "Local cart add failed"));
        }
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCartProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _remoteDataSource.getCartProducts();

        // ProductApiModel -> ProductEntity
        final entities = apiModels.map((m) => m.toEntity()).toList();

        return Right(entities);
      } catch (e) {
        // fallback to local
        return _getCachedCartProducts(error: e);
      }
    } else {
      return _getCachedCartProducts();
    }
  }

  Future<Either<Failure, List<ProductEntity>>> _getCachedCartProducts({
    Object? error,
  }) async {
    try {
      final hiveModels = await _localDataSource.getCartProducts();

      // If your local datasource returns CartHiveModel, convert properly
      // If it returns ProductHiveModel, convert accordingly.
      //
      // ✅ Recommended: local returns List<CartHiveModel>
      if (hiveModels is List<CartHiveModel>) {
        final entities = hiveModels
            .map(
              (m) => ProductEntity(
                // You only have productId + quantity in cart hive;
                // to show product details you must fetch product by id.
                // For now we create a minimal entity (not ideal).
                id: m.productId,
                name: "",
                description: "",
                price: 0,
                inStock: 0,
                category: "",
                nutritionalInfo: "",
                image: "",
              ),
            )
            .toList();
        return Right(entities);
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: (error ?? e).toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCartItem(String cartItemId) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remoteDataSource.deleteCartItem(cartItemId);
        if (!ok) {
          return Left(
            LocalDatabaseFailure(message: "Failed to delete cart item"),
          );
        }
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      try {
        final ok = await _localDataSource.deleteCartItem(cartItemId);
        if (!ok) {
          return Left(
            LocalDatabaseFailure(message: "Local delete cart item failed"),
          );
        }
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> clearCart() async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _remoteDataSource.clearCart();
        if (!ok) {
          return Left(LocalDatabaseFailure(message: "Failed to clear cart"));
        }

        // optional: clear local too
        await _localDataSource.clearCart();

        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      try {
        final ok = await _localDataSource.clearCart();
        if (!ok) {
          return Left(LocalDatabaseFailure(message: "Local clear cart failed"));
        }
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> cancelMyOrder(String orderId) {
    // TODO: implement cancelMyOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> createOrderFromCart() {
    // TODO: implement createOrderFromCart
    throw UnimplementedError();
  }

  // @override
  // Future<Either<Failure, bool>> createOrderFromCart() async {
  //   // ordering should be online
  //   if (!await _networkInfo.isConnected) {
  //     return Left(
  //       LocalDatabaseFailure(message: "No internet connection to place order"),
  //     );
  //   }

  //   try {
  //     final ok = await _remoteDataSource.createOrderFromCart();
  //     if (!ok) {
  //       return Left(LocalDatabaseFailure(message: "Failed to create order"));
  //     }

  //     // optional: clear local cart after ordering
  //     await _localDataSource.clearCart();

  //     return const Right(true);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Failure, bool>> cancelMyOrder(String orderId) async {
  //   if (!await _networkInfo.isConnected) {
  //     return Left(
  //       LocalDatabaseFailure(message: "No internet connection to cancel order"),
  //     );
  //   }

  //   try {
  //     final ok = await _remoteDataSource.cancelMyOrder(orderId);
  //     if (!ok) {
  //       return Left(LocalDatabaseFailure(message: "Failed to cancel order"));
  //     }
  //     return const Right(true);
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }
}
