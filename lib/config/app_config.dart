import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  const AppConfig({required this.appDisplayName, required this.firebaseOptions, required Widget child}) : super(child: child);

  final String appDisplayName;
  final FirebaseOptions firebaseOptions;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}