import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:click_shop/features/cart/presentation/widgets/checkout_button_widget.dart';
import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';
import 'package:click_shop/features/order/presentation/widgets/order_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:click_shop/features/cart/presentation/view_model/cart_view_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cartViewModelProvider.notifier).getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : state.cartProducts.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              itemCount: state.cartProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.cartProducts[index];
                final qty = item.quantity ?? 1;

                return _CartItemTile(
                  imageUrl: item.image,
                  title: item.name,
                  inStock: item.inStock > 0,
                  qty: qty,
                  price: item.price,
                  onRemove: () async {
                    await ref
                        .read(cartViewModelProvider.notifier)
                        .deleteFromCart(item.id ?? "");
                  },
                  onPlus: () {
                    ref
                        .read(cartViewModelProvider.notifier)
                        .changeQty(itemId: item.id ?? "", newQty: qty + 1);
                  },
                  onMinus: () {
                    if (qty <= 1) return;
                    ref
                        .read(cartViewModelProvider.notifier)
                        .changeQty(itemId: item.id ?? "", newQty: qty - 1);
                  },
                );
              },
            ),

      bottomNavigationBar: state.cartProducts.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: CheckoutButton(
                  total: ref
                      .read(cartViewModelProvider.notifier)
                      .totalPrice
                      .toDouble(),
                  onCheckout: () {
                    showCheckoutSheet(
                      context: context,
                      ref: ref,
                      total: ref
                          .read(cartViewModelProvider.notifier)
                          .totalPrice,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool inStock;
  final int qty;
  final num price;
  final VoidCallback onRemove;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  const _CartItemTile({
    required this.imageUrl,
    required this.title,
    required this.inStock,
    required this.qty,
    required this.price,
    required this.onRemove,
    required this.onPlus,
    required this.onMinus,
  });

  String _buildImageUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;

    return "${ApiEndpoints.getHostUrl()}${path.startsWith("/") ? "" : "/"}$path";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cs.surfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? Image.asset("assets/images/Group.jpg", fit: BoxFit.cover)
                  : Image.network(
                      _buildImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/Group.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + remove X
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  inStock ? "In stock" : "Out of stock",
                  style: TextStyle(
                    color: inStock ? Colors.green : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QtyControl(qty: qty, onMinus: onMinus, onPlus: onPlus),
                    Text(
                      "Rs.${price.toString()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyControl({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.surfaceVariant),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onMinus,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: Icon(Icons.remove, size: 18),
            ),
          ),
          SizedBox(
            width: 22,
            child: Text(
              "$qty",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
