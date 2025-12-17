class ProductModel {
  final String id;
  final String productName;
  final String price;
  final String nutrition;
  final String productDetail;
  final String imageUrl;
  final String categories;

  ProductModel({
    required this.productName,
    required this.price,
    required this.nutrition,
    required this.productDetail,
    required this.id,
    required this.imageUrl,
    required this.categories,
  });
}
