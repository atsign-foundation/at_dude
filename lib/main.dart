// 🎯 Dart imports:
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_client/src/listener/sync_progress_listener.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'controller/authentication_controller.dart';
import 'controller/controller.dart';
import 'dude_theme.dart';
import 'screens/profile_screen.dart';
import 'screens/screens.dart';
import 'services/services.dart';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

import 'widgets/widgets.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService().initNotification();

  // * AtEnv is an abstraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  AtSignLogger.root_level = 'FINER';

  try {
    await AtEnv.load();
  } catch (e) {
    _logger.finer('Environment failed to load from .env: ', e);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DudeController()),
        ChangeNotifierProvider.value(value: ContactsController()),
        ChangeNotifierProvider.value(value: AuthenticationController()),
      ],
      child: MaterialApp(
        home: const MyApp(),
        theme: DudeTheme.light(),
        routes: {
          SendDudeScreen.routeName: (context) => const SendDudeScreen(),
          HistoryScreen.routeName: (context) => const HistoryScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
        },
        navigatorKey: NavigationService.navKey,
      ),
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _handleOnboard(context));
  }

  /// Signs user into the @platform.
  void _handleOnboard(BuildContext context) async {
    if (mounted) {
      Onboarding(
        context: context,
        atClientPreference: await futurePreference,
        domain: AtEnv.rootDomain,
        rootEnvironment: AtEnv.rootEnvironment,
        appAPIKey: AtEnv.appApiKey,
        onboard: (value, atsign) async {
          dudeService
            ..atClientService = value[atsign]
            ..atClient = dudeService.atClientService!.atClientManager.atClient;

          _logger.finer('Successfully onboarded $atsign');
          DudeService.getInstance().monitorNotifications(context);
          DudeService.getInstance()
              .atClientManager
              .syncService
              .addProgressListener(MySyncProgressListener());
          initializeContactsService(rootDomain: AtEnv.rootDomain);
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('@dude'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 200,
            icon: Image.asset('assets/images/dude_logo.png'),
            onPressed: null,
          ),
          ElevatedButton(
            onPressed: () {
              _handleOnboard(context);
            },
            child: const Text('Start Duding'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Or',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                    ),
                  ),
                ]),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomResetButton(
              buttonText: 'Reset @sign',
              width: 110,
            ),
          ),
        ],
      ),
    );
  }
}

class MySyncProgressListener extends SyncProgressListener {
  @override
  void onSyncProgressEvent(SyncProgress syncProgress) async {
    if (syncProgress.syncStatus == SyncStatus.success) {
      BuildContext context = NavigationService.navKey.currentContext!;
      await context.read<DudeController>().getDudes();
    }
  }
}
