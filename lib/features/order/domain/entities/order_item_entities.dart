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
  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productId: json['product'] ?? json['productId'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      quantity: (json['quantity'] ?? 0) as int,
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
    );
  }

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
