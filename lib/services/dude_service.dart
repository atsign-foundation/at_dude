// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_app_flutter/at_app_flutter.dart';
// ignore: implementation_imports
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_utils/at_utils.dart';
import 'package:flutter/material.dart';

import '../models/dude_model.dart';
import '../models/persona_model.dart';
import '../models/profile_model.dart';
import 'local_notification_service.dart';

/// A singleton that makes all the network calls to the @platform.
class DudeService {
  static final DudeService _singleton = DudeService._internal();
  DudeService._internal();

  factory DudeService.getInstance() {
    return _singleton;
  }
  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();

  static var contactService = ContactService();

  /// Saves Dude to the receiver's remote secondary and stats to the sender's local secondary.
  Future<bool> putDude(
    DudeModel dude,
    String contactAtsign,
    BuildContext context,
  ) async {
    bool isCompleted = false;
    dude.saveSender(atClientManager.atClient.getCurrentAtSign()!);
    dude.saveReceiver(contactAtsign);
    dude.saveId();
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..ttr = -1
      ..isPublic = false;

    var key = AtKey()
      ..key = dude.id
      ..sharedBy = dude.sender
      ..sharedWith = dude.receiver
      ..metadata = metaData
      ..namespace = '';

    dude.saveTimeSent();

    await atClientManager.notificationService.notify(
        NotificationParams.forUpdate(
          key,
          value: json.encode(dude.toJson()),
        ),
        onSuccess: (notification) async {});

    var profileMetaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var profileKey = AtKey()
      ..key = 'dude_profile_' + dude.sender.replaceFirst('@', '')
      ..sharedBy = dude.sender
      ..metadata = profileMetaData;

    try {
      AtValue profileAtValue = await atClientManager.atClient.get(profileKey);
      ProfileModel profileModel =
          ProfileModel.fromJson(jsonDecode(profileAtValue.value));
      profileModel.saveId(dude.sender);
      profileModel.dudesSent += 1;

      await atClientManager.atClient
          .put(
            profileKey,
            json.encode(
              profileModel.toJson(),
            ),
          )
          .whenComplete(() => isCompleted = true)
          .onError((error, stackTrace) => isCompleted = false);
    } catch (e) {
      // Exception should be thrown the first time a profile is created for an atsign
      await atClientManager.atClient
          .put(
            profileKey,
            json.encode(
              ProfileModel(
                id: dude.sender,
                dudesSent: 1,
              ).toJson(),
            ),
          )
          .whenComplete(() => isCompleted = true)
          .onError((error, stackTrace) => isCompleted = false);
    }
    return isCompleted;
  }

  /// Receives all dudes sent to the current atsign.
  Future<List<DudeModel>> getDudes() async {
    // String? currentAtSign = atClient!.getCurrentAtSign();
    // @blizzard30:some_uuid.at_skeleton_app@assault30
    // @blizzard30:signing_privatekey@blizzard30
    // List<String> sendersAtsignList = await getSenderAtsigns();
    // for (var atsign in sendersAtsignList) {
    //   atsign = atsign.replaceAll('@', '');
    // }
    List<AtKey> receivedKeysList = [];
    var key = await atClientManager.atClient.getAtKeys(
      regex: '^cached:.*@.+\$',
      // sharedBy: atsign,
    );

    receivedKeysList.addAll(key);

    List<DudeModel> dudes = [];
    for (AtKey key in receivedKeysList) {
      try {
        if (key.sharedBy != null && key.key!.length == 36) {
          AtValue _keyValue = await atClientManager.atClient.get(key);
          var model = DudeModel.fromJson(jsonDecode(_keyValue.value));
          model.createdAt = _keyValue.metadata!.createdAt;
          if (atClientManager.atClient.getCurrentAtSign()! == model.sender) {
            model.isSender = true;
          } else {
            model.isSender = false;
          }

          dudes.add(model);
        }
      } on Exception catch (e) {
        ScaffoldMessenger(child: SnackBar(content: Text(e.toString())));
      }
    }
    return dudes;
  }

  /// Subscribes to the stream of data being sent to the current atsign.
  void monitorNotifications(BuildContext context) {
    atClientManager.notificationService
        .subscribe(regex: 'at_skeleton_app')
        .listen(
      (AtNotification notification) async {
        String? currentAtsign = DudeService.getInstance()
            .atClientManager
            .atClient
            .getCurrentAtSign();

        if (currentAtsign == notification.to) {
          await LocalNotificationService().showNotifications(
              notification.id.length,
              'Dude',
              '${notification.from} sent you a dude',
              1);
        }
      },
    );
  }

