// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fertilizer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FertilizerInfo _$FertilizerInfoFromJson(Map<String, dynamic> json) =>
    FertilizerInfo(
      basal: BasalDose.fromJson(json['basal'] as Map<String, dynamic>),
      topdress: (json['topdress'] as List<dynamic>)
          .map((e) => TopDressing.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FertilizerInfoToJson(FertilizerInfo instance) =>
    <String, dynamic>{'basal': instance.basal, 'topdress': instance.topdress};

BasalDose _$BasalDoseFromJson(Map<String, dynamic> json) => BasalDose(
  nitrogen: (json['nitrogen'] as num).toInt(),
  phosphorus: (json['phosphorus'] as num).toInt(),
  potash: (json['potash'] as num).toInt(),
);

Map<String, dynamic> _$BasalDoseToJson(BasalDose instance) => <String, dynamic>{
  'nitrogen': instance.nitrogen,
  'phosphorus': instance.phosphorus,
  'potash': instance.potash,
};

TopDressing _$TopDressingFromJson(Map<String, dynamic> json) => TopDressing(
  daysAfterTransplant: (json['daysAfterTransplant'] as num?)?.toInt(),
  daysAfterSowing: (json['daysAfterSowing'] as num?)?.toInt(),
  nitrogen: (json['nitrogen'] as num).toInt(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$TopDressingToJson(TopDressing instance) =>
    <String, dynamic>{
      'daysAfterTransplant': instance.daysAfterTransplant,
      'daysAfterSowing': instance.daysAfterSowing,
      'nitrogen': instance.nitrogen,
      'note': instance.note,
    };
