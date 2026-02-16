import 'package:click_shop/features/order/data/model/order_item_api_model.dart';
import 'package:click_shop/features/order/data/model/shipping_address_api_model.dart';
import 'package:click_shop/features/order/domain/entities/order_entities.dart';
import 'package:click_shop/features/order/domain/entities/order_status.dart';

class OrderApiModel {
  final String? id;
  final String? userId;
  final List<OrderItemApiModel> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final String paymentStatus;
  final ShippingAddressApiModel? shippingAddress;
  final String? notes;
  final String? driverId;
  final String? driverName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderApiModel({
    this.id,
    this.userId,
    required this.items,
    this.subtotal = 0,
    this.shippingFee = 0,
    this.total = 0,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.shippingAddress,
    this.notes,
    this.driverId,
    this.driverName,
    this.createdAt,
    this.updatedAt,
  });

  /// ---------- HELPERS ----------
  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map) return value['_id'] as String?;
    return value as String?;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  /// ---------- FROM JSON ----------
  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: json['_id'] as String?,
      userId: _extractId(json['userId']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: _toDouble(json['subtotal']),
      shippingFee: _toDouble(json['shippingFee']),
      total: _toDouble(json['total']),
      status: (json['status'] ?? 'pending').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'unpaid').toString(),
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressApiModel.fromJson(json['shippingAddress'])
          : null,
      notes: json['notes'] as String?,
      driverId: _extractId(json['driverId']),
      driverName: json['driverName'] as String?,
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'status': status,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress?.toJson(),
      'notes': notes,
      'driverId': driverId,
      'driverName': driverName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// ---------- ENTITY MAPPING ----------
  OrderEntity toEntity() {
    return OrderEntity(
      id: id ?? "",
      userId: userId ?? "",
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      status: _parseOrderStatus(status),
      paymentStatus: _parsePaymentStatus(paymentStatus),
      shippingAddress: shippingAddress?.toEntity(),
      notes: notes,
      driverId: driverId,
      driverName: driverName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory OrderApiModel.fromEntity(OrderEntity entity) {
    return OrderApiModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items.map(OrderItemApiModel.fromEntity).toList(),
      subtotal: entity.subtotal,
      shippingFee: entity.shippingFee,
      total: entity.total,
      status: entity.status.name,
      paymentStatus: entity.paymentStatus.name,
      shippingAddress: entity.shippingAddress != null
          ? ShippingAddressApiModel.fromEntity(entity.shippingAddress!)
          : null,
      notes: entity.notes,
      driverId: entity.driverId,
      driverName: entity.driverName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<OrderEntity> toEntityList(List<OrderApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  /// ---------- STATUS PARSING ----------
  static OrderStatus _parseOrderStatus(String value) {
    switch (value) {
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String value) {
    switch (value) {
      case 'paid':
        return PaymentStatus.paid;
      default:
        return PaymentStatus.unpaid;
    }
  }
}
