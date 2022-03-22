import 'dart:typed_data';

import 'package:at_dude/dude_theme.dart';
import 'package:flutter/material.dart';

import '../services/services.dart';

class AtsignAvatar extends StatefulWidget {
  const AtsignAvatar({Key? key}) : super(key: key);

  @override
  State<AtsignAvatar> createState() => _AtsignAvatarState();
}

class _AtsignAvatarState extends State<AtsignAvatar> {
  Uint8List? image;
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      image = await DudeService.getInstance().getCurrentAtsignProfileImage();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: kPrimaryColor,
        child: image == null
            ? const Icon(
                Icons.person_outline,
              )
            : ClipOval(child: Image.memory(image!)),
      ),
      onTap: () {},
    );
  }
}
