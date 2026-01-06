import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_text_field_widgets.dart';
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
                Center(
                  child: Image.asset(
                    'assets/images/Group.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 15,
                    bottom: 0,
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: MyTextFieldWidgets(
                    controller: passwordController,
                    obscureText: true,
                    hintText: 'Enter New Password',
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
                    validator: (value) {
                      if (value == "") {
                        return "password_cannot_be_empty";
                      }
                      return null;
                    },
                    text: 'New Password',
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 15,
                    bottom: 10,
                  ),
                  child: MyButtonWidgets(
                    // style: ButtonStyle(
                    //   minimumSize: WidgetStateProperty.all<Size>(
                    //     const Size(double.infinity, 48),
                    //   ),
                    //   maximumSize: WidgetStateProperty.all<Size>(
                    //     const Size(double.infinity, 48),
                    //   ),
                    //   backgroundColor: WidgetStateProperty.all<Color>(
                    //     const Color.fromRGBO(84, 175, 230, 1),
                    //   ),
                    //   // Replace 'red' with 'Colors.red'
                    // ),
                    onPressed: () {},
                    text: 'Submit',
                    height: 12,
                    borderRadius: 12,
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
