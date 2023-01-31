import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/dude_controller.dart';
import '../models/dude_model.dart';
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
                      if (dude.duration.inSeconds < 1) {
                        await audioPlayer.play(AssetSource('audios/dude.wav'));
                      } else {
                        await audioPlayer.play(AssetSource('audios/dude.mp3'));
                      }

                      Provider.of<DudeController>(context, listen: false)
                          .deleteDude(dude);
                    },
                    icon: const Icon(Icons.play_arrow_outlined)),
                Flexible(child: Text(dude.sender.replaceFirst('@', ''))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat.yMd().add_jm().format(dude.createdAt!),
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                "${dude.duration.inMinutes.remainder(60)}:${(dude.duration.inSeconds.remainder(60))}",
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
