import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track_star/Plans/models/plan.dart';

class PlansProvider extends ChangeNotifier {

  late StreamSubscription _plansSubscription;

  List<Plan> _plans = [];
  get plans => _plans;

  PlansProvider() {
    _plansSubscription = _initPlansSubscription();
  }

  @override
  void dispose() {
    _plansSubscription.cancel();
    super.dispose();
  }

  StreamSubscription<QuerySnapshot> _initPlansSubscription() {
    return FirebaseFirestore.instance
      .collection('plans')
      .orderBy('start_date')
      .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
        _plans = snapshot.docs.map((doc) => Plan.fromJson(doc.data() as Map<String, dynamic>)).toList();
        notifyListeners();
      });
  }

  static Future<List<Plan>> getPlans() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('plans')
        .orderBy('start_date')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();

    return snapshot.docs.map((doc) => Plan.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
