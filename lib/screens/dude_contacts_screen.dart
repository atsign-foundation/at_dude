import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:async';

import '../controller/controller.dart';
import '../services/shared_preferences_service.dart';
import '../widgets/widgets.dart';

import 'package:at_contact/at_contact.dart';

import 'package:at_common_flutter/at_common_flutter.dart';

import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';

import 'package:at_contacts_flutter/widgets/bottom_sheet.dart';

import 'package:at_contacts_flutter/widgets/custom_search_field.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:at_contacts_flutter/widgets/horizontal_list_view.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

/// The screen which is exposed from the library for displaying, adding, selecting and deleting Contacts.
class DudeContactsScreen extends StatefulWidget {
  /// takes in @param [context] to get the app context
  final BuildContext? context;

  /// a callback function to return back the selected list from the screen to the app
  final ValueChanged<List<AtContact?>>? selectedList;

  /// toggles between the selection type screen to display the contacts
  final bool asSelectionScreen;
  final bool asSingleSelectionScreen;
  final Function? saveGroup, onSendIconPressed;
  final Function showFavoriteContactTutorial;

  const DudeContactsScreen(
      {Key? key,
      this.selectedList,
      @Deprecated('context is no longer required and will be removed in upcoming version')
          this.context,
      this.asSelectionScreen = false,
      this.asSingleSelectionScreen = false,
      this.saveGroup,
      this.onSendIconPressed,
      required this.showFavoriteContactTutorial})
      : super(key: key);
  @override
  _DudeContactsScreenState createState() => _DudeContactsScreenState();
}

class _DudeContactsScreenState extends State<DudeContactsScreen> {
  /// search text entered in the search bar
  String searchText = '';

  /// reference to singleton instance of contact service
  ContactService? _contactService;

  /// boolean flag to indicate deletion action in progress
  bool deletingContact = false;

  /// boolean flag to indicate blocking action in progress
  bool blockingContact = false;

  /// boolean flag to indicate marking favorite action in progress
  bool markingFavoriteContact = false;

  /// boolean flag to indicate error condition
  bool errorOcurred = false;
  GlobalKey addContactKey = GlobalKey();
  GlobalKey listTileKey = GlobalKey();
  GlobalKey sendDudeContactKey = GlobalKey();
  List<GlobalKey<State<StatefulWidget>>> showcaseList = [];

  /// List of selected contacts
  List<AtContact?> selectedList = [];
  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var _result = await _contactService!.fetchContacts();
      if (_result == null) {
        if (mounted) {
          setState(() {
            errorOcurred = true;
          });
        }
      }
      final addContactStatus =
          await SharedPreferencesService.getAddContactStatus();
      addContactStatus ? showcaseList.add(addContactKey) : null;

      showcaseList.isNotEmpty
          ? ShowCaseWidget.of(context)!.startShowCase(showcaseList)
          : null;

