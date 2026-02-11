import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;

  const OtpInput({super.key, this.length = 6, required this.onChanged});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _notify() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
  }

  void _focus(int i) {
    if (i >= 0 && i < _nodes.length) _nodes[i].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 48,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(fontSize: 18, letterSpacing: 2),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (v) {
              if (v.isNotEmpty) {
                if (i < widget.length - 1) _focus(i + 1);
              } else {
                if (i > 0) _focus(i - 1);
              }
              _notify();
            },
            onTap: () {
              _controllers[i].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[i].text.length,
              );
            },
            onSubmitted: (_) => _notify(),
            onEditingComplete: _notify,
          ),
        );
      }),
    );
  }
}
