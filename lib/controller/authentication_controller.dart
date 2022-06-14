import 'package:flutter/material.dart';

import 'package:at_contact/at_contact.dart';
import '../services/contact_service.dart';

import '../services/services.dart';

/// A Dude class that controls the UI update when the [ContactsService] methods are called.
class AuthenticationController with ChangeNotifier {
  List<String> _atSignList = [];

  List<String> get atsignList {
    return [..._atSignList];
  }

  /// Get contacts for the current atsign.
  Future<void> getAtSignList() async {
    _atSignList =
        await AuthenticationService.getInstance().getAtsignList() ?? [];
    notifyListeners();
  }

  Future<AtContact> getAtContact(String atSign) async {
    return await AuthenticationService.getInstance().getAtContact(atSign);
  }
}
