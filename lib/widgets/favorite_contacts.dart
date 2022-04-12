import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../services/services.dart';
import 'widgets.dart';

class FavoriteContacts extends StatefulWidget {
  final DudeModel dude;
  const FavoriteContacts({required this.dude, Key? key}) : super(key: key);

  @override
  State<FavoriteContacts> createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  List<AtContact?>? selectedContacts = [];
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      selectedContacts = await DudeService.getInstance().getContactList();
      await DudeService.getInstance().getCurrentAtsignProfileImage();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _handleSendDudeToContact(
            DudeModel dude, String contactAtsign) async =>
        DudeService.getInstance().putDude(dude, contactAtsign).whenComplete(
          () {
            Navigator.of(context).popAndPushNamed(HistoryScreen.routeName);
          },
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Dudes +',
          style: Theme.of(context).textTheme.headline2,
        ),
        Flexible(
            child: selectedContacts == null || selectedContacts!.isEmpty
                ? const Text('No Contacts Available')
                : ListView.builder(
                    itemCount: selectedContacts!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (selectedContacts!.isEmpty ||
                          selectedContacts == null) {
                        return const Text('No Contacts');
                      } else {
                        return GestureDetector(
                          onTap: () {
                            if (widget.dude.dude.isEmpty) {
                              SnackBars.notificationSnackBar(
                                  content: 'No duuude to send',
                                  context: context);
                            } else {
                              _handleSendDudeToContact(widget.dude,
                                  selectedContacts![index]!.atSign!);
                            }
                          },
                          child: CircularContacts(
                            contact: selectedContacts![index],
                            onCrossPressed: () {},
                          ),
                        );
                      }
                    })),
      ],
    );
  }
}
