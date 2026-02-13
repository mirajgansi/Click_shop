import 'package:flutter/material.dart';

class MyTextFieldWidgets extends StatefulWidget {
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
  State<MyTextFieldWidgets> createState() => _MyTextFieldWidgetsState();
}

class _MyTextFieldWidgetsState extends State<MyTextFieldWidgets> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.45)),
        labelText: widget.text,
        labelStyle: TextStyle(
          fontSize: 16,
          color: cs.onSurface.withOpacity(0.75),
          fontWeight: FontWeight.normal,
        ),

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.8)),
        ),

        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),

        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 2),
        ),

        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 2),
        ),

        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: cs.onSurface.withOpacity(0.65),
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${widget.text}';
            }
            return null;
          },
    );
  }
}
