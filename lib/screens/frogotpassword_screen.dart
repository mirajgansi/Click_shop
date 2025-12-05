import 'package:flutter/material.dart';

class FrogotpasswordScreen extends StatelessWidget {
  const FrogotpasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                      child: Image.asset('assets/images/Second.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: Text('SECOND'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 15,
                    bottom: 0,
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: const Text("Password"),
                      prefixIcon: const Icon(
                        Icons.lock_open_outlined,
                        size: 20,
                      ),
                      // suffixIcon: IconButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       _passwordVisible = !_passwordVisible;
                      //     });
                      //   },
                      //   icon: Icon(
                      //     _passwordVisible
                      //         ? Icons.visibility
                      //         : Icons.visibility_off,
                      //     size: 20,
                      //   ),
                      // ),
                    ),
                    validator: (value) {
                      if (value == "") {
                        return "password_cannot_be_empty";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 15,
                    bottom: 10,
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all<Size>(
                        const Size(double.infinity, 48),
                      ),
                      maximumSize: WidgetStateProperty.all<Size>(
                        const Size(double.infinity, 48),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromRGBO(84, 175, 230, 1),
                      ),
                      // Replace 'red' with 'Colors.red'
                    ),
                    onPressed: () {},
                    child: const Text("Change Password"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
