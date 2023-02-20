import 'package:flutter/material.dart';

class DudeCard extends StatelessWidget {
  const DudeCard({
    Key? key,
    required this.child,
    this.width = 343.0,
    this.height,
    this.color = const Color.fromRGBO(255, 255, 255, 74),
  }) : super(key: key);

  final Widget child;
  final double width;
  final double? height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: color,
        shadowColor: Colors.transparent,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            width: width,
            height: height,
            child: child),
      ),
    );
  }
}
