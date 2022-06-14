import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../controller/dude_controller.dart';
import '../models/dude_model.dart';
import '../widgets/atsign_avatar.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text('History'),
        actions: const [AtsignAvatar()],
        automaticallyImplyLeading: widget.canPop,
      ),
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 1),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        const AppBackground(alignment: Alignment.center),
        Consumer<DudeController>(
          builder: ((context, dudeController, child) =>
              dudeController.dudes.isEmpty
                  ? const Center(child: Text('No dudes available'))
                  : ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: dudeController.dudes.length,
                      itemBuilder: (context, index) {
                        return DudeBubble(dude: dudeController.dudes[index]);
                      })),
        ),
      ]),
    );
  }
}
