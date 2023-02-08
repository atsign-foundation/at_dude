// ignore_for_file: unnecessary_cast

class ProfileModel {
  late String id;
  int dudesSent = 0;

  DateTime? createdAt;

  ProfileModel({required this.id, required this.dudesSent, this.createdAt});

  ProfileModel.newDude();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dudesSent': dudesSent,
    };
  }

  ProfileModel.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String,
          dudesSent: json['dudesSent'] as int,
        );

  // @override
  // String toString() {
  //   return 'ProfileModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  // }

  void saveId(String value) => id = value;
  void saveDudesSent(int value) => dudesSent = value;
}
