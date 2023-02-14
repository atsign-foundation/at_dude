import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../dude_theme.dart';
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
      context.read<ContactsController>().getContacts();
      var atContacts = context.watch<ContactsController>().contacts;

      String? name;
      if (atContacts.isNotEmpty) {
        var name = atContacts
            .where((element) => element.atSign == atsign)
            .first
            .tags!['name'] as String?;
      }

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
                      try {
                        if (dude.selectedDudeType == DudeType.hi) {
                          await audioPlayer.play(
                            AssetSource('audios/hi_dude_scott.wav'),
                          );
                        } else if (dude.selectedDudeType ==
                            DudeType.youWontBelieve) {
                          await audioPlayer.play(AssetSource(
                              'audios/you_woudnt_believe_dude_scott.wav'));
                        } else if (dude.selectedDudeType == DudeType.awesome) {
                          await audioPlayer.play(
                              AssetSource('audios/awesome_dude_scott.wav'));
                        }
                      } catch (e) {
                        log(e.toString());
                      }

                      Provider.of<DudeController>(context, listen: false)
                          .deleteDude(dude);
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: kPrimaryColor, fontSize: 12),
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
