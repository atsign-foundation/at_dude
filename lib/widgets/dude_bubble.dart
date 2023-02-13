import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../models/dude_model.dart';
import '../utils/enums.dart';
import 'dude_card.dart';

class DudeBubble extends StatelessWidget {
  DudeBubble({
    Key? key,
    required this.dude,
  }) : super(key: key);

  final DudeModel dude;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    String timeCategory(Duration duration) {
      if (duration < const Duration(seconds: 1)) {
        return duration.inSeconds.toString();
      } else if (duration >= const Duration(seconds: 1) &&
          duration < const Duration(seconds: 60)) {
        return duration.inMinutes.toString();
      } else if (duration >= const Duration(minutes: 1) &&
          duration < const Duration(minutes: 60)) {
        return duration.inMinutes.toString();
      } else {
        return '${duration.inHours} hour ';
      }
    }

    String getAtsignName(String atsign) {
      var atContacts = context.watch<ContactsController>().contacts;
      log('atcontact is: ${atContacts.toString()}');
      String? name;
      if (atContacts.isNotEmpty) {
        var name = atContacts
            .where((element) => element.atSign == atsign)
            .first
            .tags!['name'] as String?;
      }

      log(dude.sender);
      if (name != null) {
        return name;
      } else {
        return atsign;
      }
    }

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
                        await audioPlayer.play(AssetSource('audios/dude.wav'));
                      } else {
                        await audioPlayer.play(AssetSource('audios/dude.mp3'));
                      }

                      Provider.of<DudeController>(context, listen: false)
                          .deleteDude(dude);
                    },
                    icon: const Icon(Icons.play_arrow_outlined)),
                Flexible(child: Text(getAtsignName(dude.sender))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat.yMd().add_jm().format(dude.timeSent),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
