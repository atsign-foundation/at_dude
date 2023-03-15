// import 'package:badges/badges.dart';
import 'dart:developer';

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
  const DudeBottomNavigationBar({required this.selectedIndex, Key? key}) : super(key: key);

  final int selectedIndex;
  @override
  State<DudeBottomNavigationBar> createState() => _DudeBottomNavigationBarState();
}

class _DudeBottomNavigationBarState extends State<DudeBottomNavigationBar> {
  void _handleOnTap(int currentIndex) {
    if (currentIndex == 4) {
      Navigator.of(context).pushNamed(SettingsScreen.routeName);
    } else if (currentIndex == 2) {
      Navigator.of(context).pushNamed(SendDudeScreen.routeName);
    } else if (currentIndex == 3) {
      Navigator.of(context).pushNamed(NotificationScreen.routeName);
    } else if (currentIndex == 1) {
      Navigator.of(context).pushNamed(StatsScreen.routeName);
    } else if (currentIndex == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShowCaseWidget(
              builder: Builder(
            builder: (context) => const DudeContactsScreen(),
          )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedFontSize: 12,
      unselectedFontSize: 12,
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
              return FutureBuilder(
                future: dudeController.dudeReadCount,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  var readCount = snapshot.data ?? 0;
                  log('future read count is $readCount');
                  return Badge(
                    isLabelVisible: readCount > 0 ? true : false,
                    backgroundColor: kAlternativeColor,
                    textColor: Colors.black,
                    // elevation: dudeController.dudeCount > 0 ? 2 : 0,
                    // showBadge: dudeController.dudeCount > 0 ? true : false,
                    // badgeColor: Theme.of(context).bottomAppBarColor,
                    label: readCount > 0
                        ? Text(
                            readCount.toString(),
                            style: const TextStyle(
                                // color: kAlternativeColor,
                                ),
                          )
                        : null,
                    child: SvgPicture.asset(
                      'assets/images/nav_icons/notifications.svg',
                      color: widget.selectedIndex == 3 ? kPrimaryColor : Colors.black,
                    ),
                  );
                },
              );
            }),
          ),
          label: Texts.notifications,
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
