import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final String? type;
  final String? orderId;
  final String? productId;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.orderId,
    this.productId,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    String? createdAt,
    String? type,
    String? orderId,
    String? productId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    isRead,
    createdAt,
    type,
    orderId,
    productId,
  ];
}
