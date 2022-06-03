import 'package:flutter/material.dart';

import 'package:at_contact/at_contact.dart';
import '../services/contact_service.dart';

import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

/// A Dude class that controls the UI update when the [ContactsService] methods are called.
class ContactsController with ChangeNotifier {
  List<AtContact> _contacts = [];

  List<AtContact> get contacts {
    return [..._contacts];
  }

  /// Get contacts for the current atsign.
  Future<void> getContacts() async {
    _contacts = await ContactsService.getInstance().getContactList() ?? [];
    notifyListeners();
  }

  Future<void> deleteContact(String atSign) async {
    bool result = await ContactsService.getInstance().deleteContact(atSign);
    result
        ? await getContacts()
        : SnackBars.errorSnackBar(
            content: 'Contact not deleted',
            context: NavigationService.navKey.currentContext!);
    notifyListeners();
  }

  Future<void> addContacts(String atSign) async {
    bool result = await ContactsService.getInstance().addContact(atSign);
    result
        ? await getContacts()
        : SnackBars.errorSnackBar(
            content: 'Error adding atsign, atsign may no exist',
            context: NavigationService.navKey.currentContext!);
    notifyListeners();
  }
}
