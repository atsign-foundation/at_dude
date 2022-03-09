import 'dart:ui';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_dude/main.dart';
import 'package:at_dude/screens/screens.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class SendDudeScreen extends StatefulWidget {
  const SendDudeScreen({Key? key}) : super(key: key);
  static String routeName = 'sendDudeScreen';

  @override
  State<SendDudeScreen> createState() => _SendDudeScreenState();
}

class _SendDudeScreenState extends State<SendDudeScreen> {
  String dude = '';
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleSendDudeToContact(String contactAtsign) async {
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
      ..sharedBy = currentAtsign
      ..sharedWith = contactAtsign
      ..metadata = metaData;

    await atClient.put(
      key,
      dude,
    );

    atClientManager.syncService.sync();
    Navigator.of(context).popAndPushNamed(HistoryScreen.routeName);
    print(currentAtsign);
    print(dude);
  }

  @override
  Widget build(BuildContext context) {
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    SizeConfig().init(context);
    var atClientManager = AtClientManager.getInstance();
    AtClient atClient = atClientManager.atClient;
    String? currentAtsign = atClient.getCurrentAtSign();

    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      appBar: AppBar(title: Text('Send Dude')),
      bottomNavigationBar: DudeBottomNavigationBar(
        selectedIndex: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Center(
                  child: Text(dude, style: TextStyle(color: Colors.black)))),
          GestureDetector(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  // TODO: Send dude to atsign
                  // Snackbar will display String "Dude"
                  // on pressed of the elevated button
                  // var snackBar =
                  //     SnackBar(content: Text(strArr.join("").toString()));
                  // ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  setState(() {
                    dude = strArr.join("").toString();
                  });
                },
                child: Text(
                  'Send Dude',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              onLongPressStart: (_) async {
                _buttonPressed = true;
                do {
                  strArr.insert(1, "u");
                  setState(() {
                    dude = strArr.join("").toString();
                  });
                  await Future.delayed(Duration(milliseconds: 250));
                } while (_buttonPressed);
              },
              onLongPressEnd: (_) {
                setState(() {
                  _buttonPressed = false;
                });
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ContactsScreen(
                    onSendIconPressed: (String atsign) =>
                        _handleSendDudeToContact(atsign),
                  ),
                ));
                // String stringList = strArr.join("");
                // TODO: Send "Duuuuuude" to atsign
              }),

          // ListView.builder(itemBuilder: itemBuilder)
        ],
      ),
    );
  }
}
