import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade500, Colors.green.shade100],
          ),
        ),
        child: Form(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                      image: AssetImage('assets/images/8140 1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome\nto our store',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                MyButtonWidgets(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  text: 'Get Started',
                  height: 50,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
