import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/contacts_controller.dart';
import '../controller/dude_controller.dart';
import '../models/dude_model.dart';
import '../services/navigation_service.dart';
import '../widgets/dude_card.dart';
import '../widgets/widgets.dart';
import 'dude_contacts_screen.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = 'notification';
  final bool canPop;
  const NotificationScreen({this.canPop = false, Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<DudeModel>? dudes;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<DudeController>(context, listen: false).getDudes();
      await Provider.of<ContactsController>(context, listen: false).getContacts();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Colors.transparent,
      //   shadowColor: Colors.transparent,
      //   title: const Text(Texts.history, style: TextStyle(color: Colors.black)),
      //   actions: const [AtsignAvatar()],
      //   automaticallyImplyLeading: widget.canPop,
      // ),
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 3),
      // extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        const AppBackground(alignment: Alignment.bottomCenter),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Consumer<DudeController>(
              builder: ((context, dudeController, child) => Column(
                    children: [
                      Flexible(
                          flex: 5,
                          child: dudeController.dudes.isEmpty
                              ? DudeCard(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'No new dudes!',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset('assets/images/drifty_rory_sad.png'),
                                      ElevatedButton(
                                          style:
                                              ElevatedButton.styleFrom(fixedSize: const Size(double.maxFinite, 61.22)),
                                          onPressed: () async {
                                            await Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (context) => ShowCaseWidget(
                                                        builder: Builder(
                                                      builder: (context) => const DudeContactsScreen(),
                                                    )),
                                                  ),
                                                )
                                                .whenComplete(() async => await NavigationService.navKey.currentContext!
                                                    .read<DudeController>()
                                                    .getContacts());
                                          },
                                          child: const Text('Send Dude'))
                                    ],
                                  ),
                                )
                              : DudeCard(
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  color: const Color.fromRGBO(255, 255, 255, 0.5),
                                  child: ListView.builder(
                                      // reverse: true,
                                      shrinkWrap: true,
                                      itemCount: dudeController.dudes.length,
                                      itemBuilder: (context, index) {
                                        return DudeBubble(key: GlobalKey(), dude: dudeController.dudes[index]);
                                      }),
                                )),
                    ],
                  )),
            ),
          ),
        ),
      ]),
    );
  }
}
