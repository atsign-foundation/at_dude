// import 'package:badges/badges.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/dude_controller.dart';
import '../dude_theme.dart';
import '../models/arguments.dart';
import '../screens/screens.dart';
import '../screens/settings_screen.dart';
import '../utils/enums.dart';
import '../utils/texts.dart';

class DudeNavigationScreen extends StatefulWidget {
  static String routeName = 'dude navigation screen';

  const DudeNavigationScreen({Key? key}) : super(key: key);

  @override
  State<DudeNavigationScreen> createState() => _DudeNavigationScreenState();
}

class _DudeNavigationScreenState extends State<DudeNavigationScreen> {
  int selectedIndex = Screens.sendDude.index;
  Arguments? arguments;
  bool isOnTap = false;

  // @override
  // void initState() {
  //   selectedIndex = arguments.route ?? Screens.sendDude.index;
  //   super.initState();
  // }

  void _onTap(int index) {
    setState(() {
      isOnTap = true;
      selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ShowCaseWidget(
        builder: Builder(
      builder: (context) => const DudeContactsScreen(),
    )),
    const StatsScreen(),
    const SendDudeScreen(),
    const NotificationScreen(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)?.settings.arguments as Arguments?;
    if (arguments != null && !isOnTap) {
      log(arguments!.route.toString());

      selectedIndex = arguments!.route!;
    }

    return Scaffold(
      body: _widgetOptions[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0.0,
        currentIndex: selectedIndex,
        onTap: _onTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/nav_icons/contacts.svg',
                color: selectedIndex == 0 ? kPrimaryColor : Colors.black,
              ),
              label: Texts.contacts),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/nav_icons/stats.svg',
                color: selectedIndex == 1 ? kPrimaryColor : Colors.black,
              ),
              label: Texts.stats),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/nav_icons/send_dude.svg',
                color: selectedIndex == 2 ? kPrimaryColor : Colors.black,
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
                        color: selectedIndex == 3 ? kPrimaryColor : Colors.black,
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
                color: selectedIndex == 4 ? kPrimaryColor : Colors.black,
              ),
              label: Texts.settings),
        ],
      ),
    );
  }
}
