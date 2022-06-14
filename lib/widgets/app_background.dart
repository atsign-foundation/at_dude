import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.alignment,
    Key? key,
  }) : super(key: key);

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: const AssetImage('assets/images/beach_alt.png'),
            fit: BoxFit.cover,
            opacity: 1,
            colorFilter:
                const ColorFilter.mode(Colors.transparent, BlendMode.darken),
            alignment: alignment),
      ),
    );
  }
}
