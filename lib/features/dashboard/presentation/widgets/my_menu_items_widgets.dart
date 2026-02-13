import 'package:flutter/material.dart';

class MyMenuItemWidget extends StatelessWidget {
  const MyMenuItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26, color: cs.onSurface.withOpacity(0.85)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18, // 20 was too big for list tile
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.65),
                  ),
                )
              : null,
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: cs.onSurface.withOpacity(0.55),
              ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          onTap: onTap,
        ),
        Divider(height: 1, color: cs.outlineVariant.withOpacity(0.6)),
      ],
    );
  }
}
