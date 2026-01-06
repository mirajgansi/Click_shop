import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? productId;
  final String productName;
  final String productNutrition;
  final String productCategory;
  final String productDetails;
  final String productPrice;
  final String productImage;

  ProductEntity({
    required this.productId,
    required this.productName,
    required this.productNutrition,
    required this.productCategory,
    required this.productDetails,
    required this.productPrice,
    required this.productImage,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    productNutrition,
    productCategory,
    productDetails,
    productPrice,
    productImage,
  ];
}
