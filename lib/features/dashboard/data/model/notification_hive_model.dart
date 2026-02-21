import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:hive/hive.dart';

part 'notification_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.notificationTypeId)
class NotificationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final bool isRead;

  @HiveField(4)
  final String createdAt;

  @HiveField(5)
  final String? type;

  @HiveField(6)
  final String? orderId;
  @HiveField(7)
  final String? productId;

  NotificationHiveModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.orderId,
    this.productId,
  });
  NotificationHiveModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    String? createdAt,
    String? type,
    String? orderId,
    String? productId,
  }) {
    return NotificationHiveModel(
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

  factory NotificationHiveModel.fromEntity(NotificationEntity entity) {
    return NotificationHiveModel(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      type: entity.type,
      orderId: entity.orderId,
      productId: entity.productId,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      type: type,
      orderId: orderId,
      productId: productId,
    );
  }
}
