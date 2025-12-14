import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Add To Basket",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/Group.jpg",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Wishlist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Wai Wai",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.favorite_border),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text("1 box, Price", style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 16),

                  /// Quantity + Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ),

                      const Text(
                        "Rs. 120",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  _sectionTitle("Product Detail"),
                  const SizedBox(height: 8),
                  Text(
                    "Wai Wai is a popular instant noodle brand loved for its unique taste and quick preparation. It can be eaten straight from the packet, boiled, or fried.",
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  TextButton(onPressed: () {}, child: const Text("See More")),

                  const Divider(),

                  _listTile(title: "Nutritions", trailing: "100g"),

                  const Divider(),

                  _listTile(
                    title: "Review",
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, size: 18, color: Colors.orange),
                        Icon(Icons.star, size: 18, color: Colors.orange),
                        Icon(Icons.star, size: 18, color: Colors.orange),
                        Icon(Icons.star, size: 18, color: Colors.orange),
                        Icon(Icons.star, size: 18, color: Colors.orange),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Title Widget
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  /// List Tile Row
  Widget _listTile({
    required String title,
    String? trailing,
    Widget? trailingWidget,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing:
          trailingWidget ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text(trailing ?? ""), const Icon(Icons.chevron_right)],
          ),
    );
  }
}
