import 'package:flutter/material.dart';

import '../models/persona_model.dart';
import '../services/dude_service.dart';

class PersonaController with ChangeNotifier {
  PersonaModel _personaModel = PersonaModel.standard();

  PersonaModel get personaModel => _personaModel;
  Future<void> getPersona() async {
    _personaModel = await DudeService.getInstance().getPersona();
    notifyListeners();
  }

  Future<bool> putPersona(PersonaModel persona) async {
    var result = await DudeService.getInstance().putPersona(persona);
    notifyListeners();
    return result;
  }
}
