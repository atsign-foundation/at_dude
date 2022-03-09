import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_dude/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = 'history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? dude;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _handleDudeHistory());
  }

  void _handleDudeHistory() async {
    var atClientManager = AtClientManager.getInstance();
    Future<AtClientPreference> futurePreference = loadAtClientPreference();
    var preference = await futurePreference;
    String? currentAtsign;
    late AtClient atClient;
    atClient = atClientManager.atClient;
    atClientManager.atClient.setPreferences(preference);
    currentAtsign = atClient.getCurrentAtSign();

    var metaData = Metadata()
      ..isPublic = true
      ..isEncrypted = true
      ..namespaceAware = true;

    var key = AtKey()
      ..key = 'dude'
      ..sharedBy = null
      ..sharedWith = currentAtsign
      ..metadata = metaData;

    var data = await atClient.get(key);
    setState(() {
      dude = data.value;
    });
    atClientManager.syncService.sync();
    print("message is:" + dude.toString());
    print("atsign is:" + currentAtsign.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      bottomNavigationBar: DudeBottomNavigationBar(selectedIndex: 1),
      body: Builder(builder: (context) {
        return Center(
          child: Text(dude ?? 'No dude available'),
        );
      }),
    );
  }
}
