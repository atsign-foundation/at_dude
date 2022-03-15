import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/services/dude_service.dart';
import 'package:at_dude/widgets/dude_bubble.dart';
import 'package:at_dude/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = 'history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DudeModel>? dudes;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(
        (_) async => await DudeService.getInstance().getDudes().then((value) {
              setState(() {
                dudes = value;
              });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 1),
      body: Builder(builder: (context) {
        return dudes == null
            ? const Center(child: Text('No dudes available'))
            : ListView.builder(
                itemCount: dudes!.length,
                itemBuilder: (context, index) {
                  return DudeBubble(dude: dudes![index]);
                });
      }),
    );
  }
}
