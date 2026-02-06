import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';

class MyCartButtonWidget extends StatefulWidget {
  const MyCartButtonWidget({super.key, required String productId});

  @override
  State<MyCartButtonWidget> createState() => _MyCartButtonWidgetState();
}

class _MyCartButtonWidgetState extends State<MyCartButtonWidget> {
  bool isCartAdded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 250;

        final double buttonSize = isTablet ? 34 : 40;
        final double iconSize = isTablet ? 20 : 25;

        return SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isCartAdded = !isCartAdded;
              });

              MotionToast.success(
                description: const Text("Item added to cart"),
                toastDuration: const Duration(seconds: 1),
              ).show(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: const Color(0xFF329C2A),
              padding: EdgeInsets.zero,
            ),
            child: SvgPicture.asset(
              'assets/icons/bx_cart-add.svg',
              width: iconSize,
              height: iconSize,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
