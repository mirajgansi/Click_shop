import 'package:click_shop/screens/bottom_screen/favourite_screen.dart';
import 'package:click_shop/widgets/my_cart_button_widget.dart';
import 'package:click_shop/widgets/my_favourite_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage("assets/images/Group.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 8,
                    top: 8,
                    child: MyFavouriteButtonWidgets(),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFD4F7D2).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/gravity-ui_seal-check.svg',
                            width: 18,
                            height: 18,
                            color: Color(0xFF12A807),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "50+ in stock",
                            style: TextStyle(
                              color: Color(0xff12A807),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Text(
                "Happy Cookie",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              Text(
                "\RS299 /per kg",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
              ),

              SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: MyCartButtonWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
