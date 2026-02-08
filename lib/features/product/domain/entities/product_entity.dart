import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int inStock;
  final String category;
  final String nutritionalInfo;
  final String image; // main image
  final List<String> images; // extra images (optional)
  final String? manufacturer;
  final DateTime? manufactureDate;
  final DateTime? expireDate;
  final int? quantity;

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
  ];
}
