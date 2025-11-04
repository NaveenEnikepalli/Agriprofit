import 'package:json_annotation/json_annotation.dart';

part 'fertilizer.g.dart';

@JsonSerializable()
class FertilizerInfo {
  final BasalDose basal;
  final List<TopDressing> topdress;

  const FertilizerInfo({
    required this.basal,
    required this.topdress,
  });

  factory FertilizerInfo.fromJson(Map<String, dynamic> json) => _$FertilizerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$FertilizerInfoToJson(this);
}

@JsonSerializable()
class BasalDose {
  final int nitrogen;
  final int phosphorus;
  final int potash;

  const BasalDose({
    required this.nitrogen,
    required this.phosphorus,
    required this.potash,
  });

  factory BasalDose.fromJson(Map<String, dynamic> json) => _$BasalDoseFromJson(json);
  Map<String, dynamic> toJson() => _$BasalDoseToJson(this);
}

@JsonSerializable()
class TopDressing {
  final int? daysAfterTransplant;
  final int? daysAfterSowing;
  final int nitrogen;
  final String? note;

  const TopDressing({
    this.daysAfterTransplant,
    this.daysAfterSowing,
    required this.nitrogen,
    this.note,
  });

  factory TopDressing.fromJson(Map<String, dynamic> json) => _$TopDressingFromJson(json);
  Map<String, dynamic> toJson() => _$TopDressingToJson(this);
}
