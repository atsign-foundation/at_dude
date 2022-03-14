import 'dart:async';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_dude/screens/screens.dart';
import 'package:at_dude/screens/send_dude_screen.dart';
import 'package:at_dude/services/dude_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import 'dude_theme.dart';
import 'home_screen.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  // * AtEnv is an abtraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  try {
    await AtEnv.load();
  } catch (e) {
    _logger.finer('Environment failed to load from .env: ', e);
  }
  runApp(
    MaterialApp(
      home: const MyApp(),
      theme: DudeTheme.light(),
      routes: {
        SendDudeScreen.routeName: (context) => const SendDudeScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
      },
    ),
  );
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();
  DudeService dudeService = DudeService.getInstance();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _handleOnboard(context));
  }

  void _handleOnboard(BuildContext context) async {
    if (mounted) {
      Onboarding(
        context: context,
        atClientPreference: await futurePreference,
        domain: AtEnv.rootDomain,
        rootEnvironment: AtEnv.rootEnvironment,
        appAPIKey: AtEnv.appApiKey,
        onboard: (value, atsign) {
          dudeService
            ..atClientService = value[atsign]
            ..atClient = dudeService.atClientService!.atClientManager.atClient;

          _logger.finer('Successfully onboarded $atsign');
        },
        onError: (error) {
          _logger.severe('Onboarding throws $error error');
        },
        nextScreen: const SendDudeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('At Dude'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Onboard"),
          onPressed: () => _handleOnboard(context),
        ),
      ),
    );
  }
}
