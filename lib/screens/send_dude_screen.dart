import 'dart:ui';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class SendDudeScreen extends StatefulWidget {
  const SendDudeScreen({Key? key}) : super(key: key);
  static String routeName = 'sendDudeScreen';

  @override
  State<SendDudeScreen> createState() => _SendDudeScreenState();
}

class _SendDudeScreenState extends State<SendDudeScreen> {
  String stringList = '';
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    SizeConfig().init(context);
    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      appBar: AppBar(title: Text('Send Dude')),
      bottomNavigationBar: DudeBottomNavigationBar(
        selectedIndex: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
              child: Text(stringList, style: TextStyle(color: Colors.black))),
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
                    stringList = strArr.join("").toString();
                  });
                },
                child: Text(
                  'Select Dude',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              onLongPressStart: (_) async {
                _buttonPressed = true;
                do {
                  strArr.insert(1, "u");
                  setState(() {
                    stringList = strArr.join("").toString();
                  });
                  await Future.delayed(Duration(milliseconds: 250));
                } while (_buttonPressed);
              },
              onLongPressEnd: (_) {
                setState(() {
                  _buttonPressed = false;
                });
                // String stringList = strArr.join("");
                // TODO: Send "Duuuuuude" to atsign
              }),
          ElevatedButton(
            onPressed: () {
              // any logic
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const ContactsScreen(),
              ));
            },
            child: const Text('Send to contact'),
          ),
          // ListView.builder(itemBuilder: itemBuilder)
        ],
      ),
    );
  }
}
