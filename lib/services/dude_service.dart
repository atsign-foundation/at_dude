import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_dude/models/dude_model.dart';

import '../main.dart';

// DudeService d = DudeService.getInstance();
// d.atClient;

class DudeService {
  static DudeService _singleton = DudeService._internal();
  DudeService._internal();
  factory DudeService.getInstance() {
    return _singleton;
  }
  AtClient? atClient;
  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();
  Future<void> putDude(DudeModel dude, String contactAtsign) async {
    dude.saveSender(atClient!.getCurrentAtSign()!);
    dude.saveReceiver(contactAtsign);
    dude.saveId();
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true;

    var key = AtKey()
      ..key = dude.id
      ..sharedBy = dude.sender
      ..sharedWith = dude.receiver
      ..metadata = metaData
      ..namespace = '';

    dude.saveTimeSent();

    bool _putData = await atClient!.put(
      key,
      json.encode(dude.toJson()),
    );
    atClientManager.syncService.sync();
    print('Key dude sent is: ' + dude.dude);
    print('Key updated $_putData');
  }

  Future<List<DudeModel>> getDudes() async {
    // var metaData = Metadata()
    //   ..isEncrypted = true
    //   ..namespaceAware = true;

// [key1.namespace@atsign,key2.namespace@atsign,key2.namespace@atsign]
    List<AtKey> keysList = await atClient!.getAtKeys(
      regex: 'at_skeleton_app',
      sharedBy: atClient!.getCurrentAtSign(),
    );
    // atClientManager.syncService.sync();
    List<DudeModel> dudes = [];
    for (var key in keysList) {
      AtValue _keyValue = await atClient!.get(key);

      dudes.add(DudeModel.fromJson(jsonDecode(_keyValue.value)));
    }

    return dudes;
  }
}
