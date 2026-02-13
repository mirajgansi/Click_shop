import 'package:json_annotation/json_annotation.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';

part 'product_api_model.g.dart';

@JsonSerializable()
class ProductApiModel {
  @JsonKey(name: '_id')
  final String? id;

  final String name;
  final String description;

  // backend: nutritionalInfo
  @JsonKey(name: 'nutritionalInfo')
  final String nutritionalInfo;

  final String category;

  // backend can send int/double/string sometimes -> handle safely
  @JsonKey()
  final double price;

  @JsonKey(defaultValue: 0)
  final int inStock;

  // backend: image
  final String image;

  // backend: images (optional)
  @JsonKey(defaultValue: <String>[])
  final List<String> images;

  // optional user-visible fields
  final String? manufacturer;

  @JsonKey()
  final DateTime? manufactureDate;

  @JsonKey()
  final DateTime? expireDate;

  @JsonKey(defaultValue: 1)
  final int quantity;

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
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProductApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductApiModelToJson(this);

  // -------------------- Mapping --------------------

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
    );
  }

  static List<ProductEntity> toEntityList(List<ProductApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

// -------------------- Helpers --------------------

// double _toDouble(dynamic v) {
//   if (v == null) return 0.0;
//   if (v is num) return v.toDouble();
//   return double.tryParse(v.toString()) ?? 0.0;
// }

// int _toInt(dynamic v) {
//   if (v == null) return 0;
//   if (v is int) return v;
//   if (v is num) return v.toInt();
//   return int.tryParse(v.toString()) ?? 0;
// }

// DateTime? _toDateTimeNullable(dynamic v) {
//   if (v == null) return null;
//   if (v is DateTime) return v;
//   return DateTime.tryParse(v.toString());
// }

// dynamic _dateTimeToJsonNullable(DateTime? v) => v?.toIso8601String();
