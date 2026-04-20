import '../utils/enums.dart';

class PersonaModel {
  final String id = 'dude_persona';
  List<Map<int, String>> names = [
    {Persona.tidalWaveTory.index: 'Tidal Wave Tory'},
    {Persona.kawabungaKenny.index: 'Kawabunga Kenny'},
    {Persona.gigiRiptide.index: 'Gigi Riptide'},
    {Persona.driftyRory.index: 'Drifty Rory'},
  ];
  List<Map<int, String>> images = [
    {Persona.tidalWaveTory.index: 'assets/images/personas/tidal_wave_tory.png'},
    {
      Persona.kawabungaKenny.index: 'assets/images/personas/kawabunga_kenny.png'
    },
    {Persona.gigiRiptide.index: 'assets/images/personas/gigi_riptide.png'},
    {Persona.driftyRory.index: 'assets/images/personas/drifty_rory.png'},
  ];
  List<Map<int, String>> happyImages = [
    {
      Persona.tidalWaveTory.index:
          'assets/images/personas/tidal_wave_tory_happy.png'
    },
    {
      Persona.kawabungaKenny.index: 'assets/images/personas/kawabunga_kenny.png'
    },
    {Persona.gigiRiptide.index: 'assets/images/personas/gigi_riptide.png'},
    {Persona.driftyRory.index: 'assets/images/personas/drifty_rory.png'},
  ];

  Persona selectedPersona = Persona.tidalWaveTory;

  PersonaModel.standard();

  PersonaModel({
    required this.selectedPersona,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedPersona': selectedPersona.name,
    };
  }

  PersonaModel.fromJson(Map<String, dynamic> json)
      : this(
          selectedPersona: getEnumFromName(json['selectedPersona']),
        );

  // @override
  // String toString() {
  //   return 'ProfileModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  // }

  static Persona getEnumFromName(String name) {
    if (name == Persona.tidalWaveTory.name) {
      return Persona.tidalWaveTory;
    } else if (name == Persona.kawabungaKenny.name) {
      return Persona.kawabungaKenny;
    } else if (name == Persona.gigiRiptide.name) {
      return Persona.gigiRiptide;
    } else if (name == Persona.driftyRory.name) {
      return Persona.driftyRory;
    } else {
      return Persona.tidalWaveTory;
    }
  }

  Persona getEnumFromIndex(int index) {
    if (index == Persona.tidalWaveTory.index) {
      return Persona.tidalWaveTory;
    } else if (index == Persona.kawabungaKenny.index) {
      return Persona.kawabungaKenny;
    } else if (index == Persona.gigiRiptide.index) {
      return Persona.gigiRiptide;
    } else if (index == Persona.driftyRory.index) {
      return Persona.driftyRory;
    } else {
      return Persona.tidalWaveTory;
    }
  }
}
