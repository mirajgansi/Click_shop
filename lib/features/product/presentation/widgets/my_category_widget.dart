import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap;

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  final double aspectRatio;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    this.backgroundColor = const Color(0xFFF7F7F7),
    this.borderColor = const Color(0xFFE5E5E5),
    this.borderWidth = 1,
    this.borderRadius = 18,
    this.aspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
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
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: aspectRatio == 1
                ? _buildVerticalLayout()
                : _buildHorizontalLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 80, maxWidth: 100),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        SizedBox(
          height: 55,
          width: 55,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
