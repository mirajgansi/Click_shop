import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:hive/hive.dart';

part 'order_item_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.orderItemTypeId)
class OrderItemHiveModel {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String? image;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double lineTotal;

  const OrderItemHiveModel({
    required this.productId,
    required this.name,
    required this.price,
    this.image,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemHiveModel.fromEntity(OrderItemEntity e) {
    return OrderItemHiveModel(
      productId: e.productId,
      name: e.name,
      price: e.price,
      image: e.image,
      quantity: e.quantity,
      lineTotal: e.lineTotal,
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId,
      name: name,
      price: price,
      image: image,
      quantity: quantity,
      lineTotal: lineTotal,
    );
  }
}
