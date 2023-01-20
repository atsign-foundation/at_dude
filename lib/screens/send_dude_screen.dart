// import 'package:flutter_spotlight/flutter_spotlight.dart';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../controller/controller.dart';
import '../models/dude_model.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/atsign_avatar.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class SendDudeScreen extends StatefulWidget {
  const SendDudeScreen({this.canPop = false, Key? key}) : super(key: key);
  final bool canPop;
  static String routeName = 'sendDudeScreen';

  @override
  State<SendDudeScreen> createState() => _SendDudeScreenState();
}

class _SendDudeScreenState extends State<SendDudeScreen> {
  bool _buttonPressed = false;
  DudeModel dude = DudeModel.newDude();
  late DateTime startTime;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool isLoading = false;

  GlobalKey keyFingerPrintButton = GlobalKey();

  GlobalKey keyContactButton = GlobalKey();
  GlobalKey keyFavoriteContact = GlobalKey();
  List<GlobalKey<State<StatefulWidget>>> showcaseList = [];

  @override
  void initState() {
    initializeContactsService(rootDomain: AtEnv.rootDomain);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final createDudeStatus =
          await SharedPreferencesService.getCreateDudeStatus();
      if (createDudeStatus) showcaseList.add(keyFingerPrintButton);

      final contactScreenStatus =
          await SharedPreferencesService.getContactScreenNavigationStatus();
      if (contactScreenStatus) showcaseList.add(keyContactButton);

      if (showcaseList.isNotEmpty) {
        ShowCaseWidget.of(context).startShowCase(showcaseList);
      }

      if (showcaseList.contains(keyFingerPrintButton)) {
        await SharedPreferencesService.setCreateDudeStatus();
      }

      if (showcaseList.contains(keyContactButton)) {
        await SharedPreferencesService.setContactScreenNavigationStatus();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose().then((value) => null);
    super.dispose();
  }

  Future<void> showFavoriteContactTutorial() async {
    if (context.read<ContactsController>().favoriteContacts.length == 1) {
      showcaseList.clear();

      final sendDudeFavoriteContactStatus =
          await SharedPreferencesService.getSendDudeToFavoriteStatus();

      if (sendDudeFavoriteContactStatus) showcaseList.add(keyFavoriteContact);

      if (showcaseList.isNotEmpty) {
        ShowCaseWidget.of(context).startShowCase(showcaseList);
      }

      if (showcaseList.contains(keyFavoriteContact)) {
        await SharedPreferencesService.setSendDudeToFavoriteStatus();
      }
    }
  }

  /// Update the isLoading property to it's appropriate state.
  void updateIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  /// Sends dude to the receiver of the dude
  Future<void> _handleSendDudeToContact({
    required DudeModel dude,
    required String contactAtsign,
    required BuildContext context,
  }) async {
    if (dude.dude.isEmpty) {
      SnackBars.notificationSnackBar(
          content: Texts.createDudeFirst, context: context);
    } else {
      SnackBars.notificationSnackBar(
          content: 'Sending Dude... please wait.', context: context);
      await DudeService.getInstance()
          .putDude(dude, contactAtsign, context)
          .then(
        (value) {
          if (value) {
            SnackBars.notificationSnackBar(
                content: Texts.dudeSuccessfullySent, context: context);
          } else {
            SnackBars.errorSnackBar(
                content: 'Something went wrong, please try again.',
                context: context);
          }
        },
      );
    }
  }

  int rawTime = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text(
          Texts.sendDude,
          style: TextStyle(color: Colors.black),
        ),
        actions: const [AtsignAvatar()],
        automaticallyImplyLeading: widget.canPop,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const DudeBottomNavigationBar(
        selectedIndex: 2,
      ),
      body: Stack(children: [
        const AppBackground(
          alignment: Alignment.centerLeft,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  DudeTimer(rawTime: rawTime),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        dude.dude,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Showcase(
                    key: keyFingerPrintButton,
                    description: Texts.sendDudeIconDesc,
                    contentPadding: const EdgeInsets.only(
                        top: 8, bottom: 8, right: 8, left: 44),
                    child: GestureDetector(
                      child: ElevatedButton(
                        onPressed: () async {
                          startTime = DateTime.now();

                          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                          dude.saveId;
                          setState(() {
                            rawTime = _stopWatchTimer.rawTime.value;
                            dude.saveDude(strArr.join("").toString());
                          });
                          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                          dude.saveDuration(startTime);
                        },
                        child: const Icon(
                          Icons.fingerprint,
                          size: 40,
                        ),
                      ),
                      onLongPressStart: (_) async {
                        startTime = DateTime.now();
                        if (_stopWatchTimer.rawTime.value > 0) {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        }
                        _stopWatchTimer.onExecute.add(StopWatchExecute.start);

                        _buttonPressed = true;
                        do {
                          strArr.insert(1, "u");
                          setState(() {
                            rawTime = _stopWatchTimer.rawTime.value;
                            dude.saveDude(strArr.join("").toString());
                          });
                          await Future.delayed(const Duration(seconds: 1));
                        } while (_buttonPressed);
                      },
                      onLongPressEnd: (_) {
                        setState(() {
                          _buttonPressed = false;
                        });

                        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                        dude.saveDuration(startTime);
                        dude.saveId();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Showcase(
                    key: keyContactButton,
                    description: Texts.showContactScreenIconDesc,
                    child: ElevatedButton(
                      child: const Icon(
                        Icons.contacts_outlined,
                        size: 40,
                      ),
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ShowCaseWidget(
                                          builder: Builder(
                                              builder: ((context) =>
                                                  DudeContactsScreen(
                                                    // showFavoriteContactTutorial:
                                                    //     showFavoriteContactTutorial,
                                                    onSendIconPressed: (String
                                                            atsign) =>
                                                        _handleSendDudeToContact(
                                                            dude: dude,
                                                            contactAtsign:
                                                                atsign,
                                                            context: context),
                                                  ))))),
                            )
                            .whenComplete(() async => await context
                                .read<DudeController>()
                                .getContacts());
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: FavoriteContacts(
                favoriteContactKey: keyFavoriteContact,
                dude: dude,
                updateIsLoading: updateIsLoading,
              ),
            ),
            const SizedBox(
              height: kBottomNavigationBarHeight,
            ),
          ],
        ),
        isLoading ? const LoadingIndicator() : const SizedBox()
      ]),
    );
  }
}
