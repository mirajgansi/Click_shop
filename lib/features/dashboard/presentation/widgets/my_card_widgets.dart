import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/widgets/my_cart_button_widget.dart';
import 'package:click_shop/core/widgets/my_favourite_button_widgets.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_stock_badge_widget.dart';
import 'package:click_shop/features/product/presentation/pages/product_screen.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CardWidget extends StatelessWidget {
  final ProductEntity product;

  const CardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
        color: cs.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 90,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _ProductImage(image: product.image),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: SizedBox(
                        height: 22,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: StockPillBadge(stock: product.inStock),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

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
                    height: 24,
                    width: 24,
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
    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset("assets/images/Group.jpg", fit: BoxFit.cover),
      );
    }

    final baseUrl = ApiEndpoints.getHostUrl();
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
