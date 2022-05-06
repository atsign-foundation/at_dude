import 'package:at_dude/controller/dude_controller.dart';
import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/widgets/atsign_avatar.dart';
import 'package:at_dude/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = 'history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DudeModel>? dudes;
  @override
  @override
  void didChangeDependencies() {
    context.watch<DudeController>().getDudes();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: const [AtsignAvatar()],
      ),
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 1),
      body: Consumer<DudeController>(
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
    );
  }
}
