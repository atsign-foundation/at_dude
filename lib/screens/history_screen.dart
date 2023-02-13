import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/contacts_controller.dart';
import '../controller/dude_controller.dart';
import '../models/dude_model.dart';
import '../widgets/dude_card.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = 'history';
  final bool canPop;
  const HistoryScreen({this.canPop = false, Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DudeModel>? dudes;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<DudeController>(context, listen: false).getDudes();
      await Provider.of<ContactsController>(context, listen: false)
          .getContacts();
    });
    super.initState();
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
                              ? const Center(
                                  child: Text('No dudes available',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)))
                              : DudeCard(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.5),
                                  child: ListView.builder(
                                      // reverse: true,
                                      shrinkWrap: true,
                                      itemCount: dudeController.dudes.length,
                                      itemBuilder: (context, index) {
                                        return DudeBubble(
                                            dude: dudeController.dudes[index]);
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
