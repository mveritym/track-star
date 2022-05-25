import 'package:firebase_analytics/firebase_analytics.dart';

enum FirebaseEvents {
  tapSuggestedPlansLink,
  createNewPlan,
  editPlan,
  deletePlan,
  completeEvent,
  startEditEvent,
  finishEditEvent,
}

extension FirebaseEventsLogger on FirebaseAnalytics {
  void logCustomEvent(FirebaseEvents event) {
    logEvent(name: event.name);
  }
}
