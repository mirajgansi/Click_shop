import 'package:click_shop/app/routes/app_routes.dart';
import 'package:click_shop/features/product/presentation/pages/product_category_screen.dart';
import 'package:click_shop/features/product/presentation/widgets/my_category_widget.dart';
import 'package:flutter/material.dart';

final categories = [
  {
    "id": "meat",
    "title": "Meat & Fish",
    "image": "assets/images/meat.png",
    "bg": Color(0xFFFBEAEA),
    "border": Color(0xFFF0B4B4),
  },
  {
    "id": "oil",
    "title": "Cooking Oil\n& Ghee",
    "image": "assets/images/oil.png",
    "bg": Color(0xFFFFF1E6),
    "border": Color(0xFFFFC7A3),
  },
  {
    "id": "pulses",
    "title": "Pulses",
    "image": "assets/images/pulses.png",
    "bg": Color(0xFFFFF7D6),
    "border": Color(0xFFFFE08A),
  },
  {
    "id": "bakery",
    "title": "Bakery & Snacks",
    "image": "assets/images/bakery.png",
    "bg": Color(0xFFF1E9FF),
    "border": Color(0xFFD2C0FF),
  },
  {
    "id": "snacks",
    "title": "Snacks",
    "image": "assets/images/snacks.png",
    "bg": Color(0xFFEAF1FF),
    "border": Color(0xFFB9D0FF),
  },
  {
    "id": "beverages",
    "title": "Beverages",
    "image": "assets/images/beverages.png",
    "bg": Color(0xFFEAFBFF),
    "border": Color(0xFFAFE7F5),
  },
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _controller = TextEditingController();
  String q = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = categories.where((c) {
      final title = (c["title"] as String).toLowerCase();
      return title.contains(q.trim().toLowerCase());
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Search bar like screenshot
            TextField(
              controller: _controller,
              onChanged: (v) => setState(() => q = v),
              decoration: InputDecoration(
                hintText: "Search Store",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1, // keep your perfect size
                ),
                itemBuilder: (context, i) {
                  final cat = filtered[i];

                  return CategorySquareCard(
                    title: cat["title"] as String,
                    imagePath: cat["image"] as String,
                    backgroundColor: cat["bg"] as Color,
                    borderColor: cat["border"] as Color,
                    borderWidth: 1.2,
                    borderRadius: 18,
                    onTap: () {
                      AppRoutes.push(
                        context,
                        CategoryProductsPage(
                          categoryId: cat["id"] as String,
                          title: (cat["title"] as String).replaceAll("\n", " "),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
