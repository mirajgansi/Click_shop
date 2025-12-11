import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';

class MyCartButtonWidget extends StatefulWidget {
  const MyCartButtonWidget({super.key});

  @override
  State<MyCartButtonWidget> createState() => _MyCartButtonWidgetState();
}

class _MyCartButtonWidgetState extends State<MyCartButtonWidget> {
  bool isCartAdded = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isCartAdded = !isCartAdded;
          });
          MotionToast.success(
            description: Text("Item added to cart"),
            toastDuration: Duration(seconds: 1),
          ).show(context);
        },

        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: Color(0xFF329C2A),
          padding: EdgeInsets.all(5),
          elevation: 8,
        ),
        child: SvgPicture.asset(
          'assets/icons/bx_cart-add.svg',
          width: 25,
          height: 25,
        ),
      ),
    );
  }
}
