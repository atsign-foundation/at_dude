// 🎯 Dart imports:
import 'dart:async';

import 'package:at_contacts_flutter/utils/init_contacts_service.dart';

import 'package:at_app_flutter/at_app_flutter.dart';

import 'package:at_client_mobile/at_client_mobile.dart';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_utils/at_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../screens/screens.dart';

import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;

import 'services.dart';

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

  Future<AtClientPreference> loadAtClientPreference() async {
    var dir = await getApplicationSupportDirectory();

    return AtClientPreference()
      ..rootDomain = AtEnv.rootDomain
      ..namespace = AtEnv.appNamespace
      ..hiveStoragePath = dir.path
      ..commitLogPath = dir.path
      ..isLocalStoreRequired = true;
    // TODO
    // * By default, this configuration is suitable for most applications
    // * In advanced cases you may need to modify [AtClientPreference]
    // * Read more here: https://pub.dev/documentation/at_client/latest/at_client/AtClientPreference-class.html
  }

  /// Signs user into the @platform.
  void handleOnboard(String atsign) async {
    Onboarding(
      atsign: atsign,
      context: NavigationService.navKey.currentContext!,
      atClientPreference: await loadAtClientPreference(),
      domain: AtEnv.rootDomain,
      rootEnvironment: AtEnv.rootEnvironment,
      appAPIKey: AtEnv.appApiKey,
      onboard: (value, atsign) async {
        DudeService.getInstance()
          ..atClientService = value[atsign]
          ..atClient = DudeService.getInstance()
              .atClientService!
              .atClientManager
              .atClient;

        _logger.finer('Successfully onboarded $atsign');
      },
      onError: (error) {
        _logger.severe('Onboarding throws $error error');
      },
      nextScreen: const SendDudeScreen(),
    );
  }

  /// Get atsigns associated with the app.
  Future<List<String>?> getAtsignList() async {
    try {
      return KeychainUtil.getAtsignList();
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      return [];
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return [];
    }
  }

  /// get atsign AtContact.
  Future<AtContact> getAtContact(String atSign) async {
    return await getAtSignDetails(atSign);
  }
}


// class MySyncProgressListener extends SyncProgressListener {
//   @override
//   void onSyncProgressEvent(SyncProgress syncProgress) async {
//     if (syncProgress.syncStatus == SyncStatus.success) {
//       BuildContext context = NavigationService.navKey.currentContext!;
//       await context.read<DudeController>().getDudes();
//     }
//   }
// }
