import 'dart:convert';

class DudeModel {
  late String id;
  late String dude;
  late String sender;
  late String receiver;
  late DateTime timeSent;
  late Duration duration;
  DudeModel({
    required this.id,
    required this.dude,
    required this.sender,
    required this.receiver,
    required this.timeSent,
    required this.duration,
  });

  DudeModel.newDude();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dude': dude,
      'sender': sender,
      'receiver': receiver,
      'timeSent': timeSent,
      'duration': duration,
    };
  }

  DudeModel.fromJson(Map<String, dynamic> json)
      : this(
            id: json['id'] as String,
            dude: json['dude'] as String,
            sender: json['sender'] as String,
            receiver: json['receiver'] as String,
            timeSent: json['timeSent'] as DateTime,
            duration: json['duration'] as Duration);

  @override
  String toString() {
    return 'DudeModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  }

  void saveId() => id = DateTime.now().microsecondsSinceEpoch.toString();
  void saveDude(String value) => dude = 'dude-' + value;
  void saveSender(String value) => sender = value;
  void saveReceiver(String value) => receiver = value;
  void saveTimeSent(DateTime value) => timeSent = value;
  void saveDuration(Duration value) => duration = value;
}