      showcaseList.contains(addContactKey)
          ? await SharedPreferencesService.setContactStatus()
          : null;
    });

    super.initState();
  }

  Future<void> showContactTutorial() async {
    if (context.read<ContactsController>().contacts.length == 1) {
      showcaseList.clear();

      final listTileStatus = await SharedPreferencesService.getListTileStatus();

      final sendDudeContactStatus =
          await SharedPreferencesService.getSendDudeContactStatus();

      listTileStatus ? showcaseList.add(listTileKey) : null;
      sendDudeContactStatus ? showcaseList.add(sendDudeContactKey) : null;

      showcaseList.isNotEmpty
          ? ShowCaseWidget.of(context)!.startShowCase(showcaseList)
          : null;

      showcaseList.contains(listTileKey)
          ? await SharedPreferencesService.setListTileStatus()
          : null;

      showcaseList.contains(listTileKey)
          ? await SharedPreferencesService.setSendDudeContactStatus()
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      bottomSheet: (widget.asSelectionScreen)
          ? (widget.asSingleSelectionScreen)
              ? Container(height: 0)
              : CustomBottomSheet(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.saveGroup != null) {
                      ContactService().clearAtSigns();
                    }
                  },
                  selectedList: (List<AtContact?>? s) {
                    if (widget.selectedList != null) {
                      widget.selectedList!(s!);
                    }
                    if (widget.saveGroup != null) {
                      widget.saveGroup!();
                    }
                  },
                )
          : Container(
              height: 0,
            ),
      appBar: CustomAppBar(
        showBackButton: true,
        showTitle: true,
        showLeadingIcon: true,
        titleText: TextStrings().contacts,
        onLeadingIconPressed: () {
          setState(() {
            if (widget.asSelectionScreen) {
              ContactService().clearAtSigns();
              selectedList = [];
              if (widget.selectedList != null) {
                widget.selectedList!(selectedList);
              }
            }
          });
        },
        onTrailingIconPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const DudeAddContactDialog(),
          );

          await showContactTutorial();
        },
        // ignore: unnecessary_null_comparison
        showTrailingIcon: widget.asSelectionScreen == null ||
                widget.asSelectionScreen == false
            ? true
            : false,
        trailingIcon: Center(
          child: Showcase(
            key: addContactKey,
            description: "press this icon to add a contact",
            child: const Icon(
              Icons.add,
              color: ColorConstants.fontPrimary,
            ),
          ),
        ),
      ),
      body: errorOcurred
          ? const ErrorScreen()
          : Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.toWidth, vertical: 16.toHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ContactSearchField(
                    TextStrings().searchContact,
                    (text) => setState(() {
                      searchText = text;
                    }),
                  ),
                  SizedBox(
                    height: 15.toHeight,
                  ),
                  (widget.asSelectionScreen)
                      ? (widget.asSingleSelectionScreen)
                          ? Container()
                          : const HorizontalCircularList()
                      : Container(),
                  Expanded(
                      child: StreamBuilder<List<BaseContact?>>(
                    stream: _contactService!.contactStream,
                    initialData: _contactService!.baseContactList,
                    builder: (context, snapshot) {
                      if ((snapshot.connectionState ==
                          ConnectionState.waiting)) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if ((snapshot.data == null || snapshot.data!.isEmpty)) {
                          return Center(
                            child: Text(TextStrings().noContacts),
                          );
                        } else {
                          var _filteredList = <BaseContact?>[];
                          for (var c in snapshot.data!) {
                            if (c!.contact!.atSign!
                                .toUpperCase()
                                .contains(searchText.toUpperCase())) {
                              _filteredList.add(c);
                            }
                          }

                          if (_filteredList.isEmpty) {
                            return Center(
                              child: Text(TextStrings().noContactsFound),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.toHeight),
                            itemCount: 27,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, alphabetIndex) {
                              var contactsForAlphabet = <AtContact?>[];
                              var currentChar =
                                  String.fromCharCode(alphabetIndex + 65)
                                      .toUpperCase();
                              if (alphabetIndex == 26) {
                                currentChar = 'Others';
                                for (var c in _filteredList) {
                                  if (!RegExp(r'^[a-z]+$').hasMatch(
                                    c!.contact!.atSign![1].toLowerCase(),
                                  )) {
                                    contactsForAlphabet.add(c.contact!);
                                  }
                                }
                              } else {
                                for (var c in _filteredList) {
                                  if (c!.contact!.atSign![1].toUpperCase() ==
                                      currentChar) {
                                    contactsForAlphabet.add(c.contact!);
                                  }
                                }
                              }

                              if (contactsForAlphabet.isEmpty) {
                                return Container();
                              }
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        currentChar,
                                        style: TextStyle(
                                          color: ColorConstants.blueText,
                                          fontSize: 16.toFont,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4.toWidth),
                                      Expanded(
                                        child: Divider(
                                          color: ColorConstants.dividerColor
                                              .withOpacity(0.2),
                                          height: 1.toHeight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  contactListBuilder(contactsForAlphabet),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  ))
                ],
              ),
            ),
    );
  }

  Widget contactListBuilder(List<AtContact?> contactsForAlphabet) {
    return ListView.separated(
        itemCount: contactsForAlphabet.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, _) => Divider(
              color: ColorConstants.dividerColor.withOpacity(0.2),
              height: 1.toHeight,
            ),
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              // child: context.read<ContactsController>().contacts.length == 1
              //     ?
              child: Showcase(
                key: context.read<ContactsController>().contacts.length == 1
                    ? listTileKey
                    : GlobalKey(),
                description: "Slide left for more options",
                child: Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: TextStrings().block,
                      color: ColorConstants.inputFieldColor,
                      icon: Icons.block,
                      onTap: () async {
                        blockUnblockContact(contactsForAlphabet[index]!);
                      },
                    ),
                    IconSlideAction(
                      caption: 'Favorite',
                      color: ColorConstants.inputFieldColor,
                      icon: contactsForAlphabet[index]!.favourite!
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      onTap: () async {
                        await markUnmarkFavoriteContact(
                            contactsForAlphabet[index]!);
                        await widget.showFavoriteContactTutorial();
                        Navigator.pop(context);
                      },
                    ),
                    IconSlideAction(
                      caption: TextStrings().delete,
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        deleteContact(contactsForAlphabet[index]!);
                      },
                    ),
                  ],
                  child: ContactListTile(
                    showcaseKey: sendDudeContactKey,
                    key: UniqueKey(),
                    contactService: _contactService,
                    asSelectionTile: widget.asSelectionScreen,
                    asSingleSelectionTile: widget.asSingleSelectionScreen,
                    contact: contactsForAlphabet[index],
                    selectedList: (s) {
                      selectedList = s!;
                      if (widget.selectedList != null) {
                        widget.selectedList!(selectedList);
                      }
                    },
                    onTrailingPressed: widget.onSendIconPressed,
                  ),
                ),
              ));
        });
  }

  blockUnblockContact(AtContact contact) async {
    setState(() {
      blockingContact = true;
    });

    // ignore: unawaited_futures
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().blockContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    await _contactService!
        .blockUnblockContact(contact: contact, blockAction: true);
    setState(() {
      blockingContact = false;
      Navigator.pop(context);
    });
  }

  deleteContact(AtContact contact) async {
    setState(() {
      deletingContact = true;
    });

    // ignore: unawaited_futures
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().deleteContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    await _contactService!.deleteAtSign(atSign: contact.atSign!);
    setState(() {
      deletingContact = false;
      Navigator.pop(context);
    });
  }

  Future<void> markUnmarkFavoriteContact(AtContact contact) async {
    setState(() {
      markingFavoriteContact = true;
    });

    unawaited(showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text('Marking Favorite'),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ));
    await context.read<ContactsController>().markUnmarkFavorites(contact);

    setState(() {
      markingFavoriteContact = false;
      Navigator.pop(context);
    });
  }
}
