import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/product/data/model/product_api_model.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.productTypeId)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nutritionalInfo;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final String image;

  @HiveField(7)
  final int inStock;

  @HiveField(8)
  final List<String> images;

  @HiveField(9)
  final String? manufacturer;

  @HiveField(10)
  final String? manufactureDateIso;

  @HiveField(11)
  final String? expireDateIso;

  @HiveField(12)
  final int? quantity;

  @HiveField(13)
  final double? averageRating;

  @HiveField(14)
  final int? reviewCount;

  @HiveField(15)
  final List<String> favorites;

  @HiveField(16)
  final List<String> comments;
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
    this.quantity,

    this.averageRating,
    this.reviewCount,
    this.favorites = const [],
    this.comments = const [],
  });

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
      quantity: quantity,

      averageRating: averageRating,
      reviewCount: reviewCount,
      favorites: favorites,

      // offline comments -> userId unknown
      comments: comments
          .map(
            (text) => ProductCommentEntity(
              userId: "offline",
              comment: text,
              username: '',
            ),
          )
          .toList(),
    );
  }

  /// Entity -> HiveModel
  factory ProductHiveModel.fromEntity(ProductEntity entity) {
    return ProductHiveModel(
      id: entity.id,
      name: entity.name,
      nutritionalInfo: entity.nutritionalInfo,
      category: entity.category,
      description: entity.description,
      price: entity.price,
      image: entity.image,
      inStock: entity.inStock,
      images: entity.images,
      manufacturer: entity.manufacturer,
      manufactureDateIso: entity.manufactureDate?.toIso8601String(),
      expireDateIso: entity.expireDate?.toIso8601String(),
      quantity: entity.quantity ?? 1,

      averageRating: entity.averageRating ?? 0,
      reviewCount: entity.reviewCount ?? 0,
      favorites: entity.favorites,

      // store only comment text
      comments: entity.comments.map((c) => c.comment).toList(),
    );
  }

  static List<ProductEntity> toEntityList(List<ProductHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }

  /// API Model -> Hive Model
  factory ProductHiveModel.fromApiModel(ProductApiModel apiModel) {
    return ProductHiveModel(
      id: apiModel.id,
      name: apiModel.name,
      nutritionalInfo: apiModel.nutritionalInfo,
      category: apiModel.category,
      description: apiModel.description,
      price: apiModel.price,
      image: apiModel.image,
      inStock: apiModel.inStock,
      images: apiModel.images,
      manufacturer: apiModel.manufacturer,
      manufactureDateIso: apiModel.manufactureDate?.toIso8601String(),
      expireDateIso: apiModel.expireDate?.toIso8601String(),
      quantity: apiModel.quantity,

      averageRating: apiModel.averageRating,
      reviewCount: apiModel.reviewCount,
      favorites: apiModel.favorites,

      comments: apiModel.comments.map((c) => c.comment).toList(),
    );
  }

  static List<ProductHiveModel> fromApiModelList(
    List<ProductApiModel> apiModels,
  ) {
    return apiModels
        .map((model) => ProductHiveModel.fromApiModel(model))
        .toList();
  }
}
