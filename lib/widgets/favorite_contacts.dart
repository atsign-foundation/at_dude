import 'package:flutter/material.dart';

// import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'add_contact.dart';
import 'widgets.dart';

class FavoriteContacts extends StatefulWidget {
  final DudeModel dude;
  final Function updateIsLoading;
  const FavoriteContacts(
      {required this.dude, required this.updateIsLoading, Key? key})
      : super(key: key);

  @override
  State<FavoriteContacts> createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await context.read<ContactsController>().getContacts();
      await DudeService.getInstance().getCurrentAtsignProfileImage();
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  /// Sends dude to selected contact
  Future<void> _handleSendDudeToContact(
      {required DudeModel dude,
      required String contactAtsign,
      required BuildContext context}) async {
    widget.updateIsLoading(true);
    await DudeService.getInstance()
        .putDude(dude, contactAtsign, context)
        .then((value) {
      if (value) {
        widget.updateIsLoading(false);
        SnackBars.notificationSnackBar(
            content: 'Dude successfully sent', context: context);
      } else {
        widget.updateIsLoading(false);
        SnackBars.errorSnackBar(
            content: 'Something went wrong, please try again',
            context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
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
                  onPressed: () async => await showDialog(
                        context: context,
                        builder: (context) => const AddContactDialog(),
                      ),
                  icon: const Icon(Icons.add))
            ],
          ),
          Consumer<ContactsController>(
            builder: (context, contactsController, child) => Flexible(
              child: contactsController.contacts.isEmpty
                  ? const Text('No Contacts Available')
                  : ListView.builder(
                      itemCount: contactsController.contacts.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (contactsController.contacts.isEmpty) {
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
                                    contactAtsign: contactsController
                                        .contacts[index].atSign!,
                                    context: context);
                              }
                            },
                            child: CircularContacts(
                              contact: contactsController.contacts[index],
                              onCrossPressed: () async {
                                await contactsController.deleteContact(
                                    contactsController.contacts[index].atSign!);
                              },
                            ),
                          );
                        }
                      }),
            ),
          ),
        ],
      ),
    );
  }
}
