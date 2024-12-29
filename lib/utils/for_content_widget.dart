import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';

class ForContentWidget extends StatelessWidget {
  final String contentTitle;

  const ForContentWidget({
    required this.contentTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: text24Bold(text: contentTitle),
    );
  }
}