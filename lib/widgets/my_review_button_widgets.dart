import 'package:flutter/material.dart';

class MyReviewButtonWidgets extends StatelessWidget {
  final bool isRated;
  final VoidCallback onTap;

  const MyReviewButtonWidgets({
    super.key,
    required this.isRated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: onTap,
      icon: Icon(
        isRated ? Icons.star : Icons.star_border_outlined,
        color: isRated ? Colors.orange : Colors.grey,
        size: 20,
      ),
    );
  }
}
