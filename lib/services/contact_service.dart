// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_utils/at_utils.dart';
import '../models/dude_model.dart';
import '../models/profile_model.dart';
import 'local_notification_service.dart';

/// A singleton that makes all the network calls to the @platform.
class ContactsService {
  static final ContactsService _singleton = ContactsService._internal();
  ContactsService._internal();

  factory ContactsService.getInstance() {
    return _singleton;
  }
  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  AtClient? atClient;
  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();
  static var atContactService = ContactService();

  /// Fetch the current atsign contacts.
  Future<List<AtContact>?> getContactList() {
    return atContactService.fetchContacts();
  }

  /// Fetch the current atsign profile image
  Future<Uint8List?> getCurrentAtsignProfileImage() async {
    return atContactService
        .getContactDetails(atClient!.getCurrentAtSign(), null)
        .then((value) {
      return value['image'];
    });
  }

  /// Fetch details for the current atsign
  Future<dynamic> getCurrentAtsignContactDetails() async {
    return atContactService
        .getContactDetails(atClient!.getCurrentAtSign(), null)
        .then((value) {
      return value;
    });
  }

  /// Delete contact from contact list.
  Future<bool> addContact(String atSign, String? nickname) async {
    try {
      bool isAdded =
          await atContactService.addAtSign(atSign: atSign, nickName: nickname);

      return isAdded;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }

  /// Delete contact from contact list.
  Future<bool> deleteContact(String atSign) async {
    try {
      bool isDeleted = await atContactService.deleteAtSign(atSign: atSign);

      return isDeleted;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }

  /// Add/remove contact as favorite.
  Future<bool> markUnmarkFavoriteContact(AtContact contact) async {
    try {
      bool isDeleted = await atContactService.markFavContact(contact);

      return isDeleted;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }
}
