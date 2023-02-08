// import 'package:flutter_spotlight/flutter_spotlight.dart';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../controller/controller.dart';
import '../controller/persona_controller.dart';
import '../models/dude_model.dart';
import '../models/persona_model.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/dude_card.dart';
import '../widgets/dude_list_tile.dart';
import '../widgets/tip_card.dart';
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
  final bool _buttonPressed = false;
  DudeModel dude = DudeModel.newDude();
  late DateTime startTime;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool isLoading = false;

  GlobalKey keyFingerPrintButton = GlobalKey();

  GlobalKey keyContactButton = GlobalKey();
  GlobalKey keyFavoriteContact = GlobalKey();
  GlobalKey contactKey = GlobalKey();
  List<GlobalKey<State<StatefulWidget>>> showcaseList = [];

  late RiveAnimationController _controller;
  bool onPressed = false;

  @override
  void initState() {
    initializeContactsService(rootDomain: AtEnv.rootDomain);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<PersonaController>(context, listen: false).getPersona();
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

      final personaStatus = await SharedPreferencesService.getPersonaStatus();
      if (personaStatus) {
        var dudeService = DudeService.getInstance();
        var result = await dudeService.putPersona(PersonaModel.standard());
        if (result) await SharedPreferencesService.setPersonaStatus();
      }
    });
    super.initState();
    _controller = OneShotAnimation(
      'bouncing ball',
      autoplay: false,
      onStop: () => setState(() => onPressed = false),
      onStart: () => setState(() => onPressed = true),
    );
  }

  late SMITrigger? _onPressed;
  late SMIInput<double> _cardInt;
  double cardCount = -1;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _onPressed = controller.findInput<bool>('onPressed') as SMITrigger;
    _cardInt = controller.findInput<double>('cardInt') as SMINumber;
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
    if (dude.selectedDudeType == null) {
      SnackBars.notificationSnackBar(
          content: 'Select Dude First', context: context);
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
    final AtContact? contact =
        ModalRoute.of(context)!.settings.arguments as AtContact?;
    SizeConfig().init(context);

    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const DudeBottomNavigationBar(
        selectedIndex: 2,
      ),
      body: Stack(children: [
        const AppBackground(
          alignment: Alignment.centerLeft,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      contact == null
                          ? const DudeListTile(
                              title: 'Send a Dude!',
                              subtitle: 'Pst...Pick a contact first!',
                              trailing: '📢')
                          : DudeCard(
                              child: const Text('Sending to...'),
                              width: double.maxFinite,
                            ),
                      contact != null
                          ? DudeCard(
                              color: Colors.white,
                              child: CustomContactListTile(
                                showcaseKey: contactKey,
                                contact: contact,
                                contactService: ContactService(),
                              ),
                            )
                          : const SizedBox(),
                      contact == null
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize:
                                      const Size(double.maxFinite, 61.22)),
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
                                                                    context:
                                                                        context),
                                                          ))))),
                                    )
                                    .whenComplete(() async => await context
                                        .read<DudeController>()
                                        .getContacts());
                              },
                              child: const Text('Select Contact'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize:
                                      const Size(double.maxFinite, 61.22)),
                              onPressed: () {
                                _handleSendDudeToContact(
                                    dude: dude,
                                    contactAtsign: contact.atSign!,
                                    context: context);
                              },
                              child: const Text('Send Dude')),
                      SizedBox(
                        height: 400,
                        child: GestureDetector(
                          onTap: () {
                            if (contact == null) {
                              SnackBars.notificationSnackBar(
                                  content: 'Select Contact first',
                                  context: context);
                            } else {
                              _onPressed?.fire();
                              setState(() {
                                cardCount = cardCount + 1;
                                if (cardCount > 2) {
                                  cardCount = 0;
                                }
                              });
                              _cardInt.value = cardCount;
                              dude.selectedDudeType =
                                  dude.getEnumFromIndex(_cardInt.value.toInt());
                              dude.saveId();
                            }
                          },
                          child: RiveAnimation.asset(
                            'assets/animations/drifty_rory_alt_6.riv',
                            fit: BoxFit.contain,
                            animations: const ['state machine 2'],
                            // controllers: [_controller],
                            onInit: _onRiveInit,
                          ),
                        ),
                      ),
                      contact == null
                          ? const SizedBox()
                          : const TipCard(tip: 'Tap the ball to select a Dude!')
                    ],
                  ),
                ),
                // Flexible(
                //   flex: 3,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Showcase(
                //         key: keyFingerPrintButton,
                //         description: Texts.sendDudeIconDesc,
                //         contentPadding: const EdgeInsets.only(
                //             top: 8, bottom: 8, right: 8, left: 44),
                //         child: GestureDetector(
                //           child: ElevatedButton(
                //             onPressed: () async {
                //               startTime = DateTime.now();

                //               _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                //               dude.saveId;
                //               setState(() {
                //                 rawTime = _stopWatchTimer.rawTime.value;
                //                 dude.saveDude(strArr.join("").toString());
                //               });
                //               _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                //               dude.saveDuration(startTime);
                //             },
                //             child: const Icon(
                //               Icons.fingerprint,
                //               size: 40,
                //             ),
                //           ),
                //           onLongPressStart: (_) async {
                //             startTime = DateTime.now();
                //             if (_stopWatchTimer.rawTime.value > 0) {
                //               _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                //             }
                //             _stopWatchTimer.onExecute.add(StopWatchExecute.start);

                //             _buttonPressed = true;
                //             do {
                //               strArr.insert(1, "u");
                //               setState(() {
                //                 rawTime = _stopWatchTimer.rawTime.value;
                //                 dude.saveDude(strArr.join("").toString());
                //               });
                //               await Future.delayed(const Duration(seconds: 1));
                //             } while (_buttonPressed);
                //           },
                //           onLongPressEnd: (_) {
                //             setState(() {
                //               _buttonPressed = false;
                //             });

                //             _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                //             dude.saveDuration(startTime);
                //             dude.saveId();
                //           },
                //         ),
                //       ),
                //       const SizedBox(
                //         width: 25,
                //       ),
                //       Showcase(
                //         key: keyContactButton,
                //         description: Texts.showContactScreenIconDesc,
                //         child: ElevatedButton(
                //           child: const Icon(
                //             Icons.contacts_outlined,
                //             size: 40,
                //           ),
                //           onPressed: () async {
                //             await Navigator.of(context)
                //                 .push(
                //                   MaterialPageRoute(
                //                       builder: (BuildContext context) =>
                //                           ShowCaseWidget(
                //                               builder: Builder(
                //                                   builder: ((context) =>
                //                                       DudeContactsScreen(
                //                                         // showFavoriteContactTutorial:
                //                                         //     showFavoriteContactTutorial,
                //                                         onSendIconPressed: (String
                //                                                 atsign) =>
                //                                             _handleSendDudeToContact(
                //                                                 dude: dude,
                //                                                 contactAtsign:
                //                                                     atsign,
                //                                                 context: context),
                //                                       ))))),
                //                 )
                //                 .whenComplete(() async => await context
                //                     .read<DudeController>()
                //                     .getContacts());
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 180,
                //   child: FavoriteContacts(
                //     favoriteContactKey: keyFavoriteContact,
                //     dude: dude,
                //     updateIsLoading: updateIsLoading,
                //   ),
                // ),
              ],
            ),
          ),
        ),
        isLoading ? const LoadingIndicator() : const SizedBox()
      ]),
    );
  }
}
