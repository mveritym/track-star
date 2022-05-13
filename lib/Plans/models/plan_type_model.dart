import 'package:json_annotation/json_annotation.dart';

enum PlanType {
  @JsonValue('baseTraining') baseTraining,
  @JsonValue('race') race,
  @JsonValue('noPlan') noPlan,
}

extension PlanTypeExtension on PlanType {
  String getDisplayName() {
    switch(this) {
      case PlanType.baseTraining: return 'Base fitness';
      case PlanType.race: return 'A race';
      case PlanType.noPlan: return 'I\'m not following a plan';
    }
  }
}