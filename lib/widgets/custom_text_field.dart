import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final RegExp validatorRegExp;
  final void Function(String?) onSaved;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.validatorRegExp,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: (value) {
        if (value != null && validatorRegExp.hasMatch(value)) {
          return null;
        }
        return "Please enter a valid ${hintText.toLowerCase()}";
      },
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
