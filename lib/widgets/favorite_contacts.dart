import 'package:flutter/material.dart';

// import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
// import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/controller.dart';

import '../models/models.dart';
import '../screens/screens.dart';
import '../services/services.dart';
import 'widgets.dart';

class FavoriteContacts extends StatefulWidget {
  final DudeModel dude;
  final Function updateIsLoading;
  final GlobalKey favoriteContactKey;
  const FavoriteContacts(
      {required this.dude,
      required this.updateIsLoading,
      required this.favoriteContactKey,
      Key? key})
      : super(key: key);

  @override
  State<FavoriteContacts> createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await context.read<ContactsController>().getFavoriteContacts();
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
                'Favorite',
                style: Theme.of(context).textTheme.headline2,
              ),
              // IconButton(
              //     onPressed: () => Navigator.push(
              //           context,
              //           MaterialPageRoute<void>(
              //               builder: (BuildContext context) =>
              //                   const DudeContactsScreen(),
              //               fullscreenDialog: true),
              //         ),
              //     icon: const Icon(Icons.favorite))
            ],
          ),
          Consumer<ContactsController>(
            builder: (context, contactsController, child) => Flexible(
              child: contactsController.favoriteContacts.isEmpty
                  ? const Text('No Contacts Available')
                  : ListView.builder(
                      itemCount: contactsController.favoriteContacts.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (contactsController.favoriteContacts.isEmpty) {
                          return const Text('No Contacts Available');
                        } else {
                          return GestureDetector(
                            onTap: () {
                              if (widget.dude.dude.isEmpty) {
                                SnackBars.notificationSnackBar(
                                    content: 'Create dude first',
                                    context: context);
                              } else {
                                _handleSendDudeToContact(
                                    dude: widget.dude,
                                    contactAtsign: contactsController
                                        .favoriteContacts[index].atSign!,
                                    context: context);
                              }
                            },
                            child: Showcase(
                              key: true
                                  ? widget.favoriteContactKey
                                  : GlobalKey(),
                              description: 'Press to send dude to this contact',
                              child: CircularContacts(
                                size: 50,
                                isCrossIcon: true,
                                contact:
                                    contactsController.favoriteContacts[index],
                                onCrossPressed: () async {
                                  await contactsController.markUnmarkFavorites(
                                      contactsController
                                          .favoriteContacts[index]);
                                },
                              ),
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
