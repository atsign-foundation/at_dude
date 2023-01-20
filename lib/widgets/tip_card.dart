import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  const TipCard({required this.tip, Key? key}) : super(key: key);
  final String tip;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(47, 0, 0, 0),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: Center(
          child: RichText(
            text: TextSpan(
              text: '',
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: 11, color: Colors.white),
              children: [
                TextSpan(
                    text: '💡Tip',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.white)),
                const TextSpan(text: ': '),
                TextSpan(text: tip),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
