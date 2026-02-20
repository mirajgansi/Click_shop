import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final String name;
  final int qty;
  final double price;
  final double total;
  final String? imagePath;

  const ItemTile({
    super.key,
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
    this.imagePath,
  });
  String _fullImageUrl(String path) {
    return ApiEndpoints.buildFileUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: imagePath == null || imagePath!.isEmpty
              ? const Icon(Icons.image_not_supported)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _fullImageUrl(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Qty: $qty  •  Rs ${price.toStringAsFixed(0)}"),
            ],
          ),
        ),
        Text(
          "Rs ${total.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Update base URL if needed
}
