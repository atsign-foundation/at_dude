import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/dude_controller.dart';
import '../dude_theme.dart';
import '../screens/screens.dart';
import '../screens/settings_screen.dart';
import '../utils/texts.dart';

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
    if (currentIndex == 4) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (((context) => const SettingsScreen()))),
          ((route) => false));
    } else if (currentIndex == 2) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => ShowCaseWidget(
                  builder:
                      Builder(builder: (context) => const SendDudeScreen()),
                )),
          ),
          (Route route) => false);
    } else if (currentIndex == 3) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (((context) => const HistoryScreen()))),
          ((route) => false));
    } else if (currentIndex == 1) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (((context) => const StatsScreen()))),
          ((route) => false));
    } else if (currentIndex == 0) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: ((context) => ShowCaseWidget(
                  builder:
                      Builder(builder: (context) => const DudeContactsScreen()),
                )),
          ),
          (Route route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0.0,
      currentIndex: widget.selectedIndex,
      onTap: _handleOnTap,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/nav_icons/contacts.svg',
              color: widget.selectedIndex == 0 ? kPrimaryColor : Colors.black,
            ),
            label: Texts.contacts),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/nav_icons/stats.svg',
              color: widget.selectedIndex == 1 ? kPrimaryColor : Colors.black,
            ),
            label: Texts.stats),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/nav_icons/send_dude.svg',
              color: widget.selectedIndex == 2 ? kPrimaryColor : Colors.black,
            ),
            label: Texts.sendDude),
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
                child: SvgPicture.asset(
                  'assets/images/nav_icons/history.svg',
                  color:
                      widget.selectedIndex == 3 ? kPrimaryColor : Colors.black,
                ),
              );
            }),
          ),
          label: Texts.history,
        ),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/nav_icons/settings.svg',
              color: widget.selectedIndex == 4 ? kPrimaryColor : Colors.black,
            ),
            label: Texts.settings),
      ],
    );
  }
}
