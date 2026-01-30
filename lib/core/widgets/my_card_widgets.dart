import 'package:click_shop/features/dashboard/presentation/pages/bottom_screen/favourite_screen.dart';
import 'package:click_shop/core/widgets/my_cart_button_widget.dart';
import 'package:click_shop/core/widgets/my_favourite_button_widgets.dart';
import 'package:click_shop/features/item/presentation/pages/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 250;

        final double padding = isTablet ? 6 : 8;
        final double iconSize = isTablet ? 20 : 25;
        final double fontSizeTitle = isTablet ? 14 : 16;
        final double fontSizePrice = isTablet ? 13 : 14;

        return AspectRatio(
          aspectRatio: 0.7, // width : height ratio for the card
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductDetailScreen(),
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
                      aspectRatio: 1, // keeps image square
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage("assets/images/Group.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
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
                      "Happy Cookie",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeTitle,
                      ),
                    ),

                    // PRICE + CART BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rs 299 / kg",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: fontSizePrice,
                          ),
                        ),
                        MyCartButtonWidget(),
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
