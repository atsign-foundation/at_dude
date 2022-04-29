import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/services/dude_service.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

/// A Dude class that controls the UI update when the [DudeService] methods are called.
class DudeController with ChangeNotifier {
  List<DudeModel> _dudes = [];

  List<DudeModel> get dudes {
    _dudes.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    return [..._dudes];
  }

  /// Get dudes sent to the current astign.
  void getDudes() async {
    _dudes = await DudeService.getInstance().getDudes();
    notifyListeners();
  }

  List<AtContact> _contacts = [];

  List<AtContact> get contacts {
    return [..._contacts];
  }

  /// Get contacts for the current atsign.
  void getContacts() async {
    _contacts = await DudeService.getInstance().getContactList() ?? [];
  }

  /// Deletes dudes sent to the current atsign.
  ///
  void deleteDude(DudeModel dude) async {
    bool result = await DudeService.getInstance().deleteDude(dude);
    result ? _dudes = await DudeService.getInstance().getDudes() : null;
    notifyListeners();
  }
}
