import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/persona_controller.dart';

class PersonaImageWidget extends StatelessWidget {
  const PersonaImageWidget({
    this.isHappy = false,
    Key? key,
  }) : super(key: key);

  final bool isHappy;
  @override
  Widget build(BuildContext context) {
    if (isHappy) {
      return Consumer<PersonaController>(
        builder: (context, controller, child) => Image.asset(controller
            .personaModel
            .happyImages[controller.personaModel.selectedPersona.index]
            .values
            .first),
      );
    } else {
      return Consumer<PersonaController>(
        builder: (context, controller, child) => Image.asset(controller
            .personaModel
            .images[controller.personaModel.selectedPersona.index]
            .values
            .first),
      );
    }
  }
}
