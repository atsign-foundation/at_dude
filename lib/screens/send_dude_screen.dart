// import 'package:flutter_spotlight/flutter_spotlight.dart';

import 'dart:developer';

import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controller/controller.dart';
import '../models/dude_model.dart';
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
  DudeModel dude = DudeModel.newDude();
  late DateTime startTime;

  bool isLoading = false;

  bool onPressed = false;
  bool onInit = false;
  @override
  void initState() {
    initializeContactsService(rootDomain: AtEnv.rootDomain);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DudeController>().getDudes();
    });
    onInit = true;

    super.initState();
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  late SMITrigger? _onPressed;
  late SMIInput<double> _cardInt;
  double cardCount = 0.0;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _onPressed = controller.findInput<bool>('onPressed') as SMITrigger;
    _cardInt = controller.findInput<double>('cardInt') as SMINumber;
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
      SnackBars.notificationSnackBar(content: 'Select Dude First');
    } else {
      SnackBars.notificationSnackBar(content: 'Sending Dude... please wait.');
      await DudeService.getInstance().putDude(dude, contactAtsign).then(
        (value) {
          if (value) {
            SnackBars.notificationSnackBar(content: Texts.dudeSuccessfullySent);
          } else {
            SnackBars.errorSnackBar(content: 'Something went wrong, please try again.');
          }
        },
      );
    }
  }

  AtContact? contact;

  @override
  Widget build(BuildContext context) {
    if (onInit) {
      contact = ModalRoute.of(context)!.settings.arguments as AtContact?;
    }

    SizeConfig().init(context);

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
                              title: 'Send a Dude!', subtitle: 'Pst...Pick a contact first!', trailing: '📢')
                          : const DudeCard(
                              child: Text('Sending to...'),
                              width: double.maxFinite,
                            ),
                      contact != null
                          ? DudeCard(
                              color: Colors.white,
                              child: CustomContactListTile(
                                contact: contact!,
                                contactService: ContactService(),
                              ),
                            )
                          : const SizedBox(),
                      contact == null
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(fixedSize: const Size(double.maxFinite, 61.22)),
                              onPressed: () async {
                                await Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => ShowCaseWidget(
                                            builder: Builder(
                                          builder: (context) => const DudeContactsScreen(),
                                        )),
                                      ),
                                    )
                                    .whenComplete(() async => await NavigationService.navKey.currentContext!
                                        .read<DudeController>()
                                        .getContacts());
                              },
                              child: const Text('Select Contact'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(fixedSize: const Size(double.maxFinite, 61.22)),
                              onPressed: () async {
                                await _handleSendDudeToContact(
                                    dude: dude, contactAtsign: contact!.atSign!, context: context);
                                // prevent modal route from being called
                                onInit = false;
                                if (dude.selectedDudeType == null) {
                                  SnackBars.notificationSnackBar(content: 'Select a dude first!');
                                } else {
                                  setState(() {
                                    contact = null;
                                  });
                                }
                              },
                              child: const Text('Send Dude')),
                      SizedBox(
                        height: 400,
                        child: GestureDetector(
                          onTap: () async {
                            if (contact == null) {
                              SnackBars.notificationSnackBar(content: 'Select Contact first');
                            } else {
                              log('card count at start is: $cardCount');
                              _onPressed?.fire();
                              var audioAssets = [
                                'assets/audios/hi_dude_scott.wav',
                                'assets/audios/you_woudnt_believe_dude_scott.wav',
                                'assets/audios/awesome_dude_scott.wav'
                              ];
                              try {
                                await audioPlayer.setAsset(audioAssets[cardCount.toInt()]);
                                await audioPlayer.play();
                              } catch (e) {
                                log('Error playing audio is: $e');
                              }

                              _cardInt.value = cardCount;
                              dude.selectedDudeType = dude.getEnumFromIndex(_cardInt.value.toInt());
                              dude.saveId();
                              log('dude type is: ${dude.selectedDudeType}');

                              // only 3 dudes available so it need to be reset to zero to restart.
                              cardCount = cardCount + 1;
                              if (cardCount > 2) {
                                cardCount = 0;
                              }
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
                      contact == null ? const SizedBox() : const TipCard(tip: 'Tap the ball to select a Dude!')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading ? const LoadingIndicator() : const SizedBox()
      ]),
    );
  }
}
