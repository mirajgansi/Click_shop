import 'package:flutter/material.dart';

class MyTextFieldWidgets extends StatelessWidget {
  const MyTextFieldWidgets({
    super.key,
    required this.controller,
    required this.hintText,
    required this.text,
    this.validator,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String text;
  final String? Function(String?)? validator;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hint: Text(hintText),
        labelText: text,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return ('Please enter $text');
        }
        return null;
      },
      obscureText: obscureText,
    );
  }
}
