import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.alignment,
    this.assetImageLink = 'assets/images/background_image.png',
    Key? key,
  }) : super(key: key);

  final AlignmentGeometry alignment;
  final String assetImageLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(assetImageLink),
            fit: BoxFit.cover,
            opacity: 1,
            colorFilter:
                const ColorFilter.mode(Colors.transparent, BlendMode.darken),
            alignment: alignment),
      ),
    );
  }
}
