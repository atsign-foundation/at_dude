import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../dude_theme.dart';
import '../models/dude_model.dart';
import '../services/navigation_service.dart';
import '../utils/enums.dart';
import 'dude_card.dart';

class DudeBubble extends StatelessWidget {
  DudeBubble({
    Key? key,
    required this.dude,
  }) : super(key: key);

  final DudeModel dude;
  final AudioPlayer audioPlayer = AudioPlayer();
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
    return DudeCard(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                    onPressed: () async {
                      if (dude.selectedDudeType == DudeType.hi) {
                        await audioPlayer.setAsset('assets/audios/hi_dude_scott.wav');
                        await audioPlayer.play();
                      } else if (dude.selectedDudeType == DudeType.youWontBelieve) {
                        await audioPlayer.setAsset('assets/audios/you_woudnt_believe_dude_scott.wav');
                        await audioPlayer.play();
                      } else if (dude.selectedDudeType == DudeType.awesome) {
                        await audioPlayer.setAsset('assets/audios/awesome_dude_scott.wav');
                        await audioPlayer.play();
                      }

                      await Provider.of<DudeController>(context, listen: false).deleteDude(dude);
                    },
                    icon: const Icon(Icons.play_arrow_outlined)),
                Flexible(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getAtsignName(dude.sender),
                    ),
                    Text(
                      '"${dude.message[dude.selectedDudeType!.index].values.first}"',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: kPrimaryColor, fontSize: 12),
                    )
                  ],
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat.yMd().add_jm().format(dude.timeSent.toLocal()),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
