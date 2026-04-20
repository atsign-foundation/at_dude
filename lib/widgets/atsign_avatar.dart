// 🎯 Dart imports:
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screens/stats_screen.dart';
import '../services/services.dart';

class AtsignAvatar extends StatefulWidget {
  const AtsignAvatar({Key? key}) : super(key: key);

  @override
  State<AtsignAvatar> createState() => _AtsignAvatarState();
}

class _AtsignAvatarState extends State<AtsignAvatar> {
  Uint8List? image;
  String? profileName;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await DudeService.getInstance()
          .getCurrentAtsignContactDetails()
          .then((value) {
        image = value['image'];
        profileName = value['name'];
      });
      profileName ??=
          DudeService.getInstance().atClientManager.atClient.getCurrentAtSign();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: image == null
            ? const Icon(
                Icons.person_outline,
                color: Colors.black,
              )
            : ClipOval(child: Image.memory(image!)),
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(StatsScreen.routeName, arguments: profileName);
      },
    );
  }
}
