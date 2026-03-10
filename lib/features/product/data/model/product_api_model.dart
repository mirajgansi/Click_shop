import 'package:json_annotation/json_annotation.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';

part 'product_api_model.g.dart';

@JsonSerializable()
class RatingApiModel {
  @JsonKey(fromJson: _userIdFromJson)
  final String userId;

  @JsonKey(fromJson: _toDouble)
  final double rating;

  RatingApiModel({required this.userId, required this.rating});

  factory RatingApiModel.fromJson(Map<String, dynamic> json) =>
      _$RatingApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingApiModelToJson(this);

  static String _userIdFromJson(dynamic v) {
    if (v == null) return '';

    if (v is String) return v;

    if (v is Map<String, dynamic>) {
      return (v['_id'] ?? '').toString();
    }

    return v.toString();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

@JsonSerializable()
class CommentApiModel {
  @JsonKey(fromJson: _userIdFromJson)
  final String userId;

  @JsonKey(readValue: _readUsername, defaultValue: '')
  final String username;

  final String comment;
  final DateTime? createdAt;

  CommentApiModel({
    required this.userId,
    required this.username,
    required this.comment,
    this.createdAt,
  });

  factory CommentApiModel.fromJson(Map<String, dynamic> json) =>
      _$CommentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentApiModelToJson(this);

  static String _userIdFromJson(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is Map) return (v['_id'] ?? '').toString();
    return v.toString();
  }

  static Object? _readUsername(Map json, String key) {
    final u = json['userId'];
    if (u is Map) return u['username'] ?? '';
    return json['username'] ?? '';
  }
}

@JsonSerializable()
class ProductApiModel {
  @JsonKey(name: '_id')
  final String? id;

  final String name;
  final String description;

  @JsonKey(name: 'nutritionalInfo')
  final String nutritionalInfo;

  final String category;

  @JsonKey(fromJson: _toDouble)
  final double price;

  @JsonKey(defaultValue: 0)
  final int inStock;

  final String image;

  @JsonKey(defaultValue: <String>[])
  final List<String> images;

  final String? manufacturer;

  final DateTime? manufactureDate;
  final DateTime? expireDate;

  @JsonKey(defaultValue: 1)
  final int quantity;

  @JsonKey(defaultValue: 0)
  final double averageRating;

  @JsonKey(defaultValue: 0)
  final int reviewCount;

  @JsonKey(defaultValue: <String>[])
  final List<String> favorites;

  @JsonKey(defaultValue: <CommentApiModel>[])
  final List<CommentApiModel> comments;

  @JsonKey(defaultValue: <RatingApiModel>[])
  final List<RatingApiModel> ratings;

  ProductApiModel({
    this.id,
    required this.name,
    required this.description,
    required this.nutritionalInfo,
    required this.category,
    required this.price,
    this.inStock = 0,
    required this.image,
    this.images = const <String>[],
    this.manufacturer,
    this.manufactureDate,
    this.expireDate,
    this.quantity = 1,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.favorites = const <String>[],
    this.comments = const <CommentApiModel>[],
    this.ratings = const <RatingApiModel>[],
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductApiModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      nutritionalInfo: nutritionalInfo,
      category: category,
      price: price,
      inStock: inStock,
      image: image,
      images: images,
      manufacturer: manufacturer,
      manufactureDate: manufactureDate,
      expireDate: expireDate,
      quantity: quantity,
      averageRating: averageRating,
      reviewCount: reviewCount,
      favorites: favorites,
      comments: comments
          .map(
            (c) => ProductCommentEntity(
              userId: c.userId,
              comment: c.comment,
              createdAt: c.createdAt,
              username: c.username,
            ),
          )
          .toList(),
    );
  }

  factory ProductApiModel.fromEntity(ProductEntity entity) {
    return ProductApiModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      nutritionalInfo: entity.nutritionalInfo,
      category: entity.category,
      price: entity.price,
      inStock: entity.inStock,
      image: entity.image,
      images: entity.images,
      manufacturer: entity.manufacturer,
      manufactureDate: entity.manufactureDate,
      expireDate: entity.expireDate,
      quantity: entity.quantity ?? 1,
      averageRating: entity.averageRating ?? 0,
      reviewCount: entity.reviewCount ?? 0,
      favorites: entity.favorites,
      comments: entity.comments
          .map(
            (c) => CommentApiModel(
              userId: c.userId,
              comment: c.comment,
              createdAt: c.createdAt,
              username: c.username,
            ),
          )
          .toList(),
      // ratings usually not needed to send from app -> keep empty
      ratings: const [],
    );
  }

  static List<ProductEntity> toEntityList(List<ProductApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
