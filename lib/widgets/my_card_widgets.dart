import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage("assets/shoe.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(Icons.favorite_border, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Text("Nike Air Max"),
              Text("\$299"),

              SizedBox(height: 8),
              ElevatedButton(onPressed: () {}, child: Text("Add to Cart")),
            ],
          ),
        ),
      ),
    );
  }
}
