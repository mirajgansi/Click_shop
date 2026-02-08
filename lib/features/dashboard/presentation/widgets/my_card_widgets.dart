import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/widgets/my_cart_button_widget.dart';
import 'package:click_shop/core/widgets/my_favourite_button_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_stock_badge_widget.dart';
import 'package:click_shop/features/product/presentation/pages/product_screen.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final ProductEntity product;

  const CardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 250;

        final double padding = isTablet ? 6 : 8;
        final double fontSizeTitle = isTablet ? 14 : 16;
        final double fontSizePrice = isTablet ? 13 : 14;

        return AspectRatio(
          aspectRatio: 0.7,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productId: product.id!, // if nullable handle null
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _ProductImage(image: product.image),
                          ),
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: MyFavouriteButtonWidgets(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // TITLE
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeTitle,
                      ),
                    ),
                    StockPillBadge(stock: product.inStock),

                    // PRICE + CART BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rs ${product.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: fontSizePrice,
                          ),
                        ),
                        MyCartButtonWidget(
                          // ✅ pass product id to add-to-cart
                          productId: product.id ?? "",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String image;
  const _ProductImage({required this.image});

  @override
  Widget build(BuildContext context) {
    // ✅ if backend gives full http url
    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset("assets/images/Group.jpg", fit: BoxFit.cover),
      );
    }

    // ✅ if backend gives relative path like "uploads/xxx.jpg"
    // replace baseUrl with your ApiEndpoints host
    final baseUrl = ApiEndpoints.getHostUrl(); // you already have this
    final url = "$baseUrl/$image"
        .replaceAll(RegExp(r'//+'), '/')
        .replaceFirst(':/', '://');

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset("assets/images/Group.jpg", fit: BoxFit.cover),
    );
  }
}
