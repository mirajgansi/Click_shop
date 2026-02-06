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
  });

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
  ];
}
