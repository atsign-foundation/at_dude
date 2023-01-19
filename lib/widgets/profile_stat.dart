import 'package:flutter/material.dart';

import '../dude_theme.dart';

class ProfileStat extends StatelessWidget {
  final String stat;
  final String? unit;
  final String description;

  const ProfileStat(
      {required this.stat, required this.description, this.unit, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 0.40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stat,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: kPrimaryColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w500)),
                    unit != null
                        ? Text(
                            unit!,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: kPrimaryColor, fontSize: 12),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              flex: 1,
              child: FractionallySizedBox(
                widthFactor: 1.1,
                child: Text(
                  description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ));
  }
}
