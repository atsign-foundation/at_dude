import 'dart:developer';

import 'package:at_contact/at_contact.dart';
import 'package:flutter/material.dart';

import '../services/contact_service.dart';
import '../widgets/widgets.dart';

/// A Dude class that controls the UI update when the [ContactsService] methods are called.
class ContactsController with ChangeNotifier {
  List<AtContact> _contacts = [];

  List<AtContact> get contacts {
    return [..._contacts];
  }

  List<AtContact> _favoriteContacts = [];
  List<AtContact> get favoriteContacts {
    return _favoriteContacts;
  }

  /// Get contacts for the current atsign.
  Future<void> getContacts() async {
    _contacts = await ContactsService.getInstance().getContactList() ?? [];
    for (var element in _contacts) {
      log('contacts are ${element.atSign.toString()}');
    }
    notifyListeners();
  }

  Future<void> deleteContact(String atSign) async {
    bool result = await ContactsService.getInstance().deleteContact(atSign);
    result
        ? await getContacts()
        : SnackBars.errorSnackBar(
            content: 'Contact not deleted',
          );
    notifyListeners();
  }

  /// Get favorite contacts for the current atsign.
  Future<void> getFavoriteContacts() async {
    await getContacts();
    _favoriteContacts = _contacts.where((contact) => contact.favourite == true).toList();
    notifyListeners();
  }

  Future<void> addContacts(String atSign, String? nickname) async {
    bool result = await ContactsService.getInstance().addContact(atSign, nickname);
    result
        ? await getContacts()
        : SnackBars.errorSnackBar(
            content: 'Error adding atsign, atsign does no exist',
          );
    notifyListeners();
  }

  /// Mark AtContact favourite property as true or false
  Future<void> markUnmarkFavorites(AtContact contact) async {
    bool result = await ContactsService.getInstance().markUnmarkFavoriteContact(contact);
    result ? await getFavoriteContacts() : SnackBars.errorSnackBar(content: 'Error adding atsign, atsign may no exist');
    notifyListeners();
  }
}
