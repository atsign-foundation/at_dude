import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/widgets/bottom_sheet.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:at_contacts_flutter/widgets/horizontal_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:showcaseview/showcaseview.dart';

import '../dude_theme.dart';
import '../services/shared_preferences_service.dart';
import '../utils/utils.dart';
import '../widgets/contact_search_field.dart';
import '../widgets/contacts_icon.dart';
import '../widgets/tip_card.dart';
import '../widgets/widgets.dart';

/// The screen which is exposed from the library for displaying, adding, selecting and deleting Contacts.
class DudeContactsScreen extends StatefulWidget {
  static String routeName = 'dudeContactScreen';

  /// takes in @param [context] to get the app context
  final BuildContext? context;

  /// a callback function to return back the selected list from the screen to the app
  final ValueChanged<List<AtContact?>>? selectedList;

  /// toggles between the selection type screen to display the contacts
  final bool asSelectionScreen;
  final bool asSingleSelectionScreen;
  final Function? saveGroup, onSendIconPressed;

  /// to show already selected contacts.
  final List<AtContact>? selectedContactsHistory;

  const DudeContactsScreen(
      {Key? key,
      this.selectedList,
      @Deprecated('context is no longer required and will be removed in upcoming version') this.context,
      this.asSelectionScreen = false,
      this.asSingleSelectionScreen = false,
      this.saveGroup,
      this.onSendIconPressed,
      this.selectedContactsHistory})
      : super(key: key);
  @override
  _DudeContactsScreenState createState() => _DudeContactsScreenState();
}

class _DudeContactsScreenState extends State<DudeContactsScreen> {
  /// search text entered in the search bar
  String searchText = '';

  /// reference to singleton instance of contact service
  late ContactService _contactService;

  /// boolean flag to indicate deletion action in progress
  bool deletingContact = false;

  /// boolean flag to indicate blocking action in progress
  bool blockingContact = false;

  /// boolean flag to indicate error condition
  bool errorOcurred = false;

  /// bool flag to indicate favorite atsign only
  bool isFavoriteActive = false;

  GlobalKey addContactKey = GlobalKey();
  GlobalKey filterFavoriteKey = GlobalKey();
  List<GlobalKey<State<StatefulWidget>>> showcaseList = [];

  /// List of selected contacts
  List<AtContact?> selectedList = [];

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        var _result = await _contactService.fetchContacts();
        if (_result == null) {
          if (mounted) {
            setState(() {
              errorOcurred = true;
            });
          }
        }

        if (widget.selectedContactsHistory != null) {
          _contactService.selectedContacts = widget.selectedContactsHistory!;
          _contactService.selectedContactSink.add(_contactService.selectedContacts);
        }

        final addContactStatus = await SharedPreferencesService.getAddContactStatus();
        if (addContactStatus) showcaseList.add(addContactKey);

        final filterFavoriteStatus = await SharedPreferencesService.getFilterFavoriteStatus();
        if (filterFavoriteStatus) showcaseList.add(filterFavoriteKey);

        if (showcaseList.isNotEmpty) {
          ShowCaseWidget.of(context).startShowCase(showcaseList);
        }

        if (showcaseList.contains(addContactKey)) {
          await SharedPreferencesService.setContactStatus();
        }

        if (showcaseList.contains(filterFavoriteKey)) {
          await SharedPreferencesService.setFilterFavoriteStatus();
        }
      },
    );

    super.initState();
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
        extendBody: true,
        extendBodyBehindAppBar: true,
        // bottomNavigationBar: const DudeBottomNavigationBar(selectedIndex: 0),
        body: errorOcurred
            ? const ErrorScreen()
            : GestureDetector(
                onTap: (() => FocusManager.instance.primaryFocus?.unfocus()),
                child: Stack(children: [
                  const AppBackground(alignment: Alignment.bottomRight),
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.toWidth, vertical: 16.toHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: ContactSearchField(
                                  TextStrings().searchContact,
                                  (text) => setState(() {
                                    searchText = text;
                                  }),
                                ),
                              ),
                              Flexible(
                                child: Showcase(
                                  key: filterFavoriteKey,
                                  description: Texts.filterFavoriteIconDesc,
                                  child: ContactsIcon(
                                    title: Texts.filterFavs,
                                    icon: Icons.star_border_rounded,
                                    onPress: () {
                                      setState(() {
                                        isFavoriteActive = !isFavoriteActive;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Showcase(
                                  key: addContactKey,
                                  description: Texts.addContactIconDesc,
                                  child: ContactsIcon(
                                      title: Texts.addNew,
                                      icon: Icons.add,
                                      onPress: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => const DudeAddContactDialog(),
                                        );
                                      }),
                                ),
                              )
                            ],
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
                            stream: _contactService.contactStream,
                            initialData: _contactService.baseContactList,
                            builder: (context, snapshot) {
                              if ((snapshot.connectionState == ConnectionState.waiting)) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                if ((snapshot.data == null || snapshot.data!.isEmpty)) {
                                  return const Center(
                                    child: Text(Texts.noContactsAvailable),
                                  );
                                } else {
                                  var _filteredList = <BaseContact?>[];
                                  for (var c in snapshot.data!) {
                                    if (c!.contact!.atSign!.toUpperCase().contains(searchText.toUpperCase())) {
                                      _filteredList.add(c);
                                    }

                                    if (isFavoriteActive) {
                                      _filteredList.retainWhere((c) => c!.contact!.favourite!);
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
                                      var currentChar = String.fromCharCode(alphabetIndex + 65).toUpperCase();
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
                                          if (c!.contact!.atSign![1].toUpperCase() == currentChar) {
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
                                                  color: kPrimaryColor,
                                                  fontSize: 16.toFont,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 4.toWidth),
                                              const Expanded(
                                                child: Divider(
                                                  color: kPrimaryColor,
                                                  thickness: 1,
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
                          )),
                          const TipCard(
                            tip: 'Select a contact to send a dude to',
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ));
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
            child: Card(
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
                    caption: TextStrings().delete,
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () async {
                      deleteContact(contactsForAlphabet[index]!);
                    },
                  ),
                ],
                child: CustomContactListTile(
                  key: UniqueKey(),
                  contactService: _contactService,
                  asSelectionTile: widget.asSelectionScreen,
                  asSingleSelectionTile: widget.asSingleSelectionScreen,
                  contact: contactsForAlphabet[index]!,
                  selectedList: (s) {
                    selectedList = s!;
                    if (widget.selectedList != null) {
                      widget.selectedList!(selectedList);
                    }
                  },
                  onTrailingPressed: widget.onSendIconPressed,
                ),
              ),
            ),
          );
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
    await _contactService.blockUnblockContact(contact: contact, blockAction: true);
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
    await _contactService.deleteAtSign(atSign: contact.atSign!);
    setState(() {
      deletingContact = false;
      Navigator.pop(context);
    });
  }
}
