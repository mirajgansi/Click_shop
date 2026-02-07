import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final String cartItemId;
  const CartItemEntity({
    required this.productId,
    required this.quantity,
    required this.cartItemId,
  });

  @override
  List<Object?> get props => [productId, quantity, cartItemId];
}
