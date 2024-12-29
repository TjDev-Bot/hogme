import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  //pass controller for textfields such as email and password
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Icon icon;
  final FormFieldValidator<String>? validator;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.all(8.0),
      child: TextFormField(
        style: const TextStyle(color: Colors.grey),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hoverColor: Colors.grey,
          focusColor: Colors.grey,
          labelStyle: const TextStyle(color: Colors.grey),
          suffixIcon: icon,
          enabledBorder:  const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: Colors.transparent,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        validator: validator,
      ),
    );
  }
}
