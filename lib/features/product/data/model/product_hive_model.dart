import 'package:click_shop/core/constants/hive_table_constants.dart';
import 'package:click_shop/features/auth/domain/entities/auth_entity.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.productTypeId)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String? productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String productNutrition;

  @HiveField(3)
  final String productCategory;

  @HiveField(4)
  final String productDetails;

  @HiveField(5)
  final String productPrice;

  @HiveField(6)
  final String productImage;

  ProductHiveModel({
    String? productId,
    required this.productName,
    required this.productNutrition,
    required this.productCategory,
    required this.productDetails,
    required this.productPrice,
    required this.productImage,
  }) : productId = productId ?? Uuid().v4();

  //from entity to hive model
  factory ProductHiveModel.fromEntity(ProductEntity productEntity) {
    return ProductHiveModel(
      productId: productEntity.productId,
      productName: productEntity.productName,
      productNutrition: productEntity.productNutrition,
      productCategory: productEntity.productCategory,
      productDetails: productEntity.productDetails,
      productPrice: productEntity.productPrice,
      productImage: productEntity.productImage,
    );
  }

  //to entity
  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      productName: productName,
      productNutrition: productNutrition,
      productCategory: productCategory,
      productDetails: productDetails,
      productPrice: productPrice,
      productImage: productImage,
    );
  }

  //To entity list
  static List<ProductEntity> toEntityList(List<ProductHiveModel> hiveModels) {
    return hiveModels.map((model) => model.toEntity()).toList();
  }
}
