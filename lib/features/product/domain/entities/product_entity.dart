import 'package:equatable/equatable.dart';

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

  final String? manufacturer;
  final DateTime? manufactureDate;
  final DateTime? expireDate;

  final int? quantity;

  final double? averageRating;
  final int? reviewCount;
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
    this.createdAt,
    this.updatedAt,
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
