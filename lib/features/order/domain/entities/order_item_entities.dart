import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String name;
  final double price;
  final String? image;
  final int quantity;
  final double lineTotal;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    this.image,
    required this.quantity,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    price,
    image,
    quantity,
    lineTotal,
  ];
}
