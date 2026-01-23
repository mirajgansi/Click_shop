import 'package:flutter/material.dart';

class MyMenuItemsWidgets extends StatelessWidget {
  const MyMenuItemsWidgets({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.onTap,
    this.trailing,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Widgets shown when expanded (TextField, Switch, Buttons, etc.)
  final List<Widget> children;

  /// Optional tap if you DON'T want expand and want simple action
  final VoidCallback? onTap;

  /// Optional trailing (e.g., Switch)
  final Widget? trailing;

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    // If you want dropdown/expand, use ExpansionTile.
    if (children.isNotEmpty) {
      return Column(
        children: [
          ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Icon(icon, size: 26, color: Colors.black),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: subtitle == null ? null : Text(subtitle!),
            trailing:
                trailing ??
                const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            children: children,
          ),
        ],
      );
    }

    // Otherwise behave like normal ListTile (for simple navigation)
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          trailing:
              trailing ??
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.black,
              ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 1,
          ),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
