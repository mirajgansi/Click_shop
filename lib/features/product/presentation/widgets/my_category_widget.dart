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
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 600;

    // smaller paddings + smaller image on tablet
    final pad = isTablet ? 8.0 : 12.0;
    final imageMaxH = isTablet ? 52.0 : 80.0;
    final imageMaxW = isTablet ? 70.0 : 100.0;
    final titleSize = isTablet ? 12.5 : 13.5;

    return InkWell(
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
          padding: EdgeInsets.fromLTRB(pad, pad, pad, isTablet ? 6 : 10),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: imageMaxH,
                      maxWidth: imageMaxW,
                    ),
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
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
