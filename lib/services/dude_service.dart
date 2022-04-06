import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_dude/models/dude_model.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_dude/models/profile_model.dart';
import 'package:flutter/material.dart';
// DudeService d = DudeService.getInstance();
// d.atClient;

class DudeService {
  static final DudeService _singleton = DudeService._internal();
  DudeService._internal();
  factory DudeService.getInstance() {
    return _singleton;
  }

  AtClient? atClient;
  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();
  static var contactService = ContactService();

  Future<void> putDude(DudeModel dude, String contactAtsign) async {
    dude.saveSender(atClient!.getCurrentAtSign()!);
    dude.saveReceiver(contactAtsign);
    dude.saveId();
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var key = AtKey()
      ..key = dude.id
      ..sharedBy = dude.sender
      ..sharedWith = dude.receiver
      ..metadata = metaData
      ..namespace = '';

    dude.saveTimeSent();

    await atClient!.put(
      key,
      json.encode(dude.toJson()),
    );

    var profileMetaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var profileKey = AtKey()
      ..key = 'dude_profile_' + dude.sender.replaceFirst('@', '')
      ..sharedBy = dude.sender
      ..metadata = profileMetaData;

    try {
      AtValue profileAtValue = await atClient!.get(profileKey);
      ProfileModel profileModel =
          ProfileModel.fromJson(jsonDecode(profileAtValue.value));
      profileModel.saveId(dude.sender);
      profileModel.dudesSent += 1;
      profileModel.dudeHours += dude.duration;
      if (dude.duration > profileModel.longestDude) {
        profileModel.saveLongestDude(dude.duration);
      }
      await atClient!.put(
        profileKey,
        json.encode(
          profileModel.toJson(),
        ),
      );
    } catch (e) {
      // Exception should be thrown the first time a profile is created for an atsign
      await atClient!.put(
        profileKey,
        json.encode(
          ProfileModel(
                  id: dude.sender,
                  dudesSent: 1,
                  dudeHours: dude.duration,
                  longestDude: dude.duration)
              .toJson(),
        ),
      );
    }

    atClientManager.syncService.sync();
    print('sync successful');
  }

  Future<List<DudeModel>> getDudes() async {
    // try {
    //   atClientManager.syncService.setOnDone(() {
    //     print('Sync done in getDudes()');
    //   });
    //   atClientManager.syncService.sync(onDone: () {
    //     print('Sync done in getDudes()');
    //   });
    // } on Exception catch (e) {
    //   print('Sync failed with exception $e');
    // }
    String? currentAtSign = atClient!.getCurrentAtSign();
    // @blizzard30:some_uuid.at_skeleton_app@assault30
    // @blizzard30:signing_privatekey@blizzard30
    List<AtKey> keysList = await atClient!.getAtKeys(
      regex: 'at_skeleton_app',
      // sharedBy: currentAtSign,
      sharedWith: currentAtSign,
    );

    List<DudeModel> dudes = [];
    for (AtKey key in keysList) {
      try {
        if (key.sharedBy != null && key.sharedWith != null) {
          AtValue _keyValue = await atClient!.get(key);
          dudes.add(DudeModel.fromJson(jsonDecode(_keyValue.value)));
        }
      } on Exception catch (e) {
        ScaffoldMessenger(child: SnackBar(content: Text(e.toString())));
      }
    }
    // String? response = await atClientManager.atClient
    //     .getLocalSecondary()!
    //     .executeVerb(ScanVerbBuilder()
    //       ..auth = true
    //       ..regex = 'shared_key');
    // print('RESPONSE FROM SCAN VERB HANDLER : $response');
    return dudes;
  }

  // void getResponse() async {
  //   String? response = await atClientManager.atClient
  //       .getLocalSecondary()!
  //       .executeVerb(ScanVerbBuilder()
  //         ..auth = true
  //         ..regex = 'shared_key');
  //   print(response);
  // }

  Future<void> monitorNotifications() async {
    atClientManager.notificationService
        .subscribe(regex: 'at_skeleton_app')
        .listen((AtNotification notification) {
      // print('Notification key: ' + notification.key);
      // print('Notification value: ${notification.value}');
    });
  }

  Future<List<AtContact>?> getContactList() {
    return contactService.fetchContacts();
  }

  Future<Uint8List?> getCurrentAtsignProfileImage() async {
    return contactService
        .getContactDetails(atClient!.getCurrentAtSign(), null)
        .then((value) {
      return value['image'];
    });
  }

  Future<dynamic> getCurrentAtsignContactDetails() async {
    return contactService
        .getContactDetails(atClient!.getCurrentAtSign(), null)
        .then((value) {
      return value;
    });
  }

  Future<ProfileModel> getProfile() async {
    return await atClient!
        .getAtKeys(
          regex: 'dude_profile_',
          sharedBy: atClient!.getCurrentAtSign(),
        )
        .then(
          (value) => atClient!.get(value[0]).then(
                (value) => ProfileModel.fromJson(
                  jsonDecode(value.value),
                ),
              ),
        );
  }
}
