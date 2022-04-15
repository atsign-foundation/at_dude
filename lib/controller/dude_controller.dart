import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/services/dude_service.dart';
import 'package:flutter/material.dart';

class DudeController with ChangeNotifier {
  List<DudeModel> _dudes = [];

  List<DudeModel> get dudes {
    _dudes.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    return [..._dudes];
  }

  void getDudes() async {
    _dudes = await DudeService.getInstance().getDudes();
    notifyListeners();
  }

  void deleteDude(DudeModel dude) async {
    bool result = await DudeService.getInstance().deleteDude(dude);
    result ? _dudes = await DudeService.getInstance().getDudes() : null;
    notifyListeners();
  }
}
