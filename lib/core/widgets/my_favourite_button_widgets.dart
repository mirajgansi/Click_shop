import 'package:flutter/material.dart';

class MyFavouriteButtonWidgets extends StatefulWidget {
  const MyFavouriteButtonWidgets({super.key});

  @override
  State<MyFavouriteButtonWidgets> createState() =>
      _MyFavouriteButtonWidgetsState();
}

class _MyFavouriteButtonWidgetsState extends State<MyFavouriteButtonWidgets> {
  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          isFavourite = !isFavourite;
        });
      },
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        color: isFavourite ? Colors.red : Colors.black,
      ),
    );
  }
}
