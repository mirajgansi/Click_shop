import 'package:click_shop/features/cart/domain/entities/cart_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_api_model.g.dart';

String? _extractProductId(dynamic value) {
  if (value == null) return null;
  if (value is Map) return value['_id'] as String?;
  return value as String?;
}

@JsonSerializable()
class CartApiModel {
  /// cart item id
  @JsonKey(name: '_id')
  final String? cartItemId;

  /// product id (can be object or string)
  @JsonKey(name: 'product', fromJson: _extractProductId)
  final String? productId;

  final int quantity;

  CartApiModel({this.cartItemId, this.productId, required this.quantity});

  factory CartApiModel.fromJson(Map<String, dynamic> json) =>
      _$CartApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartApiModelToJson(this);

  /// API → Domain
  CartItemEntity toEntity() {
    return CartItemEntity(
      cartItemId: cartItemId ?? '',
      productId: productId ?? '',
      quantity: quantity,
    );
  }

  /// Domain → API (for POST /api/cart)
  factory CartApiModel.fromEntity(CartItemEntity entity) {
    return CartApiModel(productId: entity.productId, quantity: entity.quantity);
  }

  static List<CartItemEntity> toEntityList(List<CartApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
