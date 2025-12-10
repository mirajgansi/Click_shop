import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.7,

        children: List.generate(20, (index) {
          return Card(
            margin: const EdgeInsets.all(10.0),

            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'assets/images/8140 1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.favorite_border, color: Colors.black),
                ),
                Positioned(
                  bottom: 40,
                  right: 10,
                  child: Text(
                    '50+ in stock',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.lightGreenAccent,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    'Item ${index + 1} \n Rs. ${((index + 1) * 50)}/per kg',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.favorite_border, color: Colors.black),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.favorite_border, color: Colors.black),
                ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Icon(Icons.shopping_cart, color: Colors.black),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
