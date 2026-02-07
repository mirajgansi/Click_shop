import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/cart/domain/entities/cart_entity.dart';
import 'package:click_shop/features/cart/data/model/cart_api_model.dart';
import 'package:hive/hive.dart';

part 'cart_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.cartTypeId) // ✅ use a cart type id
class CartHiveModel extends HiveObject {
  // cart item id (optional but useful for delete)
  @HiveField(0)
  final String cartItemId;

  // product id
  @HiveField(1)
  final String productId;

  // quantity
  @HiveField(2)
  final int quantity;

  CartHiveModel({
    required this.cartItemId,
    required this.productId,
    required this.quantity,
  });

  /// HiveModel -> Entity
  CartItemEntity toEntity() {
    return CartItemEntity(
      cartItemId: cartItemId,
      productId: productId,
      quantity: quantity,
    );
  }

  /// Entity -> HiveModel
  factory CartHiveModel.fromEntity(CartItemEntity entity) {
    return CartHiveModel(
      cartItemId: entity.cartItemId,
      productId: entity.productId,
      quantity: entity.quantity,
    );
  }

  /// ApiModel -> HiveModel
  factory CartHiveModel.fromApiModel(CartApiModel apiModel) {
    return CartHiveModel(
      cartItemId: apiModel.cartItemId ?? '',
      productId: apiModel.productId ?? '',
      quantity: apiModel.quantity,
    );
  }

  /// list helpers
  static List<CartItemEntity> toEntityList(List<CartHiveModel> hiveModels) {
    return hiveModels.map((m) => m.toEntity()).toList();
  }

  static List<CartHiveModel> fromApiModelList(List<CartApiModel> apiModels) {
    return apiModels.map(CartHiveModel.fromApiModel).toList();
  }
}
