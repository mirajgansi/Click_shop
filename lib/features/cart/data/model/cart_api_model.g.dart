// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartApiModel _$CartApiModelFromJson(Map<String, dynamic> json) => CartApiModel(
      cartItemId: json['_id'] as String?,
      productId: _extractProductId(json['product']),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CartApiModelToJson(CartApiModel instance) =>
    <String, dynamic>{
      '_id': instance.cartItemId,
      'product': instance.productId,
      'quantity': instance.quantity,
    };
