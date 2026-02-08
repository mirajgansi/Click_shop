import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';

class OrderItemApiModel {
  final String? productId;
  final String name;
  final double price;
  final String? image;
  final int quantity;
  final double lineTotal;

  const OrderItemApiModel({
    this.productId,
    required this.name,
    required this.price,
    this.image,
    this.quantity = 1,
    required this.lineTotal,
  });

  /// Helper to extract ID from nested object or string
  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['_id'] as String?;
    return value as String?;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    // if backend sends string numbers "12.5"
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  /// ---------- FROM JSON ----------
  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) {
    return OrderItemApiModel(
      productId: _extractId(json['productId']),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      image: json['image'] as String?,
      quantity: _toInt(json['quantity'], fallback: 1),
      lineTotal: _toDouble(json['lineTotal']),
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }

  /// ---------- ENTITY MAPPING ----------
  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId ?? "",
      name: name,
      price: price,
      image: image,
      quantity: quantity,
      lineTotal: lineTotal,
    );
  }

  factory OrderItemApiModel.fromEntity(OrderItemEntity entity) {
    return OrderItemApiModel(
      productId: entity.productId,
      name: entity.name,
      price: entity.price,
      image: entity.image,
      quantity: entity.quantity,
      lineTotal: entity.lineTotal,
    );
  }

  static List<OrderItemEntity> toEntityList(List<OrderItemApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
