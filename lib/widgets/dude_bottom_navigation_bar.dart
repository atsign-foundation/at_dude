import 'package:flutter/material.dart';

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
      Navigator.of(context).popAndPushNamed(SendDudeScreen.routeName);
    } else {
      Navigator.of(context).popAndPushNamed(HistoryScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: _handleOnTap,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: 'Send Dude',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
        ]);
  }
}
