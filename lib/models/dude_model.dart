// ignore_for_file: unnecessary_cast

import 'package:uuid/uuid.dart';

import '../utils/enums.dart';

class DudeModel {
  late String id;
  late String sender;
  late String receiver;
  late DateTime timeSent;
  DudeType? selectedDudeType;
  DateTime? createdAt;
  bool? isSender;
  bool isRead;

  List<Map<int, String>> audios = [
    {DudeType.hi.index: 'assets/audios/dude.wav'},
    {DudeType.youWontBelieve.index: 'assets/audios/dude.wav'},
    {DudeType.awesome.index: 'assets/audios/dude.mp3'},
  ];
  List<Map<int, String>> message = [
    {DudeType.hi.index: 'Hi Dude!'},
    {DudeType.youWontBelieve.index: 'You won\'t believe Dude!'},
    {DudeType.awesome.index: 'Awesome Dude!'},
  ];

  DudeModel({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.timeSent,
    required this.selectedDudeType,
    this.isSender,
    this.createdAt,
    this.isRead = false,
  });

  DudeModel.newDude({this.isRead = false});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'timeSent': timeSent.toIso8601String(),
      'selectedDudeType': selectedDudeType!.name,
      'isRead': isRead,
    };
  }

  DudeModel.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String,
          sender: json['sender'] as String,
          receiver: json['receiver'] as String,
          timeSent: DateTime.parse((json['timeSent'])) as DateTime,
          selectedDudeType: getEnumFromName(json['selectedDudeType']),
        );

  // @override
  // String toString() {
  //   return 'DudeModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  // }

  static DudeType getEnumFromName(String name) {
    if (name == DudeType.hi.name) {
      return DudeType.hi;
    } else if (name == DudeType.youWontBelieve.name) {
      return DudeType.youWontBelieve;
    } else {
      return DudeType.awesome;
    }
  }

  DudeType getEnumFromIndex(int index) {
    if (index == DudeType.hi.index) {
      return DudeType.hi;
    } else if (index == DudeType.youWontBelieve.index) {
      return DudeType.youWontBelieve;
    } else if (index == DudeType.awesome.index) {
      return DudeType.awesome;
    } else {
      return DudeType.awesome;
    }
  }

  void saveId() => id = const Uuid().v4();

  void saveSender(String value) => sender = value;
  void saveReceiver(String value) => receiver = value;
  void saveTimeSent() => timeSent = DateTime.now().toUtc();
}
