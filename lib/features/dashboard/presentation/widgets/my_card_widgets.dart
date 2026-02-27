import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/core/widgets/my_cart_button_widget.dart';
import 'package:click_shop/features/dashboard/presentation/widgets/my_stock_badge_widget.dart';
import 'package:click_shop/features/product/domain/entities/product_entity.dart';
import 'package:click_shop/features/product/presentation/pages/product_screen.dart';
import 'package:click_shop/features/product/presentation/widgets/my_favriotes_button_wwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardWidget extends ConsumerWidget {
  final ProductEntity product;

  const CardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (product.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id!),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),

          // 👇 OUTER soft gradient glow
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.03),
                    Colors.white.withOpacity(0.01),
                  ]
                : [
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.015),
                  ],
          ),
        ),
        padding: const EdgeInsets.all(2), // space for glow
        child: Card(
          elevation: 2,
          color: cs.surface, // keep card clean
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        top: 10,
                        right: 10,
                        child: ProductFavoriteButton(
                          productId: product.id ?? "",
                          favorites: product.favorites,
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

                const SizedBox(height: 6),

                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rs ${product.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String image;
  const _ProductImage({required this.image});

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset("assets/images/Group.jpg", fit: BoxFit.cover);

    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    final baseUrl = ApiEndpoints.getHostUrl();
    final url = "$baseUrl/$image"
        .replaceAll(RegExp(r'//+'), '/')
        .replaceFirst(':/', '://');

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
