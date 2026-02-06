import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.productTypeId)
class ProductHiveModel extends HiveObject {
  // Backend: _id
  @HiveField(0)
  final String? id;

  // Backend: name
  @HiveField(1)
  final String name;

  // Backend: nutritionalInfo
  @HiveField(2)
  final String nutritionalInfo;

  // Backend: category
  @HiveField(3)
  final String category;

  // Backend: description
  @HiveField(4)
  final String description;

  // Backend: price (number)
  @HiveField(5)
  final double price;

  // Backend: image (main image)
  @HiveField(6)
  final String image;

  // Backend: inStock
  @HiveField(7)
  final int inStock;

  // Backend: images (optional)
  @HiveField(8)
  final List<String> images;

  // Optional user-visible fields
  @HiveField(9)
  final String? manufacturer;

  // Store dates as ISO strings for Hive safety
  @HiveField(10)
  final String? manufactureDateIso;

  @HiveField(11)
  final String? expireDateIso;

  ProductHiveModel({
    this.id,
    required this.name,
    required this.nutritionalInfo,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    required this.inStock,
    this.images = const [],
    this.manufacturer,
    this.manufactureDateIso,
    this.expireDateIso,
  });

  /// JSON -> HiveModel (API response)
  factory ProductHiveModel.fromJson(Map<String, dynamic> json) {
    return ProductHiveModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: (json['name'] ?? '').toString(),
      nutritionalInfo: (json['nutritionalInfo'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      inStock: (json['inStock'] is num)
          ? (json['inStock'] as num).toInt()
          : int.tryParse(json['inStock']?.toString() ?? '0') ?? 0,
      image: (json['image'] ?? '').toString(),
      images: (json['images'] is List)
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : const [],
      manufacturer: json['manufacturer']?.toString(),
      manufactureDateIso: json['manufactureDate']?.toString(),
      expireDateIso: json['expireDate']?.toString(),
    );
  }

  /// HiveModel -> Entity
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      nutritionalInfo: nutritionalInfo,
      category: category,
      description: description,
      price: price,
      image: image,
      inStock: inStock,
      images: images,
      manufacturer: manufacturer,
      manufactureDate: manufactureDateIso == null
          ? null
          : DateTime.tryParse(manufactureDateIso!),
      expireDate: expireDateIso == null
          ? null
          : DateTime.tryParse(expireDateIso!),
    );
  }

  /// Entity -> HiveModel
  factory ProductHiveModel.fromEntity(ProductEntity e) {
    return ProductHiveModel(
      id: e.id,
      name: e.name,
      nutritionalInfo: e.nutritionalInfo,
      category: e.category,
      description: e.description,
      price: e.price,
      image: e.image,
      inStock: e.inStock,
      images: e.images,
      manufacturer: e.manufacturer,
      manufactureDateIso: e.manufactureDate?.toIso8601String(),
      expireDateIso: e.expireDate?.toIso8601String(),
    );
  }

  // To entity list
  static List<ProductEntity> toEntityList(List<ProductHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }
}
