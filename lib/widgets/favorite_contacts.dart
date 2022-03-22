import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../services/services.dart';

class FavoriteContacts extends StatelessWidget {
  final DudeModel dude;
  const FavoriteContacts({required this.dude, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ContactService _contactService = ContactService();

    Future<void> _handleSendDudeToContact(
            DudeModel dude, String contactAtsign) async =>
        DudeService.getInstance().putDude(dude, contactAtsign).then(
              (value) => Navigator.of(context)
                  .popAndPushNamed(HistoryScreen.routeName),
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
          child: StreamBuilder<List<AtContact?>>(
              initialData: _contactService.contactList,
              stream: _contactService.selectedContactStream,
              builder: (context, snapshot) {
                List<AtContact?>? selectedContacts = snapshot.data;

                return ListView.builder(
                    itemCount: selectedContacts!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (selectedContacts.isEmpty) {
                        return const Text('No Contacts');
                      }

                      return GestureDetector(
                        onTap: () {
                          _handleSendDudeToContact(
                              dude, selectedContacts[index]!.atSign!);
                        },
                        child: CircularContacts(
                          contact: selectedContacts[index],
                          onCrossPressed: () {},
                        ),
                      );
                    });
              }),
        ),
      ],
    );
  }
}
