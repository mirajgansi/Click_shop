import 'package:click_shop/features/dashboard/data/model/notification_hive_model.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_api_model.g.dart';

@JsonSerializable()
class NotificationMeta {
  final String? orderId;
  final String? url;
  final String? productId;

  NotificationMeta({this.orderId, this.url, this.productId});

  factory NotificationMeta.fromJson(Map<String, dynamic> json) =>
      _$NotificationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMetaToJson(this);
}

@JsonSerializable()
class NotificationApiModel {
  @JsonKey(name: '_id')
  final String id;

  final String title;
  final String message;

  @JsonKey(name: 'read')
  final bool isRead;

  final String? type;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'data')
  final NotificationMeta? meta;

  NotificationApiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.meta,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationApiModelToJson(this);

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      type: type,
      orderId: meta?.orderId,
      productId: meta?.productId,
    );
  }

  NotificationHiveModel toHiveModel() {
    return NotificationHiveModel(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      type: type,
      orderId: meta?.orderId,
      productId: meta?.productId,
    );
  }
}
