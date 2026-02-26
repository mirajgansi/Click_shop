import 'package:equatable/equatable.dart';

class ProductCommentEntity extends Equatable {
  final String userId;
  final String comment;
  final String username;
  final DateTime? createdAt;

  const ProductCommentEntity({
    required this.userId,
    required this.username,

    required this.comment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [userId, username, comment, createdAt];
}

class ProductEntity extends Equatable {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int inStock;
  final String category;
  final String nutritionalInfo;
  final String image;
  final List<String> images;
  final double? myRating;
  final String? manufacturer;
  final DateTime? manufactureDate;
  final DateTime? expireDate;

  final int? quantity;

  final double? averageRating;
  final int? reviewCount;

  final List<String> favorites;
  final List<ProductCommentEntity> comments;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductEntity({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.inStock,
    required this.category,
    required this.nutritionalInfo,
    required this.image,
    this.images = const [],
    this.manufacturer,
    this.manufactureDate,
    this.expireDate,
    this.quantity,

    this.averageRating,
    this.reviewCount,

    this.favorites = const [],
    this.comments = const [],

    this.createdAt,
    this.updatedAt,
    this.myRating,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? inStock,
    String? category,
    String? nutritionalInfo,
    String? image,
    List<String>? images,
    String? manufacturer,
    DateTime? manufactureDate,
    DateTime? expireDate,
    int? quantity,

    double? averageRating,
    int? reviewCount,
    List<String>? favorites,
    List<ProductCommentEntity>? comments,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      inStock: inStock ?? this.inStock,
      category: category ?? this.category,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      image: image ?? this.image,
      images: images ?? this.images,
      manufacturer: manufacturer ?? this.manufacturer,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expireDate: expireDate ?? this.expireDate,
      quantity: quantity ?? this.quantity,

      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      favorites: favorites ?? this.favorites,
      comments: comments ?? this.comments,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    inStock,
    category,
    nutritionalInfo,
    image,
    images,
    manufacturer,
    manufactureDate,
    expireDate,
    quantity,
    averageRating,
    reviewCount,
    favorites,
    comments,
    createdAt,
    updatedAt,
  ];
}

class CategoryEntity {
  final String id;
  final String name;
  final String slug;
  final String? image;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
  });
}
