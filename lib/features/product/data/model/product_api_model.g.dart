// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingApiModel _$RatingApiModelFromJson(Map<String, dynamic> json) =>
    RatingApiModel(
      userId: RatingApiModel._userIdFromJson(json['userId']),
      rating: RatingApiModel._toDouble(json['rating']),
    );

Map<String, dynamic> _$RatingApiModelToJson(RatingApiModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'rating': instance.rating,
    };

CommentApiModel _$CommentApiModelFromJson(Map<String, dynamic> json) =>
    CommentApiModel(
      userId: CommentApiModel._userIdFromJson(json['userId']),
      username:
          CommentApiModel._readUsername(json, 'username') as String? ?? '',
      comment: json['comment'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentApiModelToJson(CommentApiModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'comment': instance.comment,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ProductApiModel _$ProductApiModelFromJson(Map<String, dynamic> json) =>
    ProductApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      nutritionalInfo: json['nutritionalInfo'] as String,
      category: json['category'] as String,
      price: ProductApiModel._toDouble(json['price']),
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
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentApiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ratings: (json['ratings'] as List<dynamic>?)
              ?.map((e) => RatingApiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'favorites': instance.favorites,
      'comments': instance.comments,
      'ratings': instance.ratings,
    };
