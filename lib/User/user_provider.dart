import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:track_star/Events/events.dart';
import 'package:uuid/uuid.dart';

part 'user_provider.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UserSettings {

  @JsonKey(required: true, name: 'settings_id')
  String id = const Uuid().v1();

  @JsonKey(required: true, name: 'user_id')
  String userId;

  @JsonKey(required: true, name: 'distance_unit')
  DistanceUnit unit;

  @JsonKey(defaultValue: '0', name: 'app_version')
  String appVersion;

  UserSettings(this.userId, this.unit, this.appVersion);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

  void toggleUnit() {
    if (unit == DistanceUnit.mi) {
      unit = DistanceUnit.km;
    } else {
      unit = DistanceUnit.mi;
    }
  }

  void save() {
    FirebaseFirestore.instance
        .collection('userSettings')
        .doc(id)
        .set(toJson());
  }

  void setVersion(String appVersion) {
    this.appVersion = appVersion;
  }
}

class UserSettingsProvider extends ChangeNotifier {

  late StreamSubscription _userSubscription;

  UserSettings? settings;

  UserSettingsProvider() {
    _userSubscription = _initUserSettingsSubscription();
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  StreamSubscription<QuerySnapshot> _initUserSettingsSubscription() {
    return FirebaseFirestore.instance
        .collection('userSettings')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      settings = snapshot.docs.map((doc) => UserSettings.fromJson(doc.data() as Map<String, dynamic>)).toList().first;
      notifyListeners();
    });
  }

  static Future<UserSettings?> get() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('userSettings')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (snapshot.docs.isEmpty) { return null; }

    return snapshot
        .docs
        .map((doc) => UserSettings.fromJson(doc.data()))
        .toList()
        .first;
  }

  void toggleUnit() {
    settings!.toggleUnit();
    FirebaseFirestore.instance
        .collection('userSettings')
        .doc(settings!.id)
        .update(settings!.toJson());
  }
}
