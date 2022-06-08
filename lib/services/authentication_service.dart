// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
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
class AuthenticationService {
  static final AuthenticationService _singleton =
      AuthenticationService._internal();
  AuthenticationService._internal();

  factory AuthenticationService.getInstance() {
    return _singleton;
  }
  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  AtClient? atClient;
  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();
  static var atContactService = ContactService();

  /// Get atsigns associated with the app.
  Future<List<String>?> getAtsignList() async {
    try {
      return KeychainUtil.getAtsignList();
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
    }
  }

  /// get atsign AtContact.
  Future<AtContact> getAtContact(String atSign) async {
    return await getAtSignDetails(atSign);
  }
}
