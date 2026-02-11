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
    return GestureDetector(
      onTap: () {
        if (product.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id!),
            ),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4), // 🔥 tighter bottom
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ flexible height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80, // 🔥 slightly smaller image area
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 65,
                        width: 65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _ProductImage(image: product.image),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: MyFavouriteButtonWidgets(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 3),

              SizedBox(
                height: 28, // 🔥 smaller stock badge area
                child: StockPillBadge(stock: product.inStock),
              ),

              const SizedBox(height: 2), // 🔥 minimal gap

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rs ${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 26,
                    width: 26,
                    child: MyCartButtonWidget(productId: product.id ?? ""),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
