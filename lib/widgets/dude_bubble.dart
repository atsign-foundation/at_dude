import 'dart:developer';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../dude_theme.dart';
import '../models/arguments.dart';
import '../models/dude_model.dart';
import '../services/navigation_service.dart';
import '../services/shared_preferences_service.dart';
import '../utils/enums.dart';
import 'dude_add_contact_dialog.dart';
import 'dude_card.dart';
import 'dude_navigation_screen.dart';

class DudeBubble extends StatefulWidget {
  const DudeBubble({
    Key? key,
    required this.dude,
  }) : super(key: key);

  final DudeModel dude;

  @override
  State<DudeBubble> createState() => _DudeBubbleState();
}

class _DudeBubbleState extends State<DudeBubble> with SingleTickerProviderStateMixin {
  final AudioPlayer audioPlayer = AudioPlayer();
  late Animation<double> animation;
  late AnimationController controller;
  late Duration duration;
  bool isDudeRead = false;
  bool isDudeReplied = false;
  AtContact? atContact;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isDudeRead = await SharedPreferencesService.getDudeReadStatus(widget.dude);
      isDudeReplied = await SharedPreferencesService.getDudeReplyStatus(widget.dude);
      setState(() {
        isDudeRead;
      });
      log('init state isDudeRead: $isDudeRead');

      // await ContactService().fetchContacts().then((value) {
      //   atContact = value?.firstWhere((element) => element.atSign == widget.dude.sender);
      // });
    });

    if (widget.dude.selectedDudeType == DudeType.hi) {
      audioPlayer.setAsset('assets/audios/hi_dude_scott.wav');
      duration = const Duration(seconds: 2);
    } else if (widget.dude.selectedDudeType == DudeType.youWontBelieve) {
      audioPlayer.setAsset('assets/audios/you_woudnt_believe_dude_scott.wav');
      duration = const Duration(seconds: 6);
    } else if (widget.dude.selectedDudeType == DudeType.awesome) {
      audioPlayer.setAsset('assets/audios/awesome_dude_scott.wav');
      duration = const Duration(seconds: 2);
    }

    log('duration is' + duration.toString());
    controller = AnimationController(vsync: this, duration: duration, upperBound: 315);

    animation = Tween<double>(begin: 0, end: 315).animate(controller)
      ..addListener(() {
        controller.stop();
        setState(() {});
      });

    controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  double convertDurationToWidth(
      {required double currentDuration,
      double durationMin = 0,
      double widthMin = 0,
      double widthMax = 315,
      required double durationMax}) {
    var durationRange = durationMax - durationMin;
    double currentWidth = 0;
    if (durationRange == 0) {
      currentWidth = widthMin;
    } else {
      var widthRange = widthMax - widthMin;
      currentWidth = (((currentDuration - durationMin) * widthRange) / durationRange) + widthMin;
    }
    log('new value is: ' + currentWidth.toString());
    return currentWidth;
  }

  String getAtsignName(String atsign) {
    var context = NavigationService.navKey.currentContext!;
    context.read<ContactsController>().getContacts();
    var atContacts = context.watch<ContactsController>().contacts;

    String? name;
    try {
      if (atContacts.isNotEmpty) {
        name = atContacts.where((element) => element.atSign == atsign).first.tags!['name'] as String?;
      }
    } catch (e) {
      log('where condition not met');
    }

    if (name != null) {
      return name;
    } else {
      return atsign;
    }
  }

  @override
  Widget build(BuildContext context) {
    log('controller value is:' + controller.value.toString());
    log('audio player position is ${audioPlayer.position.inMilliseconds.toDouble()}');
    log('is dudeRead is $isDudeRead');

    if (controller.value != 315) {
      controller.animateTo(
        convertDurationToWidth(
            currentDuration: audioPlayer.position.inMilliseconds.toDouble(),
            durationMax: duration.inMilliseconds.toDouble()),
      );
    }

    return Stack(children: [
      Positioned(
        top: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(7)),
            width: controller.value,
            height: 50,
          ),
        ),
      ),
      DudeCard(
        color: !isDudeRead ? Colors.white : const Color(0xffFEE8E8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            !isDudeRead
                ? Expanded(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              setState(() {});

                              await audioPlayer.play();
                              await context.read<DudeController>().updateReadDudeCount(widget.dude);

                              setState(() {
                                isDudeRead = true;
                              });

                              if (controller.value == 315) {
                                // controller.reset();
                              }

                              // await showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) => const AlertDialog(
                              //           title: Text('Reply'),
                              //           content: Text('Resend Dude'),
                              //           actions: [],
                              //         ));
                            },
                            icon: const Icon(Icons.play_arrow_outlined)),
                        Flexible(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getAtsignName(widget.dude.sender),
                            ),
                            Text(
                              '"${widget.dude.message[widget.dude.selectedDudeType!.index].values.first}"',
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: kPrimaryColor, fontSize: 12),
                            )
                          ],
                        )),
                      ],
                    ),
                  )
                : Expanded(
                    child: Row(
                    children: [
                      IconButton(
                          onPressed: !isDudeReplied
                              ? () async {
                                  /// search for dudeBubble atsign in contact list
                                  AtContact? getAtContact() {
                                    var contactIndex = ContactService()
                                        .baseContactList
                                        .indexWhere((element) => element.contact?.atSign == widget.dude.sender);

                                    AtContact? atContact;
                                    if (contactIndex != -1) {
                                      atContact = ContactService().baseContactList[contactIndex].contact;
                                    }
                                    return atContact;
                                  }

                                  var result = false;
                                  AtContact? atContact = getAtContact();
                                  if (atContact == null) {
                                    result = await showDialog(
                                      context: context,
                                      builder: (context) => DudeAddContactDialog(
                                        atsign: widget.dude.sender.replaceFirst('@', ''),
                                      ),
                                    );
                                  }

                                  if (result) {
                                    atContact = getAtContact();
                                    await Navigator.popAndPushNamed(context, DudeNavigationScreen.routeName,
                                        arguments: Arguments(
                                            route: Screens.sendDude.index,
                                            atContact: atContact,
                                            dudeModel: widget.dude));
                                  }
                                }
                              : () {},
                          icon: !isDudeReplied ? const Icon(Icons.reply) : const Icon(Icons.check)),
                      Flexible(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            !isDudeReplied ? 'Send a dude back to' : 'You sent a dude back to',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            getAtsignName(widget.dude.sender),
                          ),
                        ],
                      )),
                    ],
                  )),
            !isDudeRead
                ? Text(
                    DateFormat.yMd().add_jm().format(widget.dude.timeSent.toLocal()),
                    style: const TextStyle(fontSize: 10),
                  )
                : IconButton(
                    onPressed: () async {
                      await SharedPreferencesService.deleteDudeReadStatus(widget.dude);
                      await Provider.of<DudeController>(context, listen: false).deleteDude(widget.dude);
                    },
                    icon: const Icon(Icons.close)),
          ],
        ),
      ),
    ]);
  }
}
