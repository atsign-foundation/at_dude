import 'package:at_dude/services/dude_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:at_dude/models/dude_model.dart';

class DudeBubble extends StatelessWidget {
  DudeBubble({
    Key? key,
    required this.dude,
  }) : super(key: key);

  final DudeModel dude;
  final AudioCache audioPlayer = AudioCache();

  @override
  Widget build(BuildContext context) {
    final bool isMe =
        dude.sender == DudeService.getInstance().atClient!.getCurrentAtSign();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            dude.sender,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Theme.of(context).colorScheme.primary : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: IconButton(
                        onPressed: () async {
                          await audioPlayer.play('audios/dude.wav');
                        },
                        icon: const Icon(Icons.play_arrow_outlined)),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dude.dude,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          'To:' + dude.receiver,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 10.0,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
