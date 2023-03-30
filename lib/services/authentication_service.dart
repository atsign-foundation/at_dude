// 🎯 Dart imports:
import 'dart:async';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:at_utils/at_utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/arguments.dart';
import '../utils/enums.dart';
import '../utils/utils.dart';
import '../widgets/dude_navigation_screen.dart';
import '../widgets/snackbars.dart';
import 'services.dart';

/// A singleton that makes all the network calls to the @platform.
class AuthenticationService {
  static final AuthenticationService _singleton = AuthenticationService._internal();
  AuthenticationService._internal();

  factory AuthenticationService.getInstance() {
    return _singleton;
  }
  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  AtClient? atClient;
  AtClientService? atClientService;
  var atClientManager = AtClientManager.getInstance();
  static var atContactService = ContactService();

  /// This function will clear the keychain if the app installed newly again.
  Future<void> checkFirstRun() async {
    _logger.finer('Checking for keychain entries to clear');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('first_run') ?? true) {
      _logger.finer('First run detected. Clearing keychain');
      await clearKeychainEntries();
      await _prefs.setBool('first_run', false);
    }
  }

  Future<void> clearKeychainEntries() async {
    List<String> atsignList = await KeyChainManager.getInstance().getAtSignListFromKeychain();
    if (atsignList.isEmpty) {
      return;
    } else {
      await Future.forEach(atsignList, (String atsign) async {
        await KeyChainManager.getInstance().resetAtSignFromKeychain(atsign);
      });
    }
  }

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
  void handleSwitchAtsign(String? atsign) async {
    final result = await AtOnboarding.onboard(
      context: NavigationService.navKey.currentContext!,
      isSwitchingAtsign: true,
      atsign: atsign,
      config: AtOnboardingConfig(
        atClientPreference: await loadAtClientPreference(),
        domain: AtEnv.rootDomain,
        rootEnvironment: AtEnv.rootEnvironment,
        appAPIKey: AtEnv.appApiKey,
      ),
    );
    switch (result.status) {
      case AtOnboardingResultStatus.success:
        _logger.finer('Successfully onboarded ${result.atsign}');
        DudeService.getInstance().monitorNotifications(NavigationService.navKey.currentContext!);
        DudeService.getInstance().atClientManager.atClient.syncService.addProgressListener(MySyncProgressListener());
        initializeContactsService(rootDomain: AtEnv.rootDomain);
        await Navigator.popAndPushNamed(NavigationService.navKey.currentContext!, DudeNavigationScreen.routeName,
            arguments: Arguments(
              route: Screens.sendDude.index,
            ));

        break;

      case AtOnboardingResultStatus.error:
        _logger.severe('Onboarding throws ${result.message} error');
        SnackBars.errorSnackBar(content: result.message ?? '');
        break;

      case AtOnboardingResultStatus.cancel:
        break;
    }
    // Onboarding(
    //   atsign: atsign,
    //   context: NavigationService.navKey.currentContext!,
    //   atClientPreference: await loadAtClientPreference(),
    //   domain: AtEnv.rootDomain,
    //   rootEnvironment: AtEnv.rootEnvironment,
    //   appAPIKey: AtEnv.appApiKey,
    //   onboard: (value, atsign) async {
    //     DudeService.getInstance()
    //       ..atClientService = value[atsign]
    //       ..atClient = DudeService.getInstance()
    //           .atClientService!
    //           .atClientManager
    //           .atClient;

    //     _logger.finer('Successfully onboarded $atsign');
    //   },
    //   onError: (error) {
    //     _logger.severe('Onboarding throws $error error');
    //   },
    //   nextScreen: const SendDudeScreen(),
    // );
  }

  /// Get atsigns associated with the app.
  Future<List<String>?> getAtsignList() async {
    try {
      return KeychainUtil.getAtsignList();
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.message}');
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
