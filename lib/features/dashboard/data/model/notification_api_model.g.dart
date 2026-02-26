// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMeta _$NotificationMetaFromJson(Map<String, dynamic> json) =>
    NotificationMeta(
      orderId: json['orderId'] as String?,
      url: json['url'] as String?,
      productId: json['productId'] as String?,
    );

Map<String, dynamic> _$NotificationMetaToJson(NotificationMeta instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'url': instance.url,
      'productId': instance.productId,
    };

NotificationApiModel _$NotificationApiModelFromJson(
        Map<String, dynamic> json) =>
    NotificationApiModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['read'] as bool,
      createdAt: json['createdAt'] as String,
      type: json['type'] as String?,
      meta: json['data'] == null
          ? null
          : NotificationMeta.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationApiModelToJson(
        NotificationApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'read': instance.isRead,
      'type': instance.type,
      'createdAt': instance.createdAt,
      'data': instance.meta,
    };
