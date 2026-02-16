import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/order/data/model/order_item_hive_model.dart';
import 'package:click_shop/features/driver/data/model/shipping_address_hive_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';
import 'package:hive/hive.dart';

part 'order_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.orderTypeId)
class OrderHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final List<OrderItemHiveModel> items;

  @HiveField(3)
  final double subtotal;

  @HiveField(4)
  final double shippingFee;

  @HiveField(5)
  final double total;

  // store enums as strings (safe)
  @HiveField(6)
  final String status;

  @HiveField(7)
  final String paymentStatus;

  @HiveField(8)
  final ShippingAddressHiveModel? shippingAddress;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final String? driverId;

  @HiveField(11)
  final String? driverName;

  @HiveField(12)
  final DateTime? createdAt;

  @HiveField(13)
  final DateTime? updatedAt;

  OrderHiveModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.shippingAddress,
    this.notes,
    this.driverId,
    this.driverName,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderHiveModel.fromEntity(OrderEntity e) {
    return OrderHiveModel(
      id: e.id,
      userId: e.userId,
      items: e.items.map(OrderItemHiveModel.fromEntity).toList(),
      subtotal: e.subtotal,
      shippingFee: e.shippingFee,
      total: e.total,
      status: e.status.name,
      paymentStatus: e.paymentStatus.name,
      shippingAddress: e.shippingAddress == null
          ? null
          : ShippingAddressHiveModel.fromEntity(e.shippingAddress!),
      notes: e.notes,
      driverId: e.driverId,
      driverName: e.driverName,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      status: OrderStatusX.fromString(status),
      paymentStatus: PaymentStatusX.fromString(paymentStatus),
      shippingAddress: shippingAddress?.toEntity(),
      notes: notes,
      driverId: driverId,
      driverName: driverName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
