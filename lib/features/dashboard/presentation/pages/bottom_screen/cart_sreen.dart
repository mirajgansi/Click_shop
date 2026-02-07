import 'package:click_shop/core/config/api_endpoints.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : state.cartProducts.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              itemCount: state.cartProducts.length, // ✅
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.cartProducts[index]; // ✅
                final qty = 1; // (until you implement quantity)

                return _CartItemTile(
                  imageUrl: item.image,
                  title: item.name,
                  inStock: (item.inStock ?? 0) > 0,
                  qty: qty,
                  price: item.price ?? 0,
                  onRemove: () async {
                    await ref
                        .read(cartViewModelProvider.notifier)
                        .deleteFromCart(item.id ?? ""); // ✅ correct method
                  },
                  onPlus: () {
                    // optional: implement update quantity later
                  },
                  onMinus: () {
                    // optional: implement update quantity later
                  },
                );
              },
            ),

      // Bottom checkout bar
      bottomNavigationBar: state.cartProducts.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _CheckoutBar(
                  total: ref.read(cartViewModelProvider.notifier).totalPrice,
                  onCheckout: () async {
                    final ok = await ref
                        .read(cartViewModelProvider.notifier)
                        .orderFromCart();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? "Order created ✅" : "Order failed ❌",
                        ),
                      ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey.shade100,
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

                // Qty control + price
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
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
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

class _CheckoutBar extends StatelessWidget {
  final num total;
  final VoidCallback onCheckout;

  const _CheckoutBar({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onCheckout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  "Go to\nCheckout",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Rs.${total.toString()}",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
