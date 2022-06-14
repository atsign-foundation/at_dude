import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent.withOpacity(0.2),
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
