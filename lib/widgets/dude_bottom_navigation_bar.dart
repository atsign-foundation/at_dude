import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/dude_controller.dart';
import '../dude_theme.dart';
import '../screens/screens.dart';

class DudeBottomNavigationBar extends StatefulWidget {
  const DudeBottomNavigationBar({required this.selectedIndex, Key? key})
      : super(key: key);

  final int selectedIndex;
  @override
  State<DudeBottomNavigationBar> createState() =>
      _DudeBottomNavigationBarState();
}

class _DudeBottomNavigationBarState extends State<DudeBottomNavigationBar> {
  void _handleOnTap(int currentIndex) {
    if (currentIndex == 0) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => ShowCaseWidget(
                  builder:
                      Builder(builder: (context) => const SendDudeScreen()),
                )),
          ),
          (Route route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (((context) => const HistoryScreen()))),
          ((route) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0.0,
      backgroundColor: const Color(0x00ffffff),
      currentIndex: widget.selectedIndex,
      onTap: _handleOnTap,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.send_outlined),
          label: 'Send Dude',
        ),
        BottomNavigationBarItem(
          icon: Consumer<DudeController>(
            builder: ((context, dudeController, child) {
              return Badge(
                elevation: dudeController.dudeCount > 0 ? 2 : 0,
                showBadge: dudeController.dudeCount > 0 ? true : false,
                badgeColor: Theme.of(context).bottomAppBarColor,
                badgeContent: dudeController.dudeCount > 0
                    ? Text(
                        dudeController.dudeCount.toString(),
                        style: const TextStyle(
                          color: kAlternativeColor,
                        ),
                      )
                    : null,
                child: const Icon(
                  Icons.history_outlined,
                ),
              );
            }),
          ),
          label: 'History',
        ),
      ],
    );
  }
}
