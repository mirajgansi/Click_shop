import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motion_toast/motion_toast.dart';

import 'package:click_shop/features/cart/presentation/view_model/cart_view_model.dart';

class MyCartButtonWidget extends ConsumerStatefulWidget {
  final String productId;

  const MyCartButtonWidget({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<MyCartButtonWidget> createState() =>
      _MyCartButtonWidgetState();
}

class _MyCartButtonWidgetState extends ConsumerState<MyCartButtonWidget> {
  bool isLoading = false;

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
            onPressed: isLoading
                ? null
                : () async {
                    setState(() => isLoading = true);

                    final success = await ref
                        .read(cartViewModelProvider.notifier)
                        .addToCart(widget.productId, 1);

                    setState(() => isLoading = false);

                    if (!context.mounted) return;

                    if (success) {
                      MotionToast.success(
                        description: const Text("Item added to cart"),
                        toastDuration: const Duration(seconds: 1),
                      ).show(context);
                    } else {
                      MotionToast.error(
                        description: const Text("Failed to add item"),
                        toastDuration: const Duration(seconds: 1),
                      ).show(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: const Color(0xFF329C2A),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : SvgPicture.asset(
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
