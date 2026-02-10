import 'package:click_shop/features/order/domain/entities/order_item_entities.dart';
import 'package:click_shop/features/order/domain/entities/shipping_address.dart';
import 'package:equatable/equatable.dart';
import 'order_status.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;

  final double subtotal;
  final double shippingFee;
  final double total;

  final OrderStatus status;
  final PaymentStatus paymentStatus;

  final ShippingAddressEntity? shippingAddress;
  final String? notes;

  final String? driverId;
  final String? driverName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
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

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    subtotal,
    shippingFee,
    total,
    status,
    paymentStatus,
    shippingAddress,
    notes,
    driverId,
    driverName,
    createdAt,
    updatedAt,
  ];

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',

      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),

      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),

      status: OrderStatusX.fromString(json['status']),
      paymentStatus: PaymentStatusX.fromString(json['paymentStatus']),

      driverId: json['driverId'],
      driverName: json['driverName'],

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
