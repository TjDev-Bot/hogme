import 'package:flutter/material.dart';

class TapContent extends StatefulWidget {
  final void Function()? onTap;

  const TapContent({
    required this.onTap,
    super.key,
  });

  @override
  State<TapContent> createState() => _TapContentState();
}

class _TapContentState extends State<TapContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: const Icon(
          Icons.arrow_outward_sharp,
          color: Colors.white,
        ),
      ),
    );
  }
}