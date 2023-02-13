import 'dart:async';
import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../dude_theme.dart';
import '../screens/screens.dart';
import '../services/shared_preferences_service.dart';

class CustomContactListTile extends StatefulWidget {
  final Function? onTap;
  final Function? onTrailingPressed;
  final bool asSelectionTile;
  final bool asSingleSelectionTile;
  final AtContact contact;
  final ContactService contactService;
  final ValueChanged<List<AtContact?>?>? selectedList;

  const CustomContactListTile({
    Key? key,
    this.onTap,
    this.onTrailingPressed,
    this.asSelectionTile = false,
    this.asSingleSelectionTile = false,
    required this.contact,
    required this.contactService,
    this.selectedList,
  }) : super(key: key);

  @override
  _CustomContactListTileState createState() => _CustomContactListTileState();
}

class _CustomContactListTileState extends State<CustomContactListTile> {
  final AtSignLogger _logger = AtSignLogger('Custom List Tile');
  bool isSelected = false;

  /// boolean flag to indicate marking favorite action in progress
  bool markingFavoriteContact = false;

  Future<void> markUnmarkFavoriteContact(AtContact contact) async {
    setState(() {
      markingFavoriteContact = true;
    });

    // if (markingFavoriteContact) {
    //   unawaited(showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Center(
    //         child: Text('Marking Favorite'),
    //       ),
    //       content: SizedBox(
    //         height: 100.toHeight,
    //         child: const Center(
    //           child: CircularProgressIndicator(),
    //         ),
    //       ),
    //     ),
    //   ));
    // }
    await context.read<ContactsController>().markUnmarkFavorites(contact);

    setState(() {
      markingFavoriteContact = false;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget contactImage;
    if (widget.contact.tags != null && widget.contact.tags!['image'] != null) {
      Uint8List? image;
      try {
        List<int> intList = widget.contact.tags!['image'].cast<int>();
        image = Uint8List.fromList(intList);
      } catch (e) {
        _logger.severe('Error in image: $e');
      }

      contactImage = image != null
          ? CustomCircleAvatar(
              byteImage: image,
              nonAsset: true,
            )
          : ContactInitial(
              initials: widget.contact.atSign!,
            );
    } else {
      contactImage = ContactInitial(
        initials: widget.contact.atSign!,
      );
    }
    return StreamBuilder<List<AtContact?>>(
        initialData: widget.contactService.selectedContacts,
        stream: widget.contactService.selectedContactStream,
        builder: (context, snapshot) {
          // ignore: omit_local_variable_types
          for (AtContact? contact in widget.contactService.selectedContacts) {
            if (contact == widget.contact ||
                contact!.atSign == widget.contact.atSign) {
              isSelected = true;
              break;
            } else {
              isSelected = false;
            }
          }
          if (widget.contactService.selectedContacts.isEmpty) {
            isSelected = false;
          }
          return ListTile(
            onTap: () {
              Navigator.popAndPushNamed(context, SendDudeScreen.routeName,
                  arguments: widget.contact);
              if (widget.asSelectionTile) {
                setState(() {
                  if (isSelected) {
                    widget.contactService.removeSelectedAtSign(widget.contact);
                  } else {
                    if (widget.asSingleSelectionTile) {
                      widget.contactService.clearAtSigns();
                      Navigator.pop(context);
                    }
                    widget.contactService.selectAtSign(widget.contact);
                  }
                  isSelected = !isSelected;
                });

                widget.selectedList!(widget.contactService.selectedContacts);
              } else {
                if (widget.onTap != null) {
                  widget.onTap!();
                }
              }
            },
            title: Text(
              (widget.contact.tags != null &&
                      widget.contact.tags!['nickname'] != null
                  ? '${widget.contact.tags!['nickname']} (${widget.contact.atSign!})'
                  : widget.contact.atSign!),
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 14.toFont,
                fontWeight: FontWeight.normal,
              ),
            ),
            subtitle: Text(
              widget.contact.tags != null &&
                      widget.contact.tags!['name'] != null
                  ? widget.contact.tags!['name']
                  : widget.contact.atSign!.substring(1),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.toFont,
                fontWeight: FontWeight.normal,
              ),
            ),
            leading: Container(
                height: 40.toHeight,
                width: 40.toHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: contactImage),
            trailing: IconButton(
              onPressed: widget.asSelectionTile
                  ? null
                  : () async {
                      await markUnmarkFavoriteContact(widget.contact);
                      final bool sendDudeFavoriteContactStatus =
                          await SharedPreferencesService
                              .getSendDudeToFavoriteStatus();
                      if (sendDudeFavoriteContactStatus) {
                        Navigator.pop(context);
                      }
                      // await widget.showFavoriteContactTutorial();

                      if (widget.onTrailingPressed != null) {
                        widget.onTrailingPressed!(widget.contact.atSign);
                      }
                    },
              icon: (widget.asSelectionTile)
                  ? (isSelected)
                      ? const Icon(Icons.close)
                      : const Icon(Icons.add)
                  : widget.contact.favourite!
                      ? const Icon(
                          Icons.star_rounded,
                          color: kPrimaryColor,
                        )
                      : const Icon(
                          Icons.star_border_rounded,
                          color: kPrimaryColor,
                        ),
            ),
          );
        });
  }
}