  /// Fetch the current atsign contacts.
  Future<List<AtContact>?> getContactList() {
    return contactService.fetchContacts();
  }

  /// Fetch the current atsign profile image
  Future<Uint8List?> getCurrentAtsignProfileImage() async {
    return contactService
        .getContactDetails(atClientManager.atClient.getCurrentAtSign(), null)
        .then((value) {
      return value['image'];
    });
  }

  /// Fetch details for the current atsign
  Future<dynamic> getCurrentAtsignContactDetails() async {
    return contactService
        .getContactDetails(atClientManager.atClient.getCurrentAtSign(), null)
        .then((value) {
      return value;
    });
  }

  /// Get the profile stats for the current atsign
  Future<ProfileModel> getProfile() async {
    return await atClientManager.atClient
        .getAtKeys(
          regex: 'dude_profile_',
          sharedBy: atClientManager.atClient.getCurrentAtSign(),
        )
        .then(
          (value) => atClientManager.atClient.get(value.first).then(
            (value) {
              var model = ProfileModel.fromJson(
                jsonDecode(value.value),
              );
              model.createdAt = value.metadata!.createdAt;
              return model;
            },
          ),
        );
  }

  /// Save senders atsign to the current atsign local secondary.
  Future<void> putSenderAtsign(
      {required String senderAtsign, required String receiverAtsign}) async {
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var key = AtKey()
      ..key = 'dude_sender_atsigns_' + senderAtsign.replaceFirst('@', '')
      ..metadata = metaData
      ..sharedBy = senderAtsign
      ..sharedWith = receiverAtsign
      ..namespace = '';
    try {
      await atClientManager.notificationService.notify(
        NotificationParams.forUpdate(
          key,
          value: senderAtsign,
        ),
      );
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.message}');
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
    }
  }

  /// Get sender atsign saved in the current atsign remote secondary.
  Future<List<String>> getSenderAtsigns() async {
    // @blizzard30:some_uuid.at_skeleton_app@assault30
    // @blizzard30:signing_privatekey@blizzard30

    List<AtKey> keysList =
        await atClientManager.atClient.getAtKeys(regex: 'dude_sender_atsigns_');

    List<String> senderAtsigns = [];
    for (AtKey key in keysList) {
      try {
        AtValue _keyValue = await atClientManager.atClient.get(key);
        senderAtsigns.add(_keyValue.value);
      } on AtClientException catch (atClientExcep) {
        _logger.severe('❌ AtClientException : ${atClientExcep.message}');
      } catch (e) {
        _logger.severe('❌ Exception : ${e.toString()}');
      }
    }
    return senderAtsigns;
  }

  /// Delete dude sent to the current atsign.
  Future<bool> deleteDude(DudeModel dude) async {
    try {
      List<AtKey> dudeAtKey =
          await atClientManager.atClient.getAtKeys(regex: dude.id);
      bool isDeleted = await atClientManager.atClient.delete(dudeAtKey[0]);

      return isDeleted;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.message}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }

  /// Delete contact from contact list.
  Future<bool> deleteContact(String atSign) async {
    try {
      bool isDeleted = await contactService.deleteAtSign(atSign: atSign);

      return isDeleted;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.message}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }

  /// Get the profile stats for the current atsign
  Future<PersonaModel> getPersona() async {
    return await atClientManager.atClient
        .getAtKeys(
          regex: 'dude_persona',
          sharedBy: atClientManager.atClient.getCurrentAtSign(),
        )
        .then(
          (value) => atClientManager.atClient.get(value.first).then(
            (value) {
              return PersonaModel.fromJson(
                jsonDecode(value.value),
              );
            },
          ),
        );
  }

  /// Saves Dude to the receiver's remote secondary and stats to the sender's local secondary.
  Future<bool> putPersona(
    PersonaModel persona,
  ) async {
    bool isCompleted = false;

    var profileKey = AtKey.self('dude_persona',
            sharedBy: atClientManager.atClient.getCurrentAtSign()!)
        .build();

    await atClientManager.atClient
        .put(
          profileKey,
          json.encode(
            persona.toJson(),
          ),
        )
        .whenComplete(() => isCompleted = true)
        .onError((error, stackTrace) => isCompleted = false);

    return isCompleted;
  }
}
