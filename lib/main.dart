// 🎯 Dart imports:
import 'dart:async';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
// ignore: implementation_imports

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'controller/controller.dart';
import 'dude_theme.dart';
import 'screens/profile_screen.dart';
import 'screens/screens.dart';
import 'services/services.dart';
import 'utils/utils.dart';
import 'widgets/widgets.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService().initNotification();

  // * AtEnv is an abstraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  AtSignLogger.root_level = 'FINER';
  await AuthenticationService.getInstance().checkFirstRun();
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
          debugShowCheckedModeBanner: false,
          home: const MyApp(),
          theme: DudeTheme.light(),
          routes: {
            SendDudeScreen.routeName: (context) => const SendDudeScreen(),
            HistoryScreen.routeName: (context) => const HistoryScreen(),
            ProfileScreen.routeName: (context) => const ProfileScreen(),
          },
          navigatorKey: NavigationService.navKey,
        )),
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
      final result = await AtOnboarding.onboard(
        context: context,
        config: AtOnboardingConfig(
          atClientPreference: await futurePreference,
          domain: AtEnv.rootDomain,
          rootEnvironment: AtEnv.rootEnvironment,
          appAPIKey: AtEnv.appApiKey,
        ),
      );
      switch (result.status) {
        case AtOnboardingResultStatus.success:
          _logger.finer('Successfully onboarded ${result.atsign}');
          // dudeService..atClient = result.
          DudeService.getInstance().monitorNotifications(context);
          DudeService.getInstance()
              .atClientManager
              .syncService
              .addProgressListener(MySyncProgressListener());
          initializeContactsService(rootDomain: AtEnv.rootDomain);

          await Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: ((context) => ShowCaseWidget(
                  builder:
                      Builder(builder: (context) => const SendDudeScreen()),
                )),
          ));

          break;

        case AtOnboardingResultStatus.error:
          _logger.severe('Onboarding throws ${result.message} error');
          SnackBars.errorSnackBar(
              content: result.message ?? '', context: context);
          break;

        case AtOnboardingResultStatus.cancel:
          break;
      }
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
        title: const Text('atDude'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const ResetAppButton(
            buttonText: 'Reset @sign',
          ),
        ],
      ),
    );
  }
}
