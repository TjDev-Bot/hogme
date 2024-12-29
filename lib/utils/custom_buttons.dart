import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color buttonColor;
  final Color textColor;

  const CustomButtons(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.buttonColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          backgroundColor: buttonColor,
          elevation: 2,
          padding: const EdgeInsets.all(20.0),
          shape: RoundedRectangleBorder(
              //to set border radius to button
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
