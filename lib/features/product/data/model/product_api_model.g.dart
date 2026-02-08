// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductApiModel _$ProductApiModelFromJson(Map<String, dynamic> json) =>
    ProductApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      nutritionalInfo: json['nutritionalInfo'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      inStock: (json['inStock'] as num?)?.toInt() ?? 0,
      image: json['image'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      manufacturer: json['manufacturer'] as String?,
      manufactureDate: json['manufactureDate'] == null
          ? null
          : DateTime.parse(json['manufactureDate'] as String),
      expireDate: json['expireDate'] == null
          ? null
          : DateTime.parse(json['expireDate'] as String),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ProductApiModelToJson(ProductApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'nutritionalInfo': instance.nutritionalInfo,
      'category': instance.category,
      'price': instance.price,
      'inStock': instance.inStock,
      'image': instance.image,
      'images': instance.images,
      'manufacturer': instance.manufacturer,
      'manufactureDate': instance.manufactureDate?.toIso8601String(),
      'expireDate': instance.expireDate?.toIso8601String(),
      'quantity': instance.quantity,
    };
