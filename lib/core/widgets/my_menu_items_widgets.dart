import 'package:flutter/material.dart';

class MyMenuItemsWidgets extends StatelessWidget {
  const MyMenuItemsWidgets({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26, color: Colors.black),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.black,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
          onTap: () {},
        ),
        const Divider(),
      ],
    );
  }
}
