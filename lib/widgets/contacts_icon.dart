import 'package:flutter/material.dart';

import '../dude_theme.dart';

class ContactsIcon extends StatelessWidget {
  const ContactsIcon({
    required this.title,
    required this.icon,
    required this.onPress,
    Key? key,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: const ShapeDecoration(
                color: kPrimaryColor, shape: CircleBorder()),
            child: IconButton(
                icon: Icon(icon), color: Colors.white, onPressed: onPress),
          ),
        ),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 10, color: kPrimaryColor),
        )
      ],
    );
  }
}
