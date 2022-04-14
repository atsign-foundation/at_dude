import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
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
            {required DudeModel dude,
            required String contactAtsign,
            required BuildContext context}) async =>
        DudeService.getInstance().putDude(dude, contactAtsign).then((value) {
          if (value) {
            SnackBars.notificationSnackBar(
                content: 'Dude successfully sent', context: context);
          } else {
            SnackBars.errorSnackBar(
                content: 'Something went wrong, please try again',
                context: context);
          }
        });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Favorite Dudes',
              style: Theme.of(context).textTheme.headline2,
            ),
            IconButton(
                onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const AddContactDialog(),
                    ),
                icon: const Icon(Icons.add))
          ],
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
                        return const Text('No Contacts Available');
                      } else {
                        return GestureDetector(
                          onTap: () {
                            if (widget.dude.dude.isEmpty) {
                              SnackBars.notificationSnackBar(
                                  content: 'No duuude to send',
                                  context: context);
                            } else {
                              _handleSendDudeToContact(
                                  dude: widget.dude,
                                  contactAtsign:
                                      selectedContacts![index]!.atSign!,
                                  context: context);
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
