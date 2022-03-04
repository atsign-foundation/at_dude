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
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    SizeConfig().init(context);
    List<String> strArr = ['D', 'u', 'd', 'e'];
    String stringList = '';
    bool _buttonPressed = false;
    return Scaffold(
      appBar: AppBar(title: Text('Send Dude')),
      bottomNavigationBar: DudeBottomNavigationBar(
        selectedIndex: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(stringList),
          GestureDetector(
              child: FloatingActionButton(
                onPressed: () {},
                child: Text('Dude'),
              ),
              onTap: () {
                // TODO: Send dude to atsign
                // Snackbar will display String "Dude"
                // on pressed of the elevated button
                var snackBar = SnackBar(content: Text(strArr.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                stringList = strArr.join("");
              },
              onLongPressStart: (_) async {
                _buttonPressed = true;
                do {
                  stringList = strArr.join("");
                  setState(() {});
                  var snackBar = SnackBar(
                      duration: const Duration(milliseconds: 500),
                      content: Text(stringList));
                  strArr.insert(1, "u");

                  print("strArr tapdown => $strArr");
                  await Future.delayed(Duration(seconds: 1));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } while (_buttonPressed);
              },
              onLongPressEnd: (_) {
                setState(() {
                  _buttonPressed = false;
                });
                String stringList = strArr.join("");
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
