import 'package:firebase_auth/firebase_auth.dart';

class User {
  late String fullName;
  late int level;
  late String joinDate;
  late int points;
  late int xp;

  User({required this.fullName, required this.level, required this.joinDate, required this.points, required this.xp});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['name'],
      level: json['level'],
      joinDate: json['member_since'],
      points: json['points'],
      xp: json['xp'],
    );
  }

  String getFirstName() => fullName.split(" ").first;
  String getLastName() => fullName.split(" ").last;
  String? getEmail() => FirebaseAuth.instance.currentUser?.email;
}