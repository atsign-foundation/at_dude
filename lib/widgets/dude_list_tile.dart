import 'package:flutter/material.dart';

import 'dude_card.dart';

class DudeListTile extends StatelessWidget {
  const DudeListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    Key? key,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return DudeCard(
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline2,
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyText2),
        trailing: Text(
          trailing,
          style: const TextStyle(
            fontSize: 49,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
