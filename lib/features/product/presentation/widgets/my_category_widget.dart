import 'package:flutter/material.dart';

class CategorySquareCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const CategorySquareCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    this.backgroundColor = const Color(0xFFF7F7F7),
    this.borderColor = const Color(0xFFE5E5E5),
    this.borderWidth = 1,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // keep square
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 90, // tweak if needed
                        maxWidth: 130,
                      ),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // title like screenshot
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
