import 'package:at_app_flutter/at_app_flutter.dart';

import 'package:at_contacts_flutter/at_contacts_flutter.dart';

import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/screens/screens.dart';
import 'package:at_dude/services/services.dart';
import 'package:flutter/material.dart';

import '../dude_theme.dart';
import '../widgets/widgets.dart';

class SendDudeScreen extends StatefulWidget {
  const SendDudeScreen({Key? key}) : super(key: key);
  static String routeName = 'sendDudeScreen';

  @override
  State<SendDudeScreen> createState() => _SendDudeScreenState();
}

class _SendDudeScreenState extends State<SendDudeScreen> {
  bool _buttonPressed = false;
  DudeModel dude = DudeModel.newDude();
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSendDudeToContact(
          DudeModel dude, String contactAtsign) async =>
      DudeService.getInstance().putDude(dude, contactAtsign).then((value) =>
          Navigator.of(context).popAndPushNamed(HistoryScreen.routeName));

  @override
  Widget build(BuildContext context) {
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    SizeConfig().init(context);

    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      appBar: AppBar(title: const Text('Send Dude')),
      bottomNavigationBar: const DudeBottomNavigationBar(
        selectedIndex: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Text(
                dude.dude,
                style: DudeTheme.lightTextTheme.bodyText1,
              ),
            ),
          ),
          GestureDetector(
              child: ElevatedButton(
                onPressed: () {
                  startTime = DateTime.now();
                  dude.saveId;
                  setState(() {
                    dude.saveDude(strArr.join("").toString());
                  });
                  dude.saveDuration(startTime);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ContactsScreen(
                      onSendIconPressed: (String atsign) =>
                          _handleSendDudeToContact(dude, atsign),
                    ),
                  ));
                },
                child: const Text(
                  'Send Dude',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              onLongPressStart: (_) async {
                startTime = DateTime.now();
                dude.saveId();

                _buttonPressed = true;
                do {
                  strArr.insert(1, "u");
                  setState(() {
                    dude.saveDude(strArr.join("").toString());
                  });
                  await Future.delayed(const Duration(milliseconds: 250));
                } while (_buttonPressed);
              },
              onLongPressEnd: (_) {
                setState(() {
                  _buttonPressed = false;
                });

                dude.saveDuration(startTime);

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ContactsScreen(
                    onSendIconPressed: (String atsign) =>
                        _handleSendDudeToContact(dude, atsign),
                  ),
                ));
              }),
        ],
      ),
    );
  }
}
