import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/controller.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
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
    super.initState();
    Future.delayed(Duration.zero, () async {
      await context.read<ContactsController>().getFavoriteContacts();
      await DudeService.getInstance().getCurrentAtsignProfileImage();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Sends dude to selected contact
  Future<void> _handleSendDudeToContact({
    required DudeModel dude,
    required String contactAtsign,
  }) async {
    widget.updateIsLoading(true);
    await DudeService.getInstance().putDude(dude, contactAtsign).then((value) {
      if (value) {
        widget.updateIsLoading(false);
        SnackBars.notificationSnackBar(content: 'Dude successfully sent');
      } else {
        widget.updateIsLoading(false);
        SnackBars.errorSnackBar(
            content: 'Something went wrong, please try again');
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
                Texts.favoritesContactWidgetTitle,
                style: Theme.of(context).textTheme.headline2,
              ),
            ],
          ),
          Consumer<ContactsController>(
            builder: (context, contactsController, child) => Flexible(
              child: contactsController.favoriteContacts.isEmpty
                  ? const Text(Texts.noContactsAvailable)
                  : ListView.builder(
                      itemCount: contactsController.favoriteContacts.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (contactsController.favoriteContacts.isEmpty) {
                          return const Text('No Contacts Available');
                        } else {
                          return GestureDetector(
                            onTap: () {
                              if (widget.dude.selectedDudeType != null) {
                                SnackBars.notificationSnackBar(
                                    content: Texts.createDudeFirst);
                              } else {
                                _handleSendDudeToContact(
                                    dude: widget.dude,
                                    contactAtsign: contactsController
                                        .favoriteContacts[index].atSign!);
                              }
                            },
                            child: Showcase(
                              key: context
                                          .read<ContactsController>()
                                          .favoriteContacts
                                          .length ==
                                      1
                                  ? widget.favoriteContactKey
                                  : GlobalKey(),
                              description: Texts.sendDudeContactDesc,
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
