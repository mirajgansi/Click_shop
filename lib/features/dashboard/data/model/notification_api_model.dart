import 'package:click_shop/features/dashboard/data/model/notification_hive_model.dart';
import 'package:click_shop/features/dashboard/domain/entities/notificaton_entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_api_model.g.dart';

@JsonSerializable()
class NotificationApiModel {
  @JsonKey(name: '_id')
  final String id;

  final String title;
  final String message;
  final bool isRead;
  final String? type;

  /// If backend sends ISO string, keep String OR DateTime.
  /// Here we use String to match your Hive/Entity `createdAt` String.
  final String createdAt;

  NotificationApiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  Map<String, dynamic> toJson() => _$NotificationApiModelToJson(this);

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationApiModelFromJson(json);

  // ✅ API -> Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      type: type,
    );
  }

  // ✅ Entity -> API
  factory NotificationApiModel.fromEntity(NotificationEntity entity) {
    return NotificationApiModel(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      type: entity.type,
    );
  }

  // ✅ API -> Hive
  NotificationHiveModel toHiveModel() {
    return NotificationHiveModel(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      type: type,
    );
  }

  // ✅ List<API> -> List<Entity>
  static List<NotificationEntity> toEntityList(
    List<NotificationApiModel> models,
  ) {
    return models.map((m) => m.toEntity()).toList();
  }
}
