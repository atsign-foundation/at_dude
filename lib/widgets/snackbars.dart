import 'package:flutter/material.dart';

import '../dude_theme.dart';

class SnackBars extends StatelessWidget {
  const SnackBars({Key? key}) : super(key: key);
  static void errorSnackBar(
      {required String content, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  static void notificationSnackBar(
      {required String content, required BuildContext context}) {
    Duration duration = const Duration(seconds: 3);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      duration: duration,
      backgroundColor: kAlternativeColor,
      // action: SnackBarAction(
      //   label: 'Ok',
      //   onPressed: () {},
      //   textColor: Colors.white,
      // ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
