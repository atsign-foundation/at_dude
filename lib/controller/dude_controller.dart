import 'dart:developer';

import 'package:at_contact/at_contact.dart';
import 'package:flutter/material.dart';

import '../models/dude_model.dart';
import '../services/dude_service.dart';
import '../services/shared_preferences_service.dart';
import '../widgets/widgets.dart';

/// A Dude class that controls the UI update when the [DudeService] methods are called.
class DudeController with ChangeNotifier {
  List<DudeModel> _dudes = [];

  List<DudeModel> get dudes {
    _dudes.sort((a, b) => b.timeSent.compareTo(a.timeSent));

    return _dudes;
  }

  Future<void> get sentDudes async {
    _dudes = await DudeService.getInstance().getDudes();
    _dudes = _dudes.where((element) => element.isSender!).toList();

    notifyListeners();
  }

  Future<void> get receivedDudes async {
    _dudes = await DudeService.getInstance().getDudes();
    _dudes = _dudes.where((element) => !element.isSender!).toList();

    notifyListeners();
  }

  /// Get dudes sent to the current astign.
  Future<void> getDudes() async {
    _dudes = await DudeService.getInstance().getDudes();

    notifyListeners();
  }

  List<AtContact> _contacts = [];

  List<AtContact> get contacts {
    return [..._contacts];
  }

  int get dudeCount => dudes.length;

  Future<int> get dudeReadCount async {
    var readCount = 0;
    for (var dude in dudes) {
      var dudeReadStatus = await SharedPreferencesService.getDudeReadStatus(dude);
      if (dudeReadStatus) {
        readCount++;
      }
    }
    log('dude count is ${dudes.length}');
    log('read count is $readCount');
    return dudes.length - readCount;
  }

  /// Get contacts for the current atsign.
  Future<void> getContacts() async {
    _contacts = await DudeService.getInstance().getContactList() ?? [];
    notifyListeners();
  }

  /// Deletes dudes sent to the current atsign.
  ///
  Future<void> deleteDude(DudeModel dude) async {
    bool result = await DudeService.getInstance().deleteDude(dude);
    result ? _dudes = await DudeService.getInstance().getDudes() : null;
    notifyListeners();
  }

  Future<void> deleteContact(String atSign) async {
    bool result = await DudeService.getInstance().deleteContact(atSign);
    result ? await getContacts() : SnackBars.errorSnackBar(content: 'Contact not deleted');
    notifyListeners();
  }

  Future<bool> deleteAllData() async {
    bool result = await DudeService.getInstance().deleteAllData();
    result ? await getDudes() : SnackBars.errorSnackBar(content: 'All data not deleted');
    notifyListeners();

    return result;
  }

  Future<void> updateReadDudeCount(DudeModel dudeModel) async {
    await SharedPreferencesService.setDudeReadStatus(dudeModel);
    await dudeReadCount;
    notifyListeners();
  }
}
