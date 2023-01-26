import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';
import '../models/dude_model.dart';

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
        return 'less than 1 second ';
      } else if (duration >= const Duration(seconds: 1) &&
          duration < const Duration(seconds: 60)) {
        return '${duration.inSeconds} seconds ';
      } else if (duration >= const Duration(minutes: 1) &&
          duration < const Duration(minutes: 60)) {
        return '${duration.inMinutes} minute';
      } else {
        return '${duration.inHours} hour ';
      }
    }

    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IconButton(
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
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dude.sender.replaceFirst('@', '') +
                        " sent you a " +
                        timeCategory(dude.duration) +
                        dude.dude,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
